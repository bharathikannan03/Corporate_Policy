defmodule CorporatePolicyWeb.AddPolicyLiveTest do
  use CorporatePolicyWeb.ConnCase, async: false

  import Phoenix.LiveViewTest

  alias CorporatePolicy.Accounts
  alias CorporatePolicy.Corporates
  alias CorporatePolicy.EscalationMatrices
  alias CorporatePolicy.Policies
  alias CorporatePolicy.Repo

  # ---------------------------------------------------------------------------
  # Shared Setup
  # ---------------------------------------------------------------------------

  setup do
    {:ok, user} =
      Accounts.create_user(%{
        first_name: "Admin",
        last_name: "Test",
        email_address: "admin_wizard_test@example.com",
        password: "admin@123",
        status: 1
      })

    {:ok, corporate} =
      Corporates.create_corporate(%{
        "corporate_name" => "Wizard Corp",
        "corporate_address" => "123 Test Street",
        "pincode" => "560001",
        "city" => "Bengaluru",
        "state" => "Karnataka",
        "pan_number" => "ABCWZ1234A",
        "corporate_status" => 1
      })

    # Fetch/create master data needed for policy creation
    lob = List.first(Policies.list_line_of_businesses())
    insurer = List.first(Policies.list_insurers())

    gmc_pt =
      case Repo.get_by(Policies.PolicyType, policy_type_value: "GMC") do
        nil ->
          %Policies.PolicyType{}
          |> Policies.PolicyType.changeset(%{
            policy_type_value: "GMC",
            display_id: 1,
            status: 1,
            ref_md_line_of_businesses_id: (lob && lob.id) || 1
          })
          |> Repo.insert!()

        existing ->
          existing
      end

    today = Date.utc_today()

    # Create an escalation matrix contact for Step 5 tests
    {:ok, em_contact} =
      EscalationMatrices.create_escalation_matrix(%{
        fullname: "Jane Escalation",
        mobile_number: "9876543210",
        email_id: "jane@example.com",
        type_id: 1,
        type: "Broker"
      })

    family_def = List.first(Policies.list_family_definitions())
    tpa = List.first(Policies.list_tpas())

    {:ok,
     user: user,
     corporate: corporate,
     lob: lob,
     insurer: insurer,
     gmc_pt: gmc_pt,
     em_contact: em_contact,
     family_def: family_def,
     tpa: tpa,
     today: today}
  end

  # Helper: build a policy in the DB and return it.
  # Includes family_definition and TPA required for Health/GMC policies.
  defp create_test_policy(corporate, lob, gmc_pt, insurer, today, opts \\ []) do
    family_def = Keyword.get(opts, :family_def, List.first(Policies.list_family_definitions()))
    tpa = Keyword.get(opts, :tpa, List.first(Policies.list_tpas()))

    {:ok, policy} =
      Policies.create_policy(%{
        "ref_corporate_id" => corporate.corporate_id,
        "corporate_name" => corporate.corporate_name,
        "ref_md_line_of_businesses_id" => (lob && lob.id) || 1,
        "line_of_business" => (lob && lob.line_of_business_value) || "Health",
        "ref_md_policy_types_id" => gmc_pt.id,
        "policy_type" => gmc_pt.policy_type_value,
        "ref_select_insurer_id" => (insurer && insurer.id) || 1,
        "select_insurer" => (insurer && insurer.name) || "Test Insurer",
        "ref_md_family_definitions_id" => (family_def && family_def.id) || 1,
        "family_definition" => (family_def && family_def.name) || "Self + Spouse + Children",
        "ref_tpa_id" => tpa && tpa.id,
        "select_tpa" => (tpa && tpa.name) || "Internal TPA",
        "policy_number" => "WIZARD-TEST-#{System.unique_integer([:positive])}",
        "policy_start_date" => Date.to_iso8601(today),
        "policy_end_date" => Date.to_iso8601(Date.add(today, 364)),
        "have_policy_number" => "1",
        "claim_submission_visibility" => "0",
        "ref_intimate_claim_visibilities_id" => "1"
      })

    policy
  end

  # ---------------------------------------------------------------------------
  # Step 1 — Policy Details (create & save to DB)
  # ---------------------------------------------------------------------------

  describe "Step 1 – Policy Details" do
    test "renders the add policy wizard on step 1", %{conn: conn, user: user} do
      conn = conn |> init_test_session(current_user_id: user.id)
      {:ok, _view, html} = live(conn, ~p"/admin/policy-details/add")

      assert html =~ "Add Policy"
      assert html =~ "Policy Details"
      assert html =~ "Corporate Name"
      assert html =~ "Policy start date"
    end

    test "submitting step 1 creates a policy in the database", %{
      conn: conn,
      user: user,
      corporate: corporate,
      lob: lob,
      gmc_pt: gmc_pt,
      insurer: insurer,
      family_def: family_def,
      tpa: tpa,
      today: today
    } do
      conn = conn |> init_test_session(current_user_id: user.id)
      {:ok, view, _html} = live(conn, ~p"/admin/policy-details/add")

      # Count policies before
      policies_before = Policies.list_policies()

      # Use element() |> render_submit() to route through the form's phx-target
      # (which points to the Step1 LiveComponent, not the parent LiveView).
      # This also bypasses form/3 select option validation.
      element(view, "#add-policy-form")
      |> render_submit(%{
        "ref_corporate_id" => corporate.corporate_id,
        "corporate_name" => corporate.corporate_name,
        "ref_md_line_of_businesses_id" => to_string((lob && lob.id) || 1),
        "line_of_business" => (lob && lob.line_of_business_value) || "Health",
        "ref_md_policy_types_id" => to_string(gmc_pt.id),
        "policy_type" => gmc_pt.policy_type_value,
        "ref_select_insurer_id" => to_string((insurer && insurer.id) || 1),
        "select_insurer" => (insurer && insurer.name) || "Test Insurer",
        "ref_md_family_definitions_id" => to_string((family_def && family_def.id) || 1),
        "family_definition" => (family_def && family_def.name) || "Self + Spouse + Children",
        "ref_tpa_id" => to_string((tpa && tpa.id) || ""),
        "select_tpa" => (tpa && tpa.name) || "",
        "policy_number" => "TEST-S1-#{System.unique_integer([:positive])}",
        "policy_start_date" => Date.to_iso8601(today),
        "policy_end_date" => Date.to_iso8601(Date.add(today, 364)),
        "have_policy_number" => "1",
        "claim_submission_visibility" => "0",
        "ref_intimate_claim_visibilities_id" => "1"
      })

      # Policy is in the database (primary assertion — redirect depends on step1 component logic)
      policies_after = Policies.list_policies()
      assert length(policies_after) == length(policies_before) + 1
    end

    test "editing step 1 updates the policy in the database", %{
      conn: conn,
      user: user,
      corporate: corporate,
      lob: lob,
      gmc_pt: gmc_pt,
      insurer: insurer,
      today: today
    } do
      policy = create_test_policy(corporate, lob, gmc_pt, insurer, today)

      conn = conn |> init_test_session(current_user_id: user.id)
      {:ok, view, html} = live(conn, ~p"/admin/policy-details/#{policy.id}/edit")

      assert html =~ "Edit Policy"
      assert html =~ policy.policy_number

      new_policy_number = "EDITED-POL-#{System.unique_integer([:positive])}"

      element(view, "#add-policy-form")
      |> render_submit(%{
        "ref_corporate_id" => corporate.corporate_id,
        "corporate_name" => corporate.corporate_name,
        "ref_md_line_of_businesses_id" => to_string((lob && lob.id) || 1),
        "line_of_business" => (lob && lob.line_of_business_value) || "Health",
        "ref_md_policy_types_id" => to_string(gmc_pt.id),
        "policy_type" => gmc_pt.policy_type_value,
        "ref_select_insurer_id" => to_string((insurer && insurer.id) || 1),
        "select_insurer" => (insurer && insurer.name) || "Test Insurer",
        "policy_number" => new_policy_number,
        "policy_start_date" => Date.to_iso8601(today),
        "policy_end_date" => Date.to_iso8601(Date.add(today, 364)),
        "have_policy_number" => "1",
        "claim_submission_visibility" => "0",
        "ref_intimate_claim_visibilities_id" => "1"
      })

      # Assert that the policy's policy number is updated in the database
      updated_policy = Policies.get_policy!(policy.id)
      assert updated_policy.policy_number == new_policy_number
    end
  end

  # ---------------------------------------------------------------------------
  # Step 2 — Policy Features (per-feature DB save)
  # ---------------------------------------------------------------------------

  describe "Step 2 – Policy Features" do
    test "renders step 2 for an existing policy and shows Add New button", %{
      conn: conn,
      user: user,
      corporate: corporate,
      lob: lob,
      gmc_pt: gmc_pt,
      insurer: insurer,
      today: today
    } do
      policy = create_test_policy(corporate, lob, gmc_pt, insurer, today)
      conn = conn |> init_test_session(current_user_id: user.id)

      {:ok, _view, html} =
        live(conn, ~p"/admin/policy-details/#{policy.id}/edit?step=step2")

      assert html =~ "Policy Features"
      assert html =~ "Add New"
    end

    test "clicking Next on step 2 transitions to step 3", %{
      conn: conn,
      user: user,
      corporate: corporate,
      lob: lob,
      gmc_pt: gmc_pt,
      insurer: insurer,
      today: today
    } do
      policy = create_test_policy(corporate, lob, gmc_pt, insurer, today)
      conn = conn |> init_test_session(current_user_id: user.id)

      {:ok, view, _html} =
        live(conn, ~p"/admin/policy-details/#{policy.id}/edit?step=step2")

      html =
        view
        |> element("button[phx-click='next_step']")
        |> render_click()

      # After next_step, step 3 content renders
      assert html =~ "Sum Insured"
    end
  end

  # ---------------------------------------------------------------------------
  # Step 3 — Sum Insured (immediate DB persistence)
  # ---------------------------------------------------------------------------

  describe "Step 3 – Sum Insured (immediate DB writes)" do
    test "renders step 3 with Add & Save button", %{
      conn: conn,
      user: user,
      corporate: corporate,
      lob: lob,
      gmc_pt: gmc_pt,
      insurer: insurer,
      today: today
    } do
      policy = create_test_policy(corporate, lob, gmc_pt, insurer, today)
      conn = conn |> init_test_session(current_user_id: user.id)

      {:ok, _view, html} =
        live(conn, ~p"/admin/policy-details/#{policy.id}/edit?step=step3")

      assert html =~ "Sum Insured"
      assert html =~ "Add &amp; Save"
      assert html =~ "saved to the database immediately"
    end

    test "clicking Add & Save persists sum insured to DB immediately", %{
      conn: conn,
      user: user,
      corporate: corporate,
      lob: lob,
      gmc_pt: gmc_pt,
      insurer: insurer,
      today: today
    } do
      policy = create_test_policy(corporate, lob, gmc_pt, insurer, today)
      conn = conn |> init_test_session(current_user_id: user.id)

      {:ok, view, _html} =
        live(conn, ~p"/admin/policy-details/#{policy.id}/edit?step=step3")

      # Use element() |> render_submit() to route through the form's phx-target
      # (the form targets the Step3 LiveComponent, not the parent LiveView).
      # This also bypasses select option validation on policy_feature_identifier.
      element(view, "#add-sum-insured-form")
      |> render_submit(%{
        "sum_insured" => "500000",
        "policy_feature_identifier" => "GMC"
      })

      # DB should have the entry immediately
      db_records = Policies.list_sum_insureds_for_policy(policy.id)
      assert length(db_records) == 1
      assert hd(db_records).sum_insured == 500_000
      assert hd(db_records).policy_feature_identifier == "GMC"
    end

    test "sum insured data survives page refresh (persisted in DB)", %{
      conn: conn,
      user: user,
      corporate: corporate,
      lob: lob,
      gmc_pt: gmc_pt,
      insurer: insurer,
      today: today
    } do
      policy = create_test_policy(corporate, lob, gmc_pt, insurer, today)
      conn = conn |> init_test_session(current_user_id: user.id)

      # Insert via context directly (no form helper needed)
      {:ok, _} =
        Policies.create_sum_insured(
          policy.id,
          %{"sum_insured" => "300000", "policy_feature_identifier" => "GMC"},
          user.id
        )

      # Simulate refresh by mounting a brand-new LiveView process
      {:ok, _view2, html2} =
        live(conn, ~p"/admin/policy-details/#{policy.id}/edit?step=step3")

      # Data still present after "refresh"
      assert html2 =~ "300000"
    end

    test "remove_sum_insured soft-deletes the DB record", %{
      conn: conn,
      user: user,
      corporate: corporate,
      lob: lob,
      gmc_pt: gmc_pt,
      insurer: insurer,
      today: today
    } do
      policy = create_test_policy(corporate, lob, gmc_pt, insurer, today)

      # Pre-insert a sum insured directly
      {:ok, record} =
        Policies.create_sum_insured(
          policy.id,
          %{"sum_insured" => "200000", "policy_feature_identifier" => "GMC"},
          user.id
        )

      conn = conn |> init_test_session(current_user_id: user.id)

      {:ok, view, _html} =
        live(conn, ~p"/admin/policy-details/#{policy.id}/edit?step=step3")

      # Click remove
      view
      |> element("button[phx-click='remove_sum_insured'][phx-value-id='#{record.id}']")
      |> render_click()

      # DB record should be soft-deleted (not in active list)
      remaining = Policies.list_sum_insureds_for_policy(policy.id)
      assert Enum.all?(remaining, &(&1.id != record.id))
    end

    test "Save & Next with no entries shows error", %{
      conn: conn,
      user: user,
      corporate: corporate,
      lob: lob,
      gmc_pt: gmc_pt,
      insurer: insurer,
      today: today
    } do
      policy = create_test_policy(corporate, lob, gmc_pt, insurer, today)
      conn = conn |> init_test_session(current_user_id: user.id)

      {:ok, view, _html} =
        live(conn, ~p"/admin/policy-details/#{policy.id}/edit?step=step3")

      view
      |> element("button[phx-click='save_step3']")
      |> render_click()

      # Flash is sent to parent LiveView — check via render(view)
      html = render(view)
      assert html =~ "Please add at least one Sum Insured"
    end

    test "Save & Next with entries navigates to step 4", %{
      conn: conn,
      user: user,
      corporate: corporate,
      lob: lob,
      gmc_pt: gmc_pt,
      insurer: insurer,
      today: today
    } do
      policy = create_test_policy(corporate, lob, gmc_pt, insurer, today)

      # Pre-insert a sum insured
      Policies.create_sum_insured(
        policy.id,
        %{"sum_insured" => "500000", "policy_feature_identifier" => "GMC"},
        user.id
      )

      conn = conn |> init_test_session(current_user_id: user.id)

      {:ok, view, _html} =
        live(conn, ~p"/admin/policy-details/#{policy.id}/edit?step=step3")

      html =
        view
        |> element("button[phx-click='save_step3']")
        |> render_click()

      # Step 4 (Data Upload) content should now be visible
      assert html =~ "Data Upload" or html =~ "Upload"
    end
  end

  # ---------------------------------------------------------------------------
  # Step 4 — Data Upload (navigate only; actual file upload tested separately)
  # ---------------------------------------------------------------------------

  describe "Step 4 – Data Upload" do
    test "renders step 4 with upload form and Save & Next button", %{
      conn: conn,
      user: user,
      corporate: corporate,
      lob: lob,
      gmc_pt: gmc_pt,
      insurer: insurer,
      today: today
    } do
      policy = create_test_policy(corporate, lob, gmc_pt, insurer, today)
      conn = conn |> init_test_session(current_user_id: user.id)

      {:ok, _view, html} =
        live(conn, ~p"/admin/policy-details/#{policy.id}/edit?step=step4")

      assert html =~ "Upload"
      # In edit mode the button label is "Save Changes" (not "Save & Next")
      assert html =~ "Save Changes" or html =~ "save_step4"
    end

    test "Save & Next on step 4 navigates to step 5", %{
      conn: conn,
      user: user,
      corporate: corporate,
      lob: lob,
      gmc_pt: gmc_pt,
      insurer: insurer,
      today: today
    } do
      policy = create_test_policy(corporate, lob, gmc_pt, insurer, today)
      conn = conn |> init_test_session(current_user_id: user.id)

      {:ok, view, _html} =
        live(conn, ~p"/admin/policy-details/#{policy.id}/edit?step=step4")

      html =
        view
        |> element("button[phx-click='save_step4']")
        |> render_click()

      # Step 5 content should now be visible
      assert html =~ "Escalation"
    end
  end

  # ---------------------------------------------------------------------------
  # Step 5 — Escalation Matrix (immediate DB persistence)
  # ---------------------------------------------------------------------------

  describe "Step 5 – Escalation Matrix (immediate DB writes)" do
    test "renders step 5 with Assign & Save button", %{
      conn: conn,
      user: user,
      corporate: corporate,
      lob: lob,
      gmc_pt: gmc_pt,
      insurer: insurer,
      today: today
    } do
      policy = create_test_policy(corporate, lob, gmc_pt, insurer, today)
      conn = conn |> init_test_session(current_user_id: user.id)

      {:ok, _view, html} =
        live(conn, ~p"/admin/policy-details/#{policy.id}/edit?step=step5")

      assert html =~ "Escalation"
      assert html =~ "Assign &amp; Save"
      assert html =~ "saved to the database immediately"
    end

    test "clicking Assign & Save persists escalation row to DB immediately", %{
      conn: conn,
      user: user,
      corporate: corporate,
      lob: lob,
      gmc_pt: gmc_pt,
      insurer: insurer,
      em_contact: em_contact,
      today: today
    } do
      policy = create_test_policy(corporate, lob, gmc_pt, insurer, today)
      conn = conn |> init_test_session(current_user_id: user.id)

      {:ok, view, _html} =
        live(conn, ~p"/admin/policy-details/#{policy.id}/edit?step=step5")

      view
      |> form("#add-escalation-form", %{
        "escalation_level_id" => "1",
        "user_id" => to_string(em_contact.id)
      })
      |> render_submit()

      # DB should have the entry immediately
      db_records = Policies.list_escalation_matrices_for_policy(policy.id)
      assert length(db_records) == 1
      assert hd(db_records).escalation_level_id == 1
      assert hd(db_records).user_id == em_contact.id
    end

    test "escalation data survives page refresh (persisted in DB)", %{
      conn: conn,
      user: user,
      corporate: corporate,
      lob: lob,
      gmc_pt: gmc_pt,
      insurer: insurer,
      em_contact: em_contact,
      today: today
    } do
      policy = create_test_policy(corporate, lob, gmc_pt, insurer, today)
      conn = conn |> init_test_session(current_user_id: user.id)

      {:ok, view, _html} =
        live(conn, ~p"/admin/policy-details/#{policy.id}/edit?step=step5")

      view
      |> form("#add-escalation-form", %{
        "escalation_level_id" => "1",
        "user_id" => to_string(em_contact.id)
      })
      |> render_submit()

      # Simulate refresh
      {:ok, _view2, html2} =
        live(conn, ~p"/admin/policy-details/#{policy.id}/edit?step=step5")

      assert html2 =~ em_contact.fullname
    end

    test "remove escalation soft-deletes DB record", %{
      conn: conn,
      user: user,
      corporate: corporate,
      lob: lob,
      gmc_pt: gmc_pt,
      insurer: insurer,
      em_contact: em_contact,
      today: today
    } do
      policy = create_test_policy(corporate, lob, gmc_pt, insurer, today)

      # Pre-insert directly via context
      {:ok, _} =
        Policies.create_policy_escalation_matrix(
          policy.id,
          %{
            escalation_level_id: 1,
            level: "Level 1 (First Contact)",
            user_id: em_contact.id,
            user_fullname: em_contact.fullname
          },
          user.id
        )

      [record] = Policies.list_escalation_matrices_for_policy(policy.id)

      conn = conn |> init_test_session(current_user_id: user.id)

      {:ok, view, _html} =
        live(conn, ~p"/admin/policy-details/#{policy.id}/edit?step=step5")

      view
      |> element("button[phx-click='remove_matrix'][phx-value-id='#{record.id}']")
      |> render_click()

      remaining = Policies.list_escalation_matrices_for_policy(policy.id)
      assert Enum.all?(remaining, &(&1.id != record.id))
    end

    test "Save & Next with no entries shows error", %{
      conn: conn,
      user: user,
      corporate: corporate,
      lob: lob,
      gmc_pt: gmc_pt,
      insurer: insurer,
      today: today
    } do
      policy = create_test_policy(corporate, lob, gmc_pt, insurer, today)
      conn = conn |> init_test_session(current_user_id: user.id)

      {:ok, view, _html} =
        live(conn, ~p"/admin/policy-details/#{policy.id}/edit?step=step5")

      view
      |> element("button[phx-click='save_step5']")
      |> render_click()

      # Flash is sent to parent LiveView — check via render(view)
      html = render(view)
      assert html =~ "Please configure at least one Escalation"
    end

    test "duplicate escalation level rejected", %{
      conn: conn,
      user: user,
      corporate: corporate,
      lob: lob,
      gmc_pt: gmc_pt,
      insurer: insurer,
      em_contact: em_contact,
      today: today
    } do
      policy = create_test_policy(corporate, lob, gmc_pt, insurer, today)

      # Pre-insert Level 1
      Policies.create_policy_escalation_matrix(
        policy.id,
        %{
          escalation_level_id: 1,
          level: "Level 1 (First Contact)",
          user_id: em_contact.id,
          user_fullname: em_contact.fullname
        },
        user.id
      )

      conn = conn |> init_test_session(current_user_id: user.id)

      {:ok, view, _html} =
        live(conn, ~p"/admin/policy-details/#{policy.id}/edit?step=step5")

      # Try to assign Level 1 again — form() helper validates selects which are
      # already populated (level 1 and em_contact are valid options in the form).
      view
      |> form("#add-escalation-form", %{
        "escalation_level_id" => "1",
        "user_id" => to_string(em_contact.id)
      })
      |> render_submit()

      # Flash is sent to parent LiveView — check via render(view)
      html = render(view)
      assert html =~ "already been assigned"
    end
  end

  # ---------------------------------------------------------------------------
  # Step 6 — Documents (already per-upload DB save)
  # ---------------------------------------------------------------------------

  describe "Step 6 – Documents" do
    test "renders step 6 with document upload form", %{
      conn: conn,
      user: user,
      corporate: corporate,
      lob: lob,
      gmc_pt: gmc_pt,
      insurer: insurer,
      today: today
    } do
      policy = create_test_policy(corporate, lob, gmc_pt, insurer, today)
      conn = conn |> init_test_session(current_user_id: user.id)

      {:ok, _view, html} =
        live(conn, ~p"/admin/policy-details/#{policy.id}/edit?step=step6")

      assert html =~ "Document"
      assert html =~ "Attach Documents"
      # In edit mode the button label is "Save Changes" (not "Save & Next")
      assert html =~ "Save Changes" or html =~ "save_step6"
    end

    test "Save & Next on step 6 navigates to step 7", %{
      conn: conn,
      user: user,
      corporate: corporate,
      lob: lob,
      gmc_pt: gmc_pt,
      insurer: insurer,
      today: today
    } do
      policy = create_test_policy(corporate, lob, gmc_pt, insurer, today)
      conn = conn |> init_test_session(current_user_id: user.id)

      {:ok, view, _html} =
        live(conn, ~p"/admin/policy-details/#{policy.id}/edit?step=step6")

      html =
        view
        |> element("button[phx-click='save_step6']")
        |> render_click()

      # Step 7 content should now be visible
      assert html =~ "CD Statement" or html =~ "Complete Policy"
    end
  end

  # ---------------------------------------------------------------------------
  # Step 7 — CD Statements (view-only; navigate to listing on Complete)
  # ---------------------------------------------------------------------------

  describe "Step 7 – CD Statements" do
    test "renders step 7 with CD statement table and Complete Policy button", %{
      conn: conn,
      user: user,
      corporate: corporate,
      lob: lob,
      gmc_pt: gmc_pt,
      insurer: insurer,
      today: today
    } do
      policy = create_test_policy(corporate, lob, gmc_pt, insurer, today)
      conn = conn |> init_test_session(current_user_id: user.id)

      {:ok, _view, html} =
        live(conn, ~p"/admin/policy-details/#{policy.id}/edit?step=step7")

      assert html =~ "CD Statement" or html =~ "Policy Number"
      # In edit mode the complete button shows "Save Changes"
      assert html =~ "Save Changes" or html =~ "save_step7"
    end

    test "Complete Policy button redirects to policy listing", %{
      conn: conn,
      user: user,
      corporate: corporate,
      lob: lob,
      gmc_pt: gmc_pt,
      insurer: insurer,
      today: today
    } do
      policy = create_test_policy(corporate, lob, gmc_pt, insurer, today)
      conn = conn |> init_test_session(current_user_id: user.id)

      {:ok, view, _html} =
        live(conn, ~p"/admin/policy-details/#{policy.id}/edit?step=step7")

      view
      |> element("button[phx-click='save_step7']")
      |> render_click()

      assert_redirect(view, ~p"/admin/policy-details")
    end
  end
end
