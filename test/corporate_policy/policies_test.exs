defmodule CorporatePolicy.PoliciesTest do
  use CorporatePolicy.DataCase, async: false

  alias CorporatePolicy.Policies
  alias CorporatePolicy.Repo
  alias CorporatePolicy.Corporates.Corporate

  alias CorporatePolicy.Policies.{
    FinancialYear,
    LineOfBusiness,
    PolicyType,
    Insurer,
    FamilyDefinition,
    Tpa
  }

  setup do
    corporate =
      Repo.insert!(%Corporate{
        corporate_name: "Policies Test Corp",
        corporate_address: "123 Policy Lane",
        pincode: "400001",
        city: "Mumbai",
        state: "Maharashtra",
        pan_number: "ABCPOL1234",
        corporate_status: 1,
        status: 1
      })

    fy =
      Repo.insert!(%FinancialYear{
        year_name: "2026",
        start_date: ~D[2026-04-01],
        end_date: ~D[2027-03-31],
        status: 1
      })

    lob =
      Repo.insert!(%LineOfBusiness{
        line_of_business_value: "Health",
        display_id: 1,
        status: 1
      })

    policy_type =
      Repo.insert!(%PolicyType{
        policy_type_value: "GMC",
        ref_md_line_of_businesses_id: lob.id,
        display_id: 1,
        status: 1
      })

    insurer =
      Repo.insert!(%Insurer{
        name: "Insurer GMC Pol",
        ref_md_line_of_businesses_id: lob.id,
        status: 1
      })

    family_def =
      Repo.insert!(%FamilyDefinition{
        name: "Self + Spouse + 2 Children",
        display_id: 1,
        status: 1
      })

    tpa =
      Repo.insert!(%Tpa{
        name: "TPA GMC Pol",
        status: 1
      })

    {:ok,
     corporate: corporate,
     fy: fy,
     lob: lob,
     policy_type: policy_type,
     insurer: insurer,
     family_def: family_def,
     tpa: tpa}
  end

  defp create_test_policy(corporate, lob, policy_type, insurer, family_def, tpa, policy_number) do
    attrs = %{
      "ref_corporate_id" => corporate.corporate_id,
      "ref_md_line_of_businesses_id" => lob.id,
      "ref_md_policy_types_id" => policy_type.id,
      "ref_select_insurer_id" => insurer.id,
      "ref_md_family_definitions_id" => family_def.id,
      "ref_tpa_id" => tpa.id,
      "policy_number" => policy_number,
      "policy_start_date" => "2026-04-01",
      "policy_end_date" => "2027-03-31",
      "have_policy_number" => "1",
      "claim_submission_visibility" => "0",
      "ref_intimate_claim_visibilities_id" => "1"
    }

    {:ok, policy} = Policies.create_policy(attrs, 1)
    policy
  end

  test "create_policy/2 creates a policy and calculates initial fields", %{
    corporate: corporate,
    fy: fy,
    lob: lob,
    policy_type: policy_type,
    insurer: insurer,
    family_def: family_def,
    tpa: tpa
  } do
    policy =
      create_test_policy(corporate, lob, policy_type, insurer, family_def, tpa, "POL-ADD-01")

    assert policy.policy_number == "POL-ADD-01"
    assert policy.corporate_name == "Policies Test Corp"
    assert policy.ref_fy_year_id == fy.id
    assert policy.status == 2
  end

  test "update_policy/2 and update_policy_status/3 modifies policy details and status", %{
    corporate: corporate,
    lob: lob,
    policy_type: policy_type,
    insurer: insurer,
    family_def: family_def,
    tpa: tpa
  } do
    policy =
      create_test_policy(corporate, lob, policy_type, insurer, family_def, tpa, "POL-EDIT-01")

    # Update policy number
    update_attrs = %{"policy_number" => "POL-EDIT-01-UPDATED"}
    assert {:ok, updated_policy} = Policies.update_policy(policy, update_attrs)
    assert updated_policy.policy_number == "POL-EDIT-01-UPDATED"

    # Update policy status
    assert {:ok, policy_with_new_status} = Policies.update_policy_status(updated_policy, 1, 1)
    assert policy_with_new_status.status == 1
  end

  test "list_policies_paginated/1 lists and paginates policies", %{
    corporate: corporate,
    lob: lob,
    policy_type: policy_type,
    insurer: insurer,
    family_def: family_def,
    tpa: tpa
  } do
    policy =
      create_test_policy(corporate, lob, policy_type, insurer, family_def, tpa, "POL-LIST-01")

    res = Policies.list_policies_paginated(page: 1)
    assert res.total_entries == 1
    assert hd(res.entries).id == policy.id
  end

  test "delete_policy/1 removes a policy", %{
    corporate: corporate,
    lob: lob,
    policy_type: policy_type,
    insurer: insurer,
    family_def: family_def,
    tpa: tpa
  } do
    policy =
      create_test_policy(corporate, lob, policy_type, insurer, family_def, tpa, "POL-DEL-01")

    assert {:ok, _} = Policies.delete_policy(policy)
    assert is_nil(Policies.get_policy(policy.id))
  end
end
