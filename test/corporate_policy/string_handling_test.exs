defmodule CorporatePolicy.StringHandlingTest do
  use CorporatePolicy.DataCase, async: true

  alias CorporatePolicy.Claims
  alias CorporatePolicy.Claims.MasterClaimSubmission

  alias CorporatePolicy.Corporates.Corporate

  alias CorporatePolicy.Policies.{
    FinancialYear,
    Insurer,
    LineOfBusiness,
    Policy,
    PolicyType,
    TrnMappingLiveEmployee
  }

  alias CorporatePolicy.Repo

  setup do
    user =
      Repo.insert!(%CorporatePolicy.Accounts.User{
        first_name: "Case",
        last_name: "Tester",
        email_address: "string-handling@example.com",
        password: "password123",
        status: 1
      })

    corporate =
      Repo.insert!(%Corporate{
        corporate_name: "Case Corp",
        corporate_address: "123 Test Street",
        status: 1,
        corporate_status: 1
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
        display_id: 1,
        ref_md_line_of_businesses_id: lob.id,
        status: 1
      })

    insurer =
      Repo.insert!(%Insurer{
        name: "Case Insurer",
        ref_md_line_of_businesses_id: lob.id,
        status: 1
      })

    fy =
      Repo.insert!(%FinancialYear{
        year_name: "2026",
        start_date: ~D[2026-04-01],
        end_date: ~D[2027-03-31],
        status: 1
      })

    policy =
      Repo.insert!(%Policy{
        policy_number: "POL-CASE-001",
        corporate_name: corporate.corporate_name,
        ref_corporate_id: corporate.corporate_id,
        ref_md_line_of_businesses_id: lob.id,
        line_of_business: lob.line_of_business_value,
        ref_md_policy_types_id: policy_type.id,
        policy_type: policy_type.policy_type_value,
        ref_select_insurer_id: insurer.id,
        select_insurer: insurer.name,
        ref_fy_year_id: fy.id,
        status: 1,
        created_by: user.id,
        updated_by: user.id
      })

    employee =
      Repo.insert!(%TrnMappingLiveEmployee{
        ref_policy_id: policy.id,
        ref_corporate_id: corporate.corporate_id,
        employee_code: "EMP900",
        employee_name: "John Case",
        relationship: "Employee",
        status: "active",
        source_type: "Inception",
        created_by: user.id,
        updated_by: user.id
      })

    %{
      user: user,
      corporate: corporate,
      policy: policy,
      employee: employee
    }
  end

  test "claim submission lookups are case-insensitive and trimmed", %{policy: policy} do
    employee = Claims.get_policy_employee(policy.id, " emp900 ", "  john case ")

    assert employee
    assert employee.employee_code == "EMP900"

    options = Claims.list_patient_options(policy.id, " emp900 ")
    assert Enum.any?(options, &(&1.employee_name == "John Case"))
  end

  test "claim status and text fields are normalized before save and filter", %{
    user: user,
    policy: policy,
    corporate: corporate
  } do
    attrs = %{
      "ref_corporate_id" => corporate.corporate_id,
      "ref_policy_id" => policy.id,
      "portal_id" => 1,
      "claim_number" => "  CLM-CASE-001  ",
      "employee_code" => "  emp900 ",
      "patient_name" => "  John Case ",
      "estimated_amount" => "5000",
      "claim_reason" => "  Fever  ",
      "claim_type" => "Cashless",
      "hospital_name" => "  City Hospital ",
      "hospital_address" => "  Main Road ",
      "hospitalization_date" => ~D[2026-07-19],
      "discharge_date" => ~D[2026-07-20],
      "city" => "  Mumbai ",
      "state" => "  Maharashtra ",
      "pincode" => " 400001 ",
      "claim_status" => " submitted ",
      "created_by" => user.id,
      "updated_by" => user.id
    }

    claim =
      %MasterClaimSubmission{}
      |> MasterClaimSubmission.create_changeset(attrs)
      |> Repo.insert!()

    assert claim.claim_number == "CLM-CASE-001"
    assert claim.employee_code == "emp900"
    assert claim.patient_name == "John Case"
    assert claim.city == "Mumbai"
    assert claim.claim_status == "Submitted"

    page =
      Claims.list_claims(user, :admin, %{
        "search" => "  clm-case-001 ",
        "status" => " submitted "
      })

    assert Enum.map(page.entries, & &1.id) == [claim.id]
  end
end
