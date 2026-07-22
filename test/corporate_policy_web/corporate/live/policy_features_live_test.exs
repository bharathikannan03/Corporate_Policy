defmodule CorporatePolicyWeb.Corporate.PolicyFeaturesLiveTest do
  use CorporatePolicyWeb.ConnCase, async: false

  import Phoenix.LiveViewTest

  alias CorporatePolicy.Repo
  alias CorporatePolicy.Accounts
  alias CorporatePolicy.Corporates
  alias CorporatePolicy.Policies
  alias CorporatePolicy.Policies.PolicyType
  alias CorporatePolicy.Policies.MasterPolicyFeatureTemplateField

  alias CorporatePolicy.Policies.MappingPolicyFeatureTemplatesCorporatesPolicy
  alias CorporatePolicy.Policies.MasterSumInsured

  setup do
    # Create Corporate
    {:ok, corporate} =
      Corporates.create_corporate(%{
        "corporate_name" => "PURPLE TALK INDIA PRIVATE LIMITED",
        "corporate_address" => "123 Tech Park",
        "pincode" => "500081",
        "city" => "Hyderabad",
        "state" => "Telangana",
        "pan_number" => "ABCDE1234F",
        "corporate_status" => 1
      })

    # Create User
    {:ok, user} =
      Accounts.create_user(%{
        first_name: "Richie",
        last_name: "Joseph",
        email_address: "richie.joseph@purpletalk.com",
        password: "password123",
        ref_corporate_id: corporate.corporate_id,
        department_id: 4
      })

    # Ensure GMC policy type
    {:ok, gmc_pt} =
      case Repo.get_by(PolicyType, policy_type_value: "GMC") do
        nil ->
          %PolicyType{}
          |> PolicyType.changeset(%{
            policy_type_value: "GMC",
            display_id: 1,
            status: 1,
            ref_md_line_of_businesses_id: 1
          })
          |> Repo.insert()

        existing ->
          {:ok, existing}
      end

    lob = List.first(Policies.list_line_of_businesses())
    insurer = List.first(Policies.list_insurers())
    tpa = List.first(Policies.list_tpas())
    family_def = List.first(Policies.list_family_definitions())
    fy = List.first(Policies.list_financial_years())

    # Create active policy
    {:ok, active_policy} =
      Policies.create_policy(%{
        "ref_corporate_id" => corporate.corporate_id,
        "corporate_name" => corporate.corporate_name,
        "ref_md_line_of_businesses_id" => (lob && lob.id) || 1,
        "line_of_business" => (lob && lob.line_of_business_value) || "Health",
        "ref_md_policy_types_id" => gmc_pt.id,
        "policy_type" => "GMC",
        "ref_select_insurer_id" => (insurer && insurer.id) || 1,
        "select_insurer" => "Aditya Birla Health Insurance Co. Limited",
        "ref_tpa_id" => tpa && tpa.id,
        "select_tpa" => "Internal TPA",
        "ref_md_family_definitions_id" => (family_def && family_def.id) || 1,
        "policy_number" => "2-81-25-00003017-000",
        "policy_start_date" => "2025-07-25",
        "policy_end_date" => "2026-07-24",
        "ref_fy_year_id" => fy && fy.id,
        "status" => 1,
        "have_policy_number" => 1
      })

    # Seed master fields if needed
    parent_field =
      case Repo.get_by(MasterPolicyFeatureTemplateField,
             name: "Feature Identifier",
             template_id: 1
           ) do
        nil ->
          %MasterPolicyFeatureTemplateField{}
          |> MasterPolicyFeatureTemplateField.changeset(%{
            id: 9991,
            name: "Feature Identifier",
            placeholder: "Feature Identifier",
            field_type_id: 1,
            template_id: 1,
            status: 0,
            is_mandatory: true
          })
          |> Repo.insert!()

        existing ->
          existing
      end

    room_field =
      case Repo.get_by(MasterPolicyFeatureTemplateField, name: "Room Rent Limit", template_id: 1) do
        nil ->
          %MasterPolicyFeatureTemplateField{}
          |> MasterPolicyFeatureTemplateField.changeset(%{
            id: 9992,
            name: "Room Rent Limit",
            placeholder: "Room Rent Limit",
            field_type_id: 1,
            template_id: 1,
            status: 0,
            is_mandatory: true
          })
          |> Repo.insert!()

        existing ->
          existing
      end

    # Create a mapped feature group
    parent_mapping =
      %MappingPolicyFeatureTemplatesCorporatesPolicy{}
      |> MappingPolicyFeatureTemplatesCorporatesPolicy.changeset(%{
        ref_policy_feature_template_field_name: parent_field.name,
        policy_feature_template_field_value: "GMC",
        ref_template_id: 1,
        ref_coporate_id: corporate.corporate_id,
        ref_policy_id: active_policy.id,
        ref_policy_feature_template_field_id: parent_field.id,
        ref_policy_feature_template_field_type_id: parent_field.field_type_id,
        policy_feature_template_field_visibility_role_ids: "1,2,3",
        status: 1
      })
      |> Repo.insert!()

    parent_mapping
    |> MappingPolicyFeatureTemplatesCorporatesPolicy.changeset(%{
      ref_policyidentifier_id: parent_mapping.policy_feature_template_field_value_id
    })
    |> Repo.update!()

    # Create room rent limit mapping value
    room_mapping =
      %MappingPolicyFeatureTemplatesCorporatesPolicy{}
      |> MappingPolicyFeatureTemplatesCorporatesPolicy.changeset(%{
        ref_policy_feature_template_field_name: room_field.name,
        policy_feature_template_field_value: "1% SUM INSURED PER DAY",
        ref_template_id: 1,
        ref_coporate_id: corporate.corporate_id,
        ref_policy_id: active_policy.id,
        ref_policy_feature_template_field_id: room_field.id,
        ref_policy_feature_template_field_type_id: room_field.field_type_id,
        policy_feature_template_field_visibility_role_ids: "1,2,3",
        ref_policyidentifier_id: parent_mapping.policy_feature_template_field_value_id,
        status: 1
      })
      |> Repo.insert!()

    # Create MasterSumInsured
    {:ok, sum_insured} =
      %MasterSumInsured{}
      |> MasterSumInsured.changeset(%{
        sum_insured: 300_000,
        policy_feature_identifier: "GMC",
        template_id: 1,
        policy_id: active_policy.id,
        feature_identifier_id: parent_mapping.policy_feature_template_field_value_id,
        status: 1
      })
      |> Repo.insert()

    %{
      user: user,
      corporate: corporate,
      active_policy: active_policy,
      sum_insured: sum_insured,
      room_mapping: room_mapping
    }
  end

  test "mounts corporate policy features and renders the policy list", %{
    conn: conn,
    user: user,
    corporate: corporate,
    active_policy: active_policy
  } do
    conn = conn |> init_test_session(current_user_id: user.id)

    {:ok, _view, html} = live(conn, ~p"/corporate/policy-features")

    assert html =~ corporate.corporate_name
    assert html =~ active_policy.policy_number
    assert html =~ "300000"
    assert html =~ "Policy Benefit"
  end

  test "clicks Policy Benefit button and opens features details modal", %{
    conn: conn,
    user: user,
    active_policy: active_policy,
    sum_insured: _sum_insured
  } do
    conn = conn |> init_test_session(current_user_id: user.id)

    {:ok, view, _html} = live(conn, ~p"/corporate/policy-features")

    # Render benefit click event
    html =
      view
      |> element("button", "Policy Benefit")
      |> render_click()

    assert html =~ "Policy Details - #{active_policy.policy_number}"
    assert html =~ "Sum Insured: ₹300000"
    assert html =~ "Room Rent Limit"
    assert html =~ "1% SUM INSURED PER DAY"

    # Close modal
    html =
      view
      |> element("button", "Close")
      |> render_click()

    refute html =~ "Room Rent Limit"
    refute html =~ "1% SUM INSURED PER DAY"
  end
end
