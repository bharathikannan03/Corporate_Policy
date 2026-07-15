defmodule CorporatePolicy.Corporates do
  @moduledoc """
  The Corporates context — manages master_corporates and master_logos records.
  """
  import Ecto.Query, warn: false

  alias CorporatePolicy.Repo
  alias CorporatePolicy.Corporates.Corporate
  alias CorporatePolicy.Corporates.Logo
  alias CorporatePolicy.Corporates.MdVisibilityRoleFeature

  # ─── Logos ────────────────────────────────────────────────────────────────────

  @doc "Inserts a logo record and returns {:ok, logo} or {:error, changeset}."
  def create_logo(attrs) do
    %Logo{}
    |> Logo.changeset(attrs)
    |> Repo.insert()
  end

  # ─── Corporates ───────────────────────────────────────────────────────────────

  @doc "Returns all corporates, ordered by most recent first."
  def list_corporates do
    Corporate
    |> order_by([c], desc: c.corporate_id)
    |> Repo.all()
  end

  @doc "Returns all corporates with a specific status."
  def list_corporates_by_status(status) do
    Corporate
    |> where([c], c.corporate_status == ^status)
    |> order_by([c], desc: c.corporate_id)
    |> Repo.all()
  end

  @doc "Returns count of active corporates (status == 1)"
  def count_active_corporates do
    Corporate
    |> where([c], c.corporate_status == 1)
    |> Repo.aggregate(:count, :corporate_id)
  end

  @doc "Returns count of inactive corporates (status == 0)"
  def count_inactive_corporates do
    Corporate
    |> where([c], c.corporate_status == 0)
    |> Repo.aggregate(:count, :corporate_id)
  end

  @doc "Returns paginated list of corporates and total count."
  def list_corporates_paginated(opts \\ []) do
    page = Keyword.get(opts, :page, 1)
    limit = Keyword.get(opts, :limit, 15)
    offset = (page - 1) * limit
    status = Keyword.get(opts, :status)

    query =
      Corporate
      |> order_by([c], desc: c.corporate_id)

    query =
      case status do
        "active" -> where(query, [c], c.corporate_status == 1)
        "inactive" -> where(query, [c], c.corporate_status == 0)
        _ -> query
      end

    total_count = Repo.aggregate(query, :count, :corporate_id)

    records =
      query
      |> limit(^limit)
      |> offset(^offset)
      |> Repo.all()

    records_with_nums =
      records
      |> Enum.with_index()
      |> Enum.map(fn {corp, idx} ->
        row_num = offset + idx + 1
        Map.put(corp, :row_num, row_num)
      end)

    %{
      records: records_with_nums,
      total_count: total_count,
      page: page,
      limit: limit,
      total_pages: max(1, ceil(total_count / limit))
    }
  end

  @doc "Gets a single corporate. Raises if not found."
  def get_corporate!(id), do: Repo.get!(Corporate, id)

  @doc "Returns a changeset for tracking changes."
  def change_corporate(corporate \\ %Corporate{}, attrs \\ %{}) do
    Corporate.changeset(corporate, attrs)
  end

  @doc """
  Gets a single corporate preloading its logo. Raises if not found.
  """
  def get_corporate_with_logo!(id) do
    Corporate
    |> Repo.get!(id)
    |> Repo.preload(:logo)
  end

  @doc """
  Lists all active contacts (users) associated with a corporate.
  """
  def list_contacts_for_corporate(corporate_id) do
    query =
      from u in CorporatePolicy.Accounts.User,
        join: m in "trn_mapping_corporateid_corporatecontactsids",
        on: m.corporatecontacts_id == u.id,
        where: m.corporate_id == ^corporate_id and m.status == 1,
        order_by: [asc: u.id],
        select: u

    Repo.all(query)
  end

  @doc """
  Updates a corporate record. If a logo_path is provided, a new logo is inserted
  and linked.
  """
  def update_corporate(%Corporate{} = corporate, attrs, logo_path \\ nil) do
    logo_id =
      if logo_path do
        case create_logo(%{logo: logo_path, status: 1}) do
          {:ok, logo} -> logo.logo_id
          _ -> nil
        end
      else
        corporate.ref_master_corporate_logos_id
      end

    attrs = Map.put(attrs, "ref_master_corporate_logos_id", logo_id)
    attrs = add_location_ids(attrs)
    corporate_attrs = Map.drop(attrs, ["contacts"])

    corporate
    |> Corporate.changeset(corporate_attrs)
    |> Repo.update()
  end

  @doc """
  Updates the associated contacts for a corporate. Handles updating existing ones,
  inserting new ones, and soft-deleting removed ones from the mapping.
  """
  def update_contacts(corporate_id, contacts_params) when is_list(contacts_params) do
    Repo.transaction(fn repo ->
      # 1. Fetch current mappings for this corporate
      current_mappings =
        repo.all(
          from m in "trn_mapping_corporateid_corporatecontactsids",
            where: m.corporate_id == ^corporate_id and m.status == 1,
            select: %{id: m.corporatecontacts_id}
        )

      current_contact_ids = Enum.map(current_mappings, & &1.id)

      # 2. Process each submitted contact
      submitted_ids =
        Enum.map(contacts_params, fn contact ->
          contact_id = Map.get(contact, "id")

          db_id =
            case contact_id do
              id when is_integer(id) ->
                id

              id when is_binary(id) ->
                case Integer.parse(id) do
                  {num, ""} -> num
                  _ -> nil
                end

              _ ->
                nil
            end

          full_name = Map.get(contact, "full_name", "")
          email = Map.get(contact, "email_address", "")
          mobile = Map.get(contact, "mobile_number", "")

          if Enum.all?([full_name, email, mobile], &(&1 == "")) do
            nil
          else
            parts = String.split(full_name, ~r/\s+/, parts: 2)

            {first_name, last_name} =
              case parts do
                [f, l] when l != "" -> {f, l}
                [f] when f != "" -> {f, "User"}
                _ -> {"Contact", "User"}
              end

            dep_id_val = Map.get(contact, "department")

            dep_id =
              case dep_id_val do
                id when is_integer(id) ->
                  id

                id when is_binary(id) ->
                  case Integer.parse(id) do
                    {num, ""} -> num
                    _ -> nil
                  end

                _ ->
                  nil
              end

            dep_name =
              if dep_id do
                case repo.one(
                       from r in MdVisibilityRoleFeature,
                         where: r.role_id == ^dep_id,
                         select: r.role,
                         limit: 1
                     ) do
                  nil -> ""
                  name -> name
                end
              else
                Map.get(contact, "department", "")
              end

            user_attrs = %{
              first_name: first_name,
              last_name: last_name,
              full_name: full_name,
              mobile_no: mobile,
              email_address: email,
              status: 1,
              corporate_username: Map.get(contact, "corporate_username", ""),
              department_name: dep_name,
              department_id: dep_id,
              location: Map.get(contact, "location", ""),
              ref_corporate_id: corporate_id
            }

            if db_id && db_id in current_contact_ids do
              # Update existing user
              user = repo.get!(CorporatePolicy.Accounts.User, db_id)
              user_changeset = CorporatePolicy.Accounts.User.changeset(user, user_attrs)

              case repo.update(user_changeset) do
                {:ok, updated_user} -> updated_user.id
                {:error, cs} -> repo.rollback(cs)
              end
            else
              # Insert new user
              random_password = :crypto.strong_rand_bytes(8) |> Base.encode16(case: :lower)
              user_attrs = Map.put(user_attrs, :password, random_password)

              user_changeset =
                CorporatePolicy.Accounts.User.changeset(
                  %CorporatePolicy.Accounts.User{},
                  user_attrs
                )

              case repo.insert(user_changeset) do
                {:ok, user} ->
                  now = DateTime.utc_now()

                  mapping = %{
                    corporate_id: corporate_id,
                    corporatecontacts_id: user.id,
                    status: 1,
                    inserted_at: now,
                    updated_at: now
                  }

                  repo.insert_all("trn_mapping_corporateid_corporatecontactsids", [mapping])
                  user.id

                {:error, cs} ->
                  repo.rollback(cs)
              end
            end
          end
        end)
        |> Enum.reject(&is_nil/1)

      # 3. Soft-delete mappings for contacts that were deleted in UI
      removed_ids = current_contact_ids -- submitted_ids

      if not Enum.empty?(removed_ids) do
        from(m in "trn_mapping_corporateid_corporatecontactsids",
          where: m.corporate_id == ^corporate_id and m.corporatecontacts_id in ^removed_ids
        )
        |> repo.update_all(set: [status: 0, updated_at: DateTime.utc_now()])
      end

      {:ok, :success}
    end)
  end

  @doc """
  Step 1 — saves logo (if any) into `master_logos` then inserts the corporate
  row into `master_corporates` linking the logo id.

  Returns `{:ok, corporate}` or `{:error, changeset}`.
  """
  def create_corporate(attrs, logo_path \\ nil) do
    logo_id =
      if logo_path do
        case create_logo(%{logo: logo_path, status: 1}) do
          {:ok, logo} -> logo.logo_id
          _ -> nil
        end
      end

    attrs = Map.put(attrs, "ref_master_corporate_logos_id", logo_id)
    attrs = add_location_ids(attrs)

    # Strip contacts key so it does not confuse the corporate changeset
    corporate_attrs = Map.drop(attrs, ["contacts"])
    changeset = Corporate.changeset(%Corporate{}, corporate_attrs)

    Repo.insert(changeset)
  end

  @doc """
  Step 2 — given an existing `corporate_id` and a list of contact param maps,
  inserts each contact as a `users` row and links it via
  `trn_mapping_corporateid_corporatecontactsids`.

  Entries where all of full_name / email_address / mobile_number are blank are
  silently skipped.

  Returns `{:ok, [users | :skipped]}` or `{:error, changeset}`.
  """
  def save_contacts(corporate_id, contacts_params) when is_list(contacts_params) do
    Repo.transaction(fn repo ->
      results =
        Enum.map(contacts_params, fn contact ->
          full_name = Map.get(contact, "full_name", "")
          email = Map.get(contact, "email_address", "")
          mobile = Map.get(contact, "mobile_number", "")

          if Enum.all?([full_name, email, mobile], &(&1 == "")) do
            {:ok, :skipped}
          else
            random_password = :crypto.strong_rand_bytes(8) |> Base.encode16(case: :lower)

            parts = String.split(full_name, ~r/\s+/, parts: 2)

            {first_name, last_name} =
              case parts do
                [f, l] when l != "" -> {f, l}
                [f] when f != "" -> {f, "User"}
                _ -> {"Contact", "User"}
              end

            dep_id_val = Map.get(contact, "department")

            dep_id =
              case dep_id_val do
                id when is_integer(id) ->
                  id

                id when is_binary(id) ->
                  case Integer.parse(id) do
                    {num, ""} -> num
                    _ -> nil
                  end

                _ ->
                  nil
              end

            dep_name =
              if dep_id do
                case repo.one(
                       from r in MdVisibilityRoleFeature,
                         where: r.role_id == ^dep_id,
                         select: r.role,
                         limit: 1
                     ) do
                  nil -> ""
                  name -> name
                end
              else
                Map.get(contact, "department", "")
              end

            user_attrs = %{
              first_name: first_name,
              last_name: last_name,
              full_name: full_name,
              mobile_no: mobile,
              email_address: email,
              password: random_password,
              status: 1,
              corporate_username: Map.get(contact, "corporate_username", ""),
              department_name: dep_name,
              department_id: dep_id,
              location: Map.get(contact, "location", ""),
              ref_corporate_id: corporate_id
            }

            user_changeset =
              CorporatePolicy.Accounts.User.changeset(
                %CorporatePolicy.Accounts.User{},
                user_attrs
              )

            case repo.insert(user_changeset) do
              {:ok, user} ->
                now = DateTime.utc_now()

                mapping = %{
                  corporate_id: corporate_id,
                  corporatecontacts_id: user.id,
                  status: 1,
                  inserted_at: now,
                  updated_at: now
                }

                repo.insert_all("trn_mapping_corporateid_corporatecontactsids", [mapping])
                {:ok, user}

              {:error, cs} ->
                IO.inspect(cs.errors, label: "User changeset errors in save_contacts")
                repo.rollback(cs)
            end
          end
        end)

      Enum.map(results, fn {:ok, val} -> val end)
    end)
  end

  @doc """
  Generates a unique 6-character alphanumeric group code.
  Keeps retrying until a code that does not exist in the DB is found.
  """
  def generate_group_code do
    code = random_code()

    if Repo.exists?(from c in Corporate, where: c.corporate_group_code == ^code) do
      generate_group_code()
    else
      code
    end
  end

  defp random_code do
    :crypto.strong_rand_bytes(4)
    |> Base.encode16(case: :upper)
    |> binary_part(0, 6)
  end

  @doc """
  Returns a list of roles for department dropdown options where is_visible is 2.
  """
  def list_departments_for_dropdown do
    MdVisibilityRoleFeature
    |> where([r], r.is_visible == 2)
    |> select([r], {r.role, r.role_id})
    |> Repo.all()
  end

  def get_role_id_by_name(name) do
    if name && name != "" do
      query =
        from r in MdVisibilityRoleFeature,
          where: ilike(r.role, ^name),
          select: r.role_id,
          limit: 1

      Repo.one(query)
    else
      nil
    end
  end

  @doc """
  Finds the city and state names for a given pincode.
  Returns `%{city: city_name, state: state_name, pincode_id: pincode_id, city_id: city_id, state_id: state_id}` or `nil`.
  """
  def get_location_by_pincode(pincode) do
    pincode_int =
      case pincode do
        p when is_integer(p) ->
          p

        p when is_binary(p) ->
          case Integer.parse(p) do
            {num, ""} -> num
            _ -> nil
          end

        _ ->
          nil
      end

    if pincode_int do
      query =
        from m in CorporatePolicy.Corporates.TrnMappingPincodeCityState,
          join: p in CorporatePolicy.Corporates.Pincode,
          on: m.pincode_id == p.pincode_id,
          join: c in CorporatePolicy.Corporates.City,
          on: m.city_id == c.city_id,
          join: s in CorporatePolicy.Corporates.State,
          on: m.state_id == s.state_id,
          where: p.pincode == ^pincode_int,
          select: %{
            city: c.city,
            state: s.state,
            pincode_id: p.pincode_id,
            city_id: c.city_id,
            state_id: s.state_id
          },
          limit: 1

      Repo.one(query)
    else
      nil
    end
  end

  defp add_location_ids(attrs) do
    pincode = Map.get(attrs, "pincode") || Map.get(attrs, :pincode)

    if pincode && pincode != "" do
      case get_location_by_pincode(pincode) do
        location when is_map(location) ->
          cond do
            Map.has_key?(attrs, "pincode") ->
              attrs
              |> Map.put("ref_master_pincode_pincode_id", location.pincode_id)
              |> Map.put("ref_master_city_city_id", location.city_id)
              |> Map.put("ref_master_state_state_id", location.state_id)

            true ->
              attrs
              |> Map.put(:ref_master_pincode_pincode_id, location.pincode_id)
              |> Map.put(:ref_master_city_city_id, location.city_id)
              |> Map.put(:ref_master_state_state_id, location.state_id)
          end

        _ ->
          attrs
      end
    else
      attrs
    end
  end
end
