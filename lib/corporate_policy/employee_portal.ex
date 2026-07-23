defmodule CorporatePolicy.EmployeePortal do
  import Ecto.Query, warn: false

  alias CorporatePolicy.Accounts.User
  alias CorporatePolicy.EscalationMatrices.EscalationMatrix
  alias CorporatePolicy.Policies

  alias CorporatePolicy.Policies.{
    MappingPolicyFeatureTemplatesCorporatesPolicy,
    MasterPolicyEscalationMatrix,
    Policy,
    TrnMappingLiveEmployee
  }

  alias CorporatePolicy.Repo
  alias CorporatePolicy.StringUtils

  require Logger

  @otp_expiry_minutes 5
  @default_otp "123456"
  @eligible_relationships ["Employee", "Self"]

  defmodule SessionEmployee do
    @enforce_keys [:employee_id, :employee_code, :full_name, :ref_corporate_id, :ref_policy_id]
    defstruct [
      :employee_id,
      :employee_code,
      :full_name,
      :mobile_number,
      :relationship,
      :ref_corporate_id,
      :ref_policy_id,
      :user_id,
      :id
    ]
  end

  def otp_expiry_minutes, do: @otp_expiry_minutes

  def eligible_employee_by_mobile(mobile_number) do
    mobile_number = normalize_mobile_number(mobile_number)

    if valid_mobile_number?(mobile_number) do
      Repo.one(
        from e in TrnMappingLiveEmployee,
          where:
            fragment("regexp_replace(coalesce(?, ''), '[^0-9]', '', 'g')", e.mobile_number) ==
              ^mobile_number and
              fragment("trim(coalesce(?, '')) <> ''", e.mobile_number) and
              fragment("trim(coalesce(?, '')) <> ''", e.employee_code) and
              fragment("lower(trim(?))", e.status) == "active" and
              fragment("lower(trim(?))", e.relationship) in ["employee", "self"] and
              is_nil(e.deleted_at),
          order_by: [
            asc:
              fragment(
                "CASE WHEN lower(trim(?)) = 'self' THEN 0 WHEN lower(trim(?)) = 'employee' THEN 1 ELSE 2 END",
                e.relationship,
                e.relationship
              ),
            asc: e.id
          ],
          limit: 1
      )
    end
  end

  def get_authenticated_employee_session(employee_id) do
    TrnMappingLiveEmployee
    |> Repo.get(employee_id)
    |> case do
      %TrnMappingLiveEmployee{} = employee ->
        if employee_active?(employee) and eligible_relationship?(employee.relationship) do
          {:ok, build_session_employee(employee)}
        else
          {:error, :inactive_employee}
        end

      nil ->
        {:error, :not_found}
    end
  end

  def build_session_employee(%TrnMappingLiveEmployee{} = employee) do
    %SessionEmployee{
      id: employee.id,
      employee_id: employee.id,
      employee_code: StringUtils.normalize(employee.employee_code),
      full_name: StringUtils.normalize(employee.employee_name),
      mobile_number: normalize_mobile_number(employee.mobile_number),
      relationship: StringUtils.normalize(employee.relationship),
      ref_corporate_id: employee.ref_corporate_id,
      ref_policy_id: employee.ref_policy_id,
      user_id: resolve_employee_user_id(employee)
    }
  end

  def generate_otp do
    @default_otp
  end

  def default_otp?, do: true
  def default_otp, do: @default_otp

  def send_otp(mobile_number, otp) do
    Logger.info("Employee portal OTP generated for #{mobile_number}: #{otp}")
    :ok
  end

  def normalize_mobile_number(nil), do: ""

  def normalize_mobile_number(number),
    do: number |> to_string() |> String.replace(~r/\D/u, "") |> String.trim()

  def valid_mobile_number?(mobile_number), do: String.length(mobile_number) == 10

  def get_policy_details(policy_id), do: Policies.get_policy_with_preloads(policy_id)

  def select_policy_for_employee(
        %SessionEmployee{} = employee,
        requested_policy_id,
        policies \\ nil
      ) do
    policies = policies || list_policies_for_employee(employee)
    requested_policy_id = parse_int(requested_policy_id)

    Enum.find(policies, &(&1.id == requested_policy_id)) ||
      Enum.find(policies, &(&1.id == employee.ref_policy_id)) ||
      List.first(policies)
  end

  def scoped_employee_for_policy(%SessionEmployee{} = employee, %Policy{} = policy) do
    %SessionEmployee{
      employee
      | ref_policy_id: policy.id,
        ref_corporate_id: policy.ref_corporate_id
    }
  end

  def scoped_employee_for_policy(%SessionEmployee{} = employee, _policy), do: employee

  def list_members(%SessionEmployee{} = employee) do
    Repo.all(
      from e in TrnMappingLiveEmployee,
        where:
          e.ref_policy_id == ^employee.ref_policy_id and
            fragment("lower(trim(?))", e.employee_code) ==
              ^StringUtils.downcase(employee.employee_code) and
            is_nil(e.deleted_at),
        order_by: [
          asc:
            fragment(
              "CASE WHEN lower(trim(?)) IN ('self', 'employee') THEN 0 ELSE 1 END",
              e.relationship
            ),
          asc: e.employee_name
        ]
    )
  end

  def list_policy_feature_cards(policy_id) do
    rows =
      Repo.all(
        from m in MappingPolicyFeatureTemplatesCorporatesPolicy,
          where: m.ref_policy_id == ^policy_id and is_nil(m.deleted_at) and m.status >= 0,
          order_by: [asc: m.ref_template_id, asc: m.ref_policyidentifier_id, asc: m.inserted_at]
      )

    rows
    |> Enum.group_by(&feature_group_key/1)
    |> Enum.map(fn {_key, entries} ->
      identifier =
        find_field_value(entries, "Feature Identifier") ||
          find_field_value(entries, "Policy Identifier") ||
          "Coverage Details"

      subtitle =
        entries
        |> Enum.reject(
          &StringUtils.in?(&1.ref_policy_feature_template_field_name, [
            "Feature Identifier",
            "Policy Identifier"
          ])
        )
        |> Enum.map(fn entry ->
          %{
            label: StringUtils.normalize(entry.ref_policy_feature_template_field_name),
            value: StringUtils.normalize(entry.policy_feature_template_field_value)
          }
        end)
        |> Enum.reject(&blank?(&1.value))

      %{
        id: feature_card_id(entries),
        identifier: identifier,
        details: subtitle
      }
    end)
    |> Enum.sort_by(&String.downcase(&1.identifier || ""))
  end

  def list_contact_matrix(policy_id) do
    Repo.all(
      from pm in MasterPolicyEscalationMatrix,
        join: em in EscalationMatrix,
        on: em.id == pm.user_id,
        where:
          pm.policy_id == ^policy_id and pm.status >= 0 and is_nil(pm.deleted_at) and
            is_nil(em.deleted_at),
        order_by: [asc: pm.escalation_level_id, asc: pm.id],
        select: %{
          id: pm.id,
          level_id: pm.escalation_level_id,
          level: pm.level,
          name: pm.user_fullname,
          mobile_number: em.mobile_number,
          phone_number: em.phone_number,
          email_id: em.email_id,
          alt_email_id: em.alt_email_id,
          address: em.company_fulladdress,
          type: em.type
        }
    )
  end

  def list_policy_types_for_employee(%SessionEmployee{} = employee) do
    employee
    |> list_policies_for_employee()
    |> Enum.map(&StringUtils.normalize(&1.policy_type))
    |> Enum.reject(&blank?/1)
    |> Enum.uniq_by(&StringUtils.downcase/1)
  end

  def list_policies_for_employee(%SessionEmployee{} = employee) do
    policies =
      Repo.all(
        from e in TrnMappingLiveEmployee,
          join: p in Policy,
          on: p.id == e.ref_policy_id,
          where:
            fragment("lower(trim(?))", e.employee_code) ==
              ^StringUtils.downcase(employee.employee_code) and
              fragment("trim(coalesce(?, '')) <> ''", e.employee_code) and
              fragment("lower(trim(?))", e.status) == "active" and
              fragment("lower(trim(?))", e.relationship) in ["employee", "self"] and
              is_nil(e.deleted_at) and p.status in [1, 2],
          order_by: [asc: p.policy_type, asc: p.policy_number],
          distinct: p.id,
          select: p
      )

    Enum.sort_by(policies, fn p ->
      type = String.downcase(p.policy_type || "")

      cond do
        type == "gmc" -> {0, p.policy_number}
        String.contains?(type, "gmc") -> {1, p.policy_number}
        true -> {2, type}
      end
    end)
  end

  def format_relationship(value) do
    StringUtils.normalize(value)
  end

  def eligible_relationships, do: @eligible_relationships

  defp employee_active?(employee), do: StringUtils.equal?(employee.status, "Active")

  defp eligible_relationship?(relationship),
    do: Enum.any?(@eligible_relationships, &StringUtils.equal?(&1, relationship))

  defp feature_group_key(entry) do
    entry.ref_policyidentifier_id ||
      entry.ref_policy_feature_template_field_value_id ||
      "#{entry.ref_template_id}-#{entry.inserted_at}"
  end

  defp find_field_value(entries, field_name) do
    entries
    |> Enum.find(&StringUtils.equal?(&1.ref_policy_feature_template_field_name, field_name))
    |> case do
      nil -> nil
      row -> StringUtils.normalize(row.policy_feature_template_field_value)
    end
  end

  defp feature_card_id([entry | _]),
    do: entry.ref_policyidentifier_id || entry.policy_feature_template_field_value_id

  defp feature_card_id([]), do: nil

  defp blank?(nil), do: true
  defp blank?(""), do: true
  defp blank?(value) when is_binary(value), do: String.trim(value) == ""
  defp blank?(_value), do: false

  defp parse_int(value) when is_integer(value), do: value

  defp parse_int(value) when is_binary(value) and value != "" do
    value
    |> String.trim()
    |> Integer.parse()
    |> case do
      {int, _} -> int
      :error -> nil
    end
  end

  defp parse_int(_value), do: nil

  defp resolve_employee_user_id(%TrnMappingLiveEmployee{} = employee) do
    employee_code = StringUtils.normalize(employee.employee_code)
    mobile_number = normalize_mobile_number(employee.mobile_number)
    email = StringUtils.normalize(employee.email)

    Repo.one(
      from u in User,
        where:
          is_nil(u.deleted_at) and
            u.ref_corporate_id == ^employee.ref_corporate_id and
            (fragment("lower(trim(coalesce(?, '')))", u.corporate_username) ==
               ^StringUtils.downcase(employee_code) or
               fragment("regexp_replace(coalesce(?, ''), '[^0-9]', '', 'g')", u.mobile_no) ==
                 ^mobile_number or
               fragment("lower(trim(coalesce(?, '')))", u.email_address) ==
                 ^StringUtils.downcase(email)),
        order_by: [asc: u.id],
        limit: 1,
        select: u.id
    )
  end
end
