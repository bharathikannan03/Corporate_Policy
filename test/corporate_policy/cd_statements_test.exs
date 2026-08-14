defmodule CorporatePolicy.CdStatementsTest do
  use CorporatePolicy.DataCase, async: true

  alias CorporatePolicy.CdStatements
  alias CorporatePolicy.Repo
  alias CorporatePolicy.Corporates.Corporate
  alias CorporatePolicy.Policies.{Policy, FinancialYear, LineOfBusiness, PolicyType, Insurer}

  setup do
    corporate =
      Repo.insert!(%Corporate{
        corporate_name: "Test Corp CD",
        corporate_address: "123 Business Lane",
        pincode: "400001",
        city: "Mumbai",
        state: "Maharashtra",
        pan_number: "ABCDE1234F",
        corporate_status: 1,
        status: 1
      })

    fy =
      Repo.insert!(%FinancialYear{
        year_name: "2026-2027",
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
        name: "Insurer GMC CD",
        ref_md_line_of_businesses_id: lob.id,
        status: 1
      })

    policy =
      Repo.insert!(%Policy{
        corporate_name: corporate.corporate_name,
        ref_corporate_id: corporate.corporate_id,
        ref_fy_year_id: fy.id,
        ref_md_line_of_businesses_id: lob.id,
        line_of_business: "Health",
        ref_md_policy_types_id: policy_type.id,
        policy_type: "GMC",
        ref_select_insurer_id: insurer.id,
        select_insurer: insurer.name,
        policy_number: "POL-GMC-CD-123",
        status: 1
      })

    user =
      Repo.insert!(%CorporatePolicy.Accounts.User{
        first_name: "Corporate",
        last_name: "Manager",
        email_address: "cd_manager@example.com",
        password: "password123",
        status: 1
      })

    {:ok, corporate: corporate, policy: policy, user: user}
  end

  test "create_cd_account/2 creates account and avoids duplicate cd_number per corporate and policy",
       %{
         corporate: corporate,
         policy: policy,
         user: user
       } do
    attrs = %{
      "corporate_id" => corporate.corporate_id,
      "policy_id" => policy.id,
      "insurer_name" => policy.select_insurer,
      "cd_number" => "CD-998877"
    }

    assert {:ok, cd_account} = CdStatements.create_cd_account(attrs, user.id)
    assert cd_account.cd_number == "CD-998877"
    assert cd_account.corporate_id == corporate.corporate_id
    assert cd_account.policy_id == policy.id

    # Duplicate cd_number check
    assert {:error, "CD number already exists for the selected policy"} =
             CdStatements.create_cd_account(attrs, user.id)
  end

  test "list_cd_accounts_paginated/1 lists, sorts, and filters accounts", %{
    corporate: corporate,
    policy: policy,
    user: user
  } do
    attrs1 = %{
      "corporate_id" => corporate.corporate_id,
      "policy_id" => policy.id,
      "insurer_name" => policy.select_insurer,
      "cd_number" => "CD-AAAA"
    }

    attrs2 = %{
      "corporate_id" => corporate.corporate_id,
      "policy_id" => policy.id,
      "insurer_name" => policy.select_insurer,
      "cd_number" => "CD-BBBB"
    }

    {:ok, _ac1} = CdStatements.create_cd_account(attrs1, user.id)
    {:ok, _ac2} = CdStatements.create_cd_account(attrs2, user.id)

    # List all
    res = CdStatements.list_cd_accounts_paginated()
    assert res.total_entries == 2
    assert length(res.entries) == 2

    # Filter by search
    res_search = CdStatements.list_cd_accounts_paginated(%{"search" => "AAAA"})
    assert res_search.total_entries == 1
    assert hd(res_search.entries).cd_number == "CD-AAAA"

    # Fetch CD numbers list for corporate
    cd_list = CdStatements.list_cd_numbers_for_corporate(corporate.corporate_id)
    assert length(cd_list) == 2
    assert Enum.map(cd_list, & &1.cd_number) == ["CD-AAAA", "CD-BBBB"]

    # Get by corporate and number
    account =
      CdStatements.get_cd_account_by_corporate_and_number(corporate.corporate_id, "CD-AAAA")

    assert account.cd_number == "CD-AAAA"
  end
end
