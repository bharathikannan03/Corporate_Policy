defmodule CorporatePolicy.Workers.PolicyExpiryWorkerTest do
  use CorporatePolicy.DataCase, async: true
  use Oban.Testing, repo: CorporatePolicy.Repo

  alias CorporatePolicy.Repo
  alias CorporatePolicy.Policies.{Policy, LineOfBusiness, PolicyType, Insurer}
  alias CorporatePolicy.Corporates.Corporate
  alias CorporatePolicy.Workers.PolicyExpiryWorker

  setup do
    corporate =
      Repo.insert!(%Corporate{
        corporate_name: "Test Corp",
        corporate_address: "123 Test Street",
        status: 1,
        corporate_status: 1,
        pincode: "123456",
        city: "Test City",
        state: "Test State"
      })

    lob =
      Repo.insert!(%LineOfBusiness{
        line_of_business_value: "Health",
        display_id: 1,
        status: 1
      })

    pt =
      Repo.insert!(%PolicyType{
        policy_type_value: "GMC",
        display_id: 1,
        status: 1,
        ref_md_line_of_businesses_id: lob.id
      })

    insurer =
      Repo.insert!(%Insurer{
        name: "Test Insurer",
        ref_md_line_of_businesses_id: lob.id,
        status: 1
      })

    fy =
      Repo.insert!(%CorporatePolicy.Policies.FinancialYear{
        year_name: "2026",
        start_date: ~D[2026-04-01],
        end_date: ~D[2027-03-31],
        status: 1
      })

    policy_attrs = %{
      ref_corporate_id: corporate.corporate_id,
      ref_md_line_of_businesses_id: lob.id,
      ref_md_policy_types_id: pt.id,
      ref_select_insurer_id: insurer.id,
      ref_fy_year_id: fy.id,
      corporate_name: "Test Corp",
      line_of_business: "Health",
      policy_type: "GMC",
      select_insurer: "Test Insurer",
      status: 1
    }

    {:ok, policy_attrs: policy_attrs}
  end

  test "PolicyExpiryWorker automatically expires active policies whose end date has passed", %{
    policy_attrs: attrs
  } do
    # Policy 1: Not expired (ends in future)
    future_policy =
      Repo.insert!(
        struct(
          Policy,
          Map.merge(attrs, %{
            policy_start_date: Date.add(Date.utc_today(), -10),
            policy_end_date: Date.add(Date.utc_today(), 10),
            # Active
            status: 1
          })
        )
      )

    # Policy 2: Expired (ends in past)
    past_policy =
      Repo.insert!(
        struct(
          Policy,
          Map.merge(attrs, %{
            policy_start_date: Date.add(Date.utc_today(), -10),
            policy_end_date: Date.add(Date.utc_today(), -1),
            # Active
            status: 1
          })
        )
      )

    # Policy 3: Already expired in past
    already_expired_policy =
      Repo.insert!(
        struct(
          Policy,
          Map.merge(attrs, %{
            policy_start_date: Date.add(Date.utc_today(), -20),
            policy_end_date: Date.add(Date.utc_today(), -10),
            # Expired
            status: 3
          })
        )
      )

    # Execute the worker
    assert {:ok, 1} = perform_job(PolicyExpiryWorker, %{})

    # Verify statuses
    assert Repo.reload!(future_policy).status == 1
    assert Repo.reload!(past_policy).status == 3
    assert Repo.reload!(already_expired_policy).status == 3
  end
end
