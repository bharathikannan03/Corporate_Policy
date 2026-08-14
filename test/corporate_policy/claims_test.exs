defmodule CorporatePolicy.ClaimsTest do
  use CorporatePolicy.DataCase, async: true

  alias CorporatePolicy.Claims
  alias CorporatePolicy.Repo
  alias CorporatePolicy.Corporates.Corporate

  alias CorporatePolicy.Policies.{
    Policy,
    FinancialYear,
    LineOfBusiness,
    PolicyType,
    Insurer,
    TrnMappingLiveEmployee
  }

  setup do
    corporate =
      Repo.insert!(%Corporate{
        corporate_name: "Claims Test Corp",
        corporate_address: "99 Claim Rd",
        pincode: "400001",
        city: "Mumbai",
        state: "Maharashtra",
        pan_number: "PANCL1234E",
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
        name: "Claim Insurer Co",
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
        policy_number: "POL-CLAIM-11",
        status: 1
      })

    user =
      Repo.insert!(%CorporatePolicy.Accounts.User{
        first_name: "Claim",
        last_name: "Officer",
        email_address: "officer@example.com",
        password: "password123",
        status: 1,
        ref_corporate_id: corporate.corporate_id,
        department_id: 2
      })

    employee =
      Repo.insert!(%TrnMappingLiveEmployee{
        ref_policy_id: policy.id,
        ref_corporate_id: corporate.corporate_id,
        employee_code: "EMP-CL-01",
        employee_name: "Bob Claims",
        relationship: "Employee",
        status: "active",
        source_type: "Inception",
        created_by: user.id,
        updated_by: user.id
      })

    {:ok, corporate: corporate, policy: policy, user: user, employee: employee}
  end

  test "create_claim/3 and list_claims/3 workflows", %{
    corporate: corporate,
    policy: policy,
    user: user,
    employee: employee
  } do
    attrs = %{
      "ref_corporate_id" => corporate.corporate_id,
      "ref_policy_id" => policy.id,
      "employee_code" => employee.employee_code,
      "patient_name" => employee.employee_name,
      "estimated_amount" => "5000",
      "claim_reason" => "Fever",
      "claim_type" => "Cashless",
      "hospital_name" => "City Hospital",
      "hospital_address" => "99 Hospital Rd",
      "hospitalization_date" => Date.utc_today(),
      "discharge_date" => Date.add(Date.utc_today(), 1),
      "city" => "Mumbai",
      "state" => "Maharashtra",
      "pincode" => "400001"
    }

    assert {:ok, claim} = Claims.create_claim(attrs, user, :admin)
    assert claim.claim_status == "Draft"
    assert claim.claim_reason == "Fever"
    assert Decimal.to_integer(claim.estimated_amount) == 5000

    # List claims (admin portal sees all)
    res = Claims.list_claims(user, :admin)
    assert res.total_entries == 1
    assert hd(res.entries).id == claim.id

    # Update claim
    update_attrs = %{"estimated_amount" => "6500", "claim_reason" => "Malaria"}
    assert {:ok, updated_claim} = Claims.update_claim(claim, update_attrs, user, :admin)
    assert updated_claim.claim_reason == "Malaria"
    assert Decimal.to_integer(updated_claim.estimated_amount) == 5000

    # Submit claim (fails because we need at least 3 documents)
    assert {:error, :minimum_documents_not_met} = Claims.submit_claim(updated_claim, user, :admin)
  end

  test "lookup and accessible helper functions", %{
    corporate: corporate,
    policy: policy,
    user: user,
    employee: employee
  } do
    assert [c] = Claims.list_accessible_corporates(user, :corporate)
    assert c.corporate_id == corporate.corporate_id

    assert [p] = Claims.list_accessible_policies(user, :corporate)
    assert p.id == policy.id

    assert [%TrnMappingLiveEmployee{employee_code: "EMP-CL-01"}] =
             Claims.list_accessible_employee_codes(user, :corporate, policy.id)

    assert [%TrnMappingLiveEmployee{employee_name: "Bob Claims"}] =
             Claims.list_patient_options(policy.id, employee.employee_code)

    assert %TrnMappingLiveEmployee{employee_name: "Bob Claims"} =
             Claims.get_policy_employee(policy.id, employee.employee_code, "Bob Claims")
  end
end
