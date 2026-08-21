defmodule CorporatePolicy.DataCase do
  @moduledoc """
  This module defines the setup for tests requiring
  access to the application's data layer.

  You may define functions here to be used as helpers in
  your tests.

  Finally, if the test case interacts with the database,
  we enable the SQL sandbox, so changes done to the database
  are reverted at the end of every test. If you are using
  PostgreSQL, you can even run database tests asynchronously
  by setting `use CorporatePolicy.DataCase, async: true`, although
  this option is not recommended for other databases.
  """

  use ExUnit.CaseTemplate

  using do
    quote do
      alias CorporatePolicy.Repo

      import Ecto
      import Ecto.Changeset
      import Ecto.Query
      import CorporatePolicy.DataCase
    end
  end

  setup tags do
    CorporatePolicy.DataCase.setup_sandbox(tags)
    CorporatePolicy.DataCase.seed_roles_and_sequence()

    excluded_modules = [
      CorporatePolicyWeb.Admin.ClaimSubmissionLiveTest,
      CorporatePolicyWeb.Admin.CdStatementUploadLiveTest,
      CorporatePolicyWeb.Admin.CdAccountsLiveTest,
      CorporatePolicyWeb.Corporate.CashlessHospitalsLiveTest,
      CorporatePolicyWeb.UploadControllerTest,
      CorporatePolicy.StringHandlingTest,
      CorporatePolicy.PoliciesTest,
      CorporatePolicy.DataUploadServiceTest,
      CorporatePolicy.ClaimsTest,
      CorporatePolicy.CdStatementsTest,
      CorporatePolicy.CashlessHospitalsTest
    ]

    unless tags.module in excluded_modules do
      CorporatePolicy.DataCase.seed_lookups()
    end

    :ok
  end

  @doc """
  Seeds roles and sets the sequence to avoid unique constraint conflicts.
  """
  def seed_roles_and_sequence do
    now = DateTime.utc_now() |> DateTime.truncate(:microsecond)

    roles = [
      %{role_id: 1, role: "All", is_visible: 1, status: 1, created_at: now, updated_at: now},
      %{
        role_id: 2,
        role: "superadmin",
        is_visible: 1,
        status: 1,
        created_at: now,
        updated_at: now
      },
      %{
        role_id: 3,
        role: "broker_limited",
        is_visible: 1,
        status: 1,
        created_at: now,
        updated_at: now
      },
      %{role_id: 4, role: "none", is_visible: 1, status: 1, created_at: now, updated_at: now},
      %{role_id: 9, role: "broker", is_visible: 1, status: 1, created_at: now, updated_at: now},
      %{
        role_id: 15,
        role: "restricted",
        is_visible: 1,
        status: 1,
        created_at: now,
        updated_at: now
      }
    ]

    CorporatePolicy.Repo.insert_all(CorporatePolicy.Corporates.MdVisibilityRoleFeature, roles,
      on_conflict: :nothing
    )

    # Advance sequence to prevent conflicts with the seeded role_id 15
    Ecto.Adapters.SQL.query!(
      CorporatePolicy.Repo,
      "SELECT setval('md_visibility_role_id_feature_tmps_role_id_seq', 20)"
    )
  end

  @doc """
  Seeds lookup records needed by tests to satisfy database constraints.
  """
  def seed_lookups do
    lob =
      case CorporatePolicy.Repo.get_by(CorporatePolicy.Policies.LineOfBusiness,
             line_of_business_value: "Health"
           ) do
        nil ->
          CorporatePolicy.Repo.insert!(%CorporatePolicy.Policies.LineOfBusiness{
            line_of_business_value: "Health",
            display_id: 1,
            status: 1
          })

        record ->
          record
      end

    _insurer =
      case CorporatePolicy.Repo.get_by(CorporatePolicy.Policies.Insurer,
             name: "Aditya Birla Health Insurance Co. Limited"
           ) do
        nil ->
          CorporatePolicy.Repo.insert!(%CorporatePolicy.Policies.Insurer{
            name: "Aditya Birla Health Insurance Co. Limited",
            status: 1
          })

        record ->
          record
      end

    _family_def =
      case CorporatePolicy.Repo.get_by(CorporatePolicy.Policies.FamilyDefinition,
             name: "Self + Spouse + Children"
           ) do
        nil ->
          CorporatePolicy.Repo.insert!(%CorporatePolicy.Policies.FamilyDefinition{
            name: "Self + Spouse + Children",
            display_id: 1,
            status: 1
          })

        record ->
          record
      end

    _tpa =
      case CorporatePolicy.Repo.get_by(CorporatePolicy.Policies.Tpa, name: "Internal TPA") do
        nil ->
          CorporatePolicy.Repo.insert!(%CorporatePolicy.Policies.Tpa{
            name: "Internal TPA",
            status: 1
          })

        record ->
          record
      end

    _gmc_pt =
      case CorporatePolicy.Repo.get_by(CorporatePolicy.Policies.PolicyType,
             policy_type_value: "GMC"
           ) do
        nil ->
          %CorporatePolicy.Policies.PolicyType{}
          |> CorporatePolicy.Policies.PolicyType.changeset(%{
            policy_type_value: "GMC",
            display_id: 1,
            status: 1,
            ref_md_line_of_businesses_id: lob.id
          })
          |> CorporatePolicy.Repo.insert!()

        record ->
          record
      end

    # Seed escalation level lookup data
    now_naive = NaiveDateTime.utc_now() |> NaiveDateTime.truncate(:second)

    md_matrices = [
      %{id: 1, level: "Level 1", status: 1, inserted_at: now_naive, updated_at: now_naive},
      %{id: 2, level: "Level 2", status: 1, inserted_at: now_naive, updated_at: now_naive},
      %{id: 3, level: "Level 3", status: 1, inserted_at: now_naive, updated_at: now_naive},
      %{id: 4, level: "Level 4", status: 1, inserted_at: now_naive, updated_at: now_naive},
      %{id: 5, level: "Level 5", status: 1, inserted_at: now_naive, updated_at: now_naive}
    ]

    CorporatePolicy.Repo.insert_all("md_escalation_matrices", md_matrices, on_conflict: :nothing)

    # Seed default template for template_id: 1
    template = %{
      template_id: 1,
      policy_identifier: "GMC",
      set_default: 1,
      status: 1,
      inserted_at: now_naive,
      updated_at: now_naive
    }

    CorporatePolicy.Repo.insert_all(
      CorporatePolicy.Policies.MasterPolicyFeatureTemplate,
      [template],
      on_conflict: :nothing
    )
  end

  @doc """
  Sets up the sandbox based on the test tags.
  """
  def setup_sandbox(tags) do
    pid = Ecto.Adapters.SQL.Sandbox.start_owner!(CorporatePolicy.Repo, shared: not tags[:async])
    on_exit(fn -> Ecto.Adapters.SQL.Sandbox.stop_owner(pid) end)
  end

  @doc """
  A helper that transforms changeset errors into a map of messages.

      assert {:error, changeset} = Accounts.create_user(%{password: "short"})
      assert "password is too short" in errors_on(changeset).password
      assert %{password: ["password is too short"]} = errors_on(changeset)

  """
  def errors_on(changeset) do
    Ecto.Changeset.traverse_errors(changeset, fn {msg, opts} ->
      Regex.replace(~r"%{(\w+)}", msg, fn _, key ->
        opts |> Keyword.get(String.to_existing_atom(key), key) |> to_string()
      end)
    end)
  end
end
