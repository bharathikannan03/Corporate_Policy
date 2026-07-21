defmodule CorporatePolicy.CdStatements do
  @moduledoc """
  Shared business logic for CD accounts and policy CD statement uploads.
  """

  import Ecto.Query, warn: false

  alias CorporatePolicy.Policies
  alias CorporatePolicy.Policies.MasterCdAccount
  alias CorporatePolicy.Policies.MasterCdStatementDataUpload
  alias CorporatePolicy.Policies.MasterCdStatementUploadError
  alias CorporatePolicy.Policies.MasterPolicyCdStatement
  alias CorporatePolicy.Repo
  alias CorporatePolicy.Utils.CSVParser

  @page_size 15
  @section_id 7
  @sample_csv_path Path.join(["priv", "static", "templates", "cd_ledger.csv"])
  @required_headers [
    "particular",
    "transaction_type",
    "employee_count",
    "dependant_count",
    "policy_endorsement_no",
    "endorsement_issued_date",
    "debit_amount",
    "credit_amount",
    "bank_name",
    "cheque_no",
    "policy_number",
    "remark"
  ]

  def page_size, do: @page_size
  def section_id, do: @section_id
  def sample_csv_path, do: @sample_csv_path

  def list_active_corporates do
    Policies.list_corporates()
  end

  def list_policy_options_for_corporate(corporate_id) do
    Policies.list_active_policies_by_corporate(corporate_id)
    |> Enum.map(fn policy ->
      %{
        id: policy.id,
        policy_number: policy.policy_number,
        insurer_id: policy.ref_select_insurer_id,
        insurer_name: policy.select_insurer
      }
    end)
  end

  def list_cd_numbers_for_corporate(corporate_id) do
    from(a in MasterCdAccount,
      where: a.corporate_id == ^corporate_id and a.status == 1 and is_nil(a.deleted_at),
      order_by: [asc: a.cd_number]
    )
    |> Repo.all()
  end

  def get_cd_account_by_corporate_and_number(corporate_id, cd_number) do
    Repo.one(
      from a in MasterCdAccount,
        where:
          a.corporate_id == ^corporate_id and a.cd_number == ^cd_number and a.status == 1 and
            is_nil(a.deleted_at),
        order_by: [desc: a.id],
        limit: 1
    )
  end

  def list_cd_accounts_paginated(opts \\ %{}) do
    search = normalize_search(Map.get(opts, "search"))
    sort_by = Map.get(opts, "sort_by", "inserted_at")
    sort_dir = Map.get(opts, "sort_dir", "desc")
    page = normalize_page(Map.get(opts, "page", 1))

    base_query =
      from a in MasterCdAccount,
        where: is_nil(a.deleted_at)

    base_query =
      if search == "" do
        base_query
      else
        like = "%#{search}%"

        from a in base_query,
          where:
            ilike(a.cd_number, ^like) or ilike(a.corporate_name, ^like) or
              ilike(a.policy_number, ^like) or ilike(a.insurer_name, ^like)
      end

    base_query = order_cd_accounts(base_query, sort_by, sort_dir)

    paginate_query(base_query, page)
  end

  def create_cd_account(attrs, user_id) do
    with {:ok, corporate_id} <- parse_int(attrs["corporate_id"], "Corporate is required"),
         {:ok, policy_id} <- parse_int(attrs["policy_id"], "Policy number is required"),
         policy when not is_nil(policy) <- Policies.get_policy(corporate_policy_id(policy_id)),
         :ok <- validate_policy_belongs_to_corporate(policy, corporate_id) do
      policy = Policies.get_policy!(policy_id) |> Repo.preload([:corporate, :insurer_ref])
      corporate = policy.corporate
      insurer = policy.insurer_ref

      if is_nil(corporate) or is_nil(insurer) do
        {:error, "Selected policy is missing corporate or insurer information"}
      else
        cd_number = normalize_string(attrs["cd_number"])
        cd_name = normalize_string(attrs["cd_name"])
        cd_name = if cd_name == "", do: cd_number, else: cd_name

        duplicate? =
          Repo.exists?(
            from a in MasterCdAccount,
              where:
                a.corporate_id == ^corporate_id and a.policy_id == ^policy_id and
                  a.cd_number == ^cd_number and is_nil(a.deleted_at)
          )

        if duplicate? do
          {:error, "CD number already exists for the selected policy"}
        else
          %MasterCdAccount{}
          |> MasterCdAccount.changeset(%{
            cd_name: cd_name,
            cd_number: cd_number,
            corporate_id: corporate.corporate_id,
            corporate_name: corporate.corporate_name,
            policy_id: policy.id,
            policy_number: policy.policy_number,
            insurer_id: insurer.id,
            insurer_name: insurer.name,
            status: 1,
            created_by: user_id,
            updated_by: user_id
          })
          |> Repo.insert()
        end
      end
    else
      nil -> {:error, "Selected policy was not found"}
      {:error, _} = error -> error
    end
  end

  def list_policy_cd_statement_uploads(policy_id, opts \\ %{}) do
    search = normalize_search(Map.get(opts, "search"))
    sort_by = Map.get(opts, "sort_by", "inserted_at")
    sort_dir = Map.get(opts, "sort_dir", "desc")
    page = normalize_page(Map.get(opts, "page", 1))

    base_query =
      from s in MasterPolicyCdStatement,
        where: s.policy_id == ^policy_id and is_nil(s.deleted_at)

    base_query =
      if search == "" do
        base_query
      else
        like = "%#{search}%"

        from s in base_query,
          where:
            ilike(s.cd_number, ^like) or ilike(s.original_file_name, ^like) or
              ilike(s.corporate_name, ^like)
      end

    base_query = order_cd_statements(base_query, sort_by, sort_dir)

    page_data = paginate_query(base_query, page)

    entries =
      Enum.map(page_data.entries, fn upload ->
        Map.put(upload, :upload_errors_count, count_upload_errors(upload.id))
      end)

    %{page_data | entries: entries}
  end

  def list_cd_statement_uploads_paginated(opts \\ %{}) do
    search = normalize_search(Map.get(opts, "search"))
    sort_by = Map.get(opts, "sort_by", "inserted_at")
    sort_dir = Map.get(opts, "sort_dir", "desc")
    page = normalize_page(Map.get(opts, "page", 1))

    base_query =
      from s in MasterPolicyCdStatement,
        where: is_nil(s.deleted_at)

    base_query =
      if search == "" do
        base_query
      else
        like = "%#{search}%"

        from s in base_query,
          where:
            ilike(s.cd_number, ^like) or ilike(s.original_file_name, ^like) or
              ilike(s.corporate_name, ^like)
      end

    base_query = order_cd_statements(base_query, sort_by, sort_dir)

    page_data = paginate_query(base_query, page)

    entries =
      Enum.map(page_data.entries, fn upload ->
        Map.put(upload, :upload_errors_count, count_upload_errors(upload.id))
      end)

    %{page_data | entries: entries}
  end

  def list_policy_cd_statement_rows(policy_id, opts \\ %{}) do
    search = normalize_search(Map.get(opts, "search"))
    sort_by = Map.get(opts, "sort_by", "inserted_at")
    sort_dir = Map.get(opts, "sort_dir", "desc")
    page = normalize_page(Map.get(opts, "page", 1))

    base_query =
      from r in MasterCdStatementDataUpload,
        where: r.policy_id == ^policy_id and is_nil(r.deleted_at)

    base_query =
      if search == "" do
        base_query
      else
        like = "%#{search}%"

        from r in base_query,
          where:
            ilike(r.policy_number, ^like) or ilike(r.particular, ^like) or
              ilike(r.transaction_type, ^like) or ilike(r.policy_endorsement_no, ^like) or
              ilike(r.bank_name, ^like) or ilike(r.cheque_no, ^like) or ilike(r.remark, ^like)
      end

    base_query = order_cd_statement_rows(base_query, sort_by, sort_dir)

    paginate_query(base_query, page)
  end

  def list_policy_cd_statement_rows_for_export(policy_id) do
    Repo.all(
      from r in MasterCdStatementDataUpload,
        where: r.policy_id == ^policy_id and is_nil(r.deleted_at),
        order_by: [asc: r.id]
    )
  end

  def delete_policy_cd_statement_row(row_id, policy_id, user_id) do
    case Repo.get_by(MasterCdStatementDataUpload,
           id: row_id,
           policy_id: policy_id,
           deleted_at: nil
         ) do
      nil ->
        {:error, "CD Statement row not found"}

      row ->
        row
        |> Ecto.Changeset.change(deleted_at: DateTime.utc_now(), updated_by: user_id)
        |> Repo.update()
    end
  end

  def get_upload_errors(upload_id) do
    Repo.all(
      from e in MasterCdStatementUploadError,
        where: e.ref_doc_id == ^upload_id,
        order_by: [asc: e.row, asc: e.id]
    )
  end

  def create_policy_cd_statement_upload(policy, attrs, file_info, user_id) do
    with {:ok, corporate_id} <- parse_int(attrs["corporate_id"], "Corporate is required"),
         cd_number when cd_number != "" <- normalize_string(attrs["cd_number"]),
         :ok <- validate_policy_belongs_to_corporate(policy, corporate_id),
         %MasterCdAccount{} = cd_account <-
           get_cd_account_by_corporate_and_number(corporate_id, cd_number) do
      Repo.transaction(fn ->
        upload =
          %MasterPolicyCdStatement{}
          |> MasterPolicyCdStatement.changeset(%{
            corporate_name: policy.corporate_name,
            corporate_id: corporate_id,
            cd_number: cd_number,
            cd_account_id: cd_account.id,
            data_upload_file: file_info.public_path,
            original_file_name: file_info.original_file_name,
            policy_id: policy.id,
            is_dataupload: true,
            status: 0,
            created_by: user_id,
            updated_by: user_id
          })
          |> Repo.insert!()

        {valid_rows, errors} =
          parse_and_validate_csv(file_info.absolute_path, policy, upload, user_id)

        Enum.each(valid_rows, fn row_attrs ->
          %MasterCdStatementDataUpload{}
          |> MasterCdStatementDataUpload.changeset(row_attrs)
          |> Repo.insert!()
        end)

        Enum.each(errors, fn error_attrs ->
          %MasterCdStatementUploadError{}
          |> MasterCdStatementUploadError.changeset(error_attrs)
          |> Repo.insert!()
        end)

        status = if errors == [], do: 1, else: 2

        upload =
          upload
          |> Ecto.Changeset.change(status: status, updated_by: user_id)
          |> Repo.update!()

        mark_section_completion(policy.id, user_id, status == 1)

        %{upload: upload, imported_rows: length(valid_rows), errors_count: length(errors)}
      end)
    else
      "" -> {:error, "CD number is required"}
      nil -> {:error, "No CD number exists for the selected corporate"}
      {:error, _} = error -> error
    end
  end

  def create_cd_statement_upload(attrs, file_info, user_id) do
    with {:ok, corporate_id} <- parse_int(attrs["corporate_id"], "Corporate is required"),
         cd_number when cd_number != "" <- normalize_string(attrs["cd_number"]),
         %MasterCdAccount{} = cd_account <-
           get_cd_account_by_corporate_and_number(corporate_id, cd_number),
         {:ok, policy} <- get_cd_account_policy(cd_account),
         :ok <- validate_policy_belongs_to_corporate(policy, corporate_id) do
      create_policy_cd_statement_upload(
        policy,
        %{"corporate_id" => corporate_id, "cd_number" => cd_number},
        file_info,
        user_id
      )
    else
      "" -> {:error, "CD number is required"}
      nil -> {:error, "No CD number exists for the selected corporate"}
      {:error, _} = error -> error
    end
  end

  defp parse_and_validate_csv(file_path, policy, upload, user_id) do
    lines =
      file_path
      |> File.stream!()
      |> Enum.map(&String.trim_trailing(&1, "\n"))
      |> Enum.reject(&(&1 == ""))

    case lines do
      [] ->
        {[], [build_error(upload.id, 1, "file", "CSV file is empty")]}

      [header_line | row_lines] ->
        headers =
          header_line
          |> CSVParser.parse_line()
          |> Enum.map(&normalize_header/1)

        if headers != @required_headers do
          {[],
           [
             build_error(
               upload.id,
               1,
               "header",
               "Invalid CSV headers. Download the sample template and try again."
             )
           ]}
        else
          row_lines
          |> Enum.with_index(2)
          |> Enum.reduce({[], []}, fn {line, row_number}, {valid_rows, errors} ->
            row =
              line
              |> CSVParser.parse_line()
              |> Enum.zip(headers)
              |> Enum.into(%{}, fn {value, key} -> {key, String.trim(value)} end)

            case validate_csv_row(row, row_number, policy, upload, user_id) do
              {:ok, attrs} -> {[attrs | valid_rows], errors}
              {:error, row_errors} -> {valid_rows, row_errors ++ errors}
            end
          end)
          |> then(fn {valid_rows, errors} -> {Enum.reverse(valid_rows), Enum.reverse(errors)} end)
        end
    end
  end

  defp validate_csv_row(row, row_number, policy, upload, user_id) do
    errors = []
    errors = require_field(errors, upload.id, row_number, "particular", row["particular"])

    errors =
      require_field(errors, upload.id, row_number, "transaction_type", row["transaction_type"])

    errors = require_field(errors, upload.id, row_number, "policy_number", row["policy_number"])

    errors =
      if row["policy_number"] != "" and row["policy_number"] != to_string(policy.policy_number) do
        [
          build_error(
            upload.id,
            row_number,
            "policy_number",
            "Policy number does not match the current policy"
          )
          | errors
        ]
      else
        errors
      end

    errors =
      validate_regex(
        errors,
        upload.id,
        row_number,
        "policy_number",
        row["policy_number"],
        ~r/^[A-Za-z0-9\-\/]+$/,
        "Policy number format is invalid"
      )

    errors =
      validate_integer(errors, upload.id, row_number, "employee_count", row["employee_count"])

    errors =
      validate_integer(errors, upload.id, row_number, "dependant_count", row["dependant_count"])

    errors = validate_decimal(errors, upload.id, row_number, "debit_amount", row["debit_amount"])

    errors =
      validate_decimal(errors, upload.id, row_number, "credit_amount", row["credit_amount"])

    errors =
      validate_date(
        errors,
        upload.id,
        row_number,
        "endorsement_issued_date",
        row["endorsement_issued_date"]
      )

    if errors == [] do
      {:ok,
       %{
         ref_policy_cd_statement_id: upload.id,
         particular: row["particular"],
         transaction_type: row["transaction_type"],
         employee_count: parse_optional_integer(row["employee_count"]),
         dependant_count: parse_optional_integer(row["dependant_count"]),
         policy_endorsement_no: blank_to_nil(row["policy_endorsement_no"]),
         endorsement_issued_date: blank_to_nil(row["endorsement_issued_date"]),
         debit_amount: parse_optional_decimal(row["debit_amount"]),
         credit_amount: parse_optional_decimal(row["credit_amount"]),
         bank_name: blank_to_nil(row["bank_name"]),
         cheque_no: blank_to_nil(row["cheque_no"]),
         policy_number: row["policy_number"],
         remark: blank_to_nil(row["remark"]),
         corporate_name: policy.corporate_name,
         corporate_id: policy.ref_corporate_id,
         policy_id: policy.id,
         cd_number: upload.cd_number,
         status: 1,
         created_by: user_id,
         updated_by: user_id
       }}
    else
      {:error, Enum.reverse(errors)}
    end
  end

  defp mark_section_completion(policy_id, user_id, completed?) do
    now = DateTime.utc_now()

    existing =
      Repo.one(
        from m in "mapping_policy_completions",
          where: field(m, :ref_policy_id) == ^policy_id and field(m, :section_id) == ^@section_id,
          select: %{id: field(m, :id)}
      )

    attrs = [
      is_completed: completed?,
      completed_by: if(completed?, do: user_id, else: nil),
      completed_at: if(completed?, do: now, else: nil),
      updated_at: now
    ]

    if existing do
      from(m in "mapping_policy_completions", where: field(m, :id) == ^existing.id)
      |> Repo.update_all(set: attrs)
    else
      Repo.insert_all("mapping_policy_completions", [
        [
          ref_policy_id: policy_id,
          section_id: @section_id,
          is_completed: completed?,
          completed_by: if(completed?, do: user_id, else: nil),
          completed_at: if(completed?, do: now, else: nil),
          inserted_at: now,
          updated_at: now
        ]
      ])
    end

    Policies.finalize_policy_status(policy_id)
  end

  defp count_upload_errors(upload_id) do
    Repo.aggregate(
      from(e in MasterCdStatementUploadError, where: e.ref_doc_id == ^upload_id),
      :count,
      :id
    )
  end

  defp paginate_query(base_query, page) do
    total_entries = Repo.aggregate(base_query, :count, :id)
    total_pages = max(Integer.ceil_div(max(total_entries, 1), @page_size), 1)
    page = min(page, total_pages)

    entries =
      base_query
      |> limit(^@page_size)
      |> offset(^((page - 1) * @page_size))
      |> Repo.all()

    %{
      entries: entries,
      page: page,
      page_size: @page_size,
      total_entries: total_entries,
      total_pages: total_pages
    }
  end

  defp order_cd_accounts(query, sort_by, sort_dir) do
    direction = normalize_direction(sort_dir)

    case sort_by do
      "cd_number" -> from a in query, order_by: [{^direction, a.cd_number}, desc: a.id]
      "corporate_name" -> from a in query, order_by: [{^direction, a.corporate_name}, desc: a.id]
      "policy_number" -> from a in query, order_by: [{^direction, a.policy_number}, desc: a.id]
      "insurer_name" -> from a in query, order_by: [{^direction, a.insurer_name}, desc: a.id]
      _ -> from a in query, order_by: [{^direction, a.inserted_at}, desc: a.id]
    end
  end

  defp order_cd_statements(query, sort_by, sort_dir) do
    direction = normalize_direction(sort_dir)

    case sort_by do
      "cd_number" ->
        from s in query, order_by: [{^direction, s.cd_number}, desc: s.id]

      "original_file_name" ->
        from s in query, order_by: [{^direction, s.original_file_name}, desc: s.id]

      "status" ->
        from s in query, order_by: [{^direction, s.status}, desc: s.id]

      _ ->
        from s in query, order_by: [{^direction, s.inserted_at}, desc: s.id]
    end
  end

  defp order_cd_statement_rows(query, sort_by, sort_dir) do
    direction = normalize_direction(sort_dir)

    case sort_by do
      "policy_number" ->
        from r in query, order_by: [{^direction, r.policy_number}, desc: r.id]

      "particular" ->
        from r in query, order_by: [{^direction, r.particular}, desc: r.id]

      "debit_amount" ->
        from r in query, order_by: [{^direction, r.debit_amount}, desc: r.id]

      "credit_amount" ->
        from r in query, order_by: [{^direction, r.credit_amount}, desc: r.id]

      "policy_endorsement_no" ->
        from r in query, order_by: [{^direction, r.policy_endorsement_no}, desc: r.id]

      "endorsement_issued_date" ->
        from r in query, order_by: [{^direction, r.endorsement_issued_date}, desc: r.id]

      "bank_name" ->
        from r in query, order_by: [{^direction, r.bank_name}, desc: r.id]

      "cheque_no" ->
        from r in query, order_by: [{^direction, r.cheque_no}, desc: r.id]

      "remark" ->
        from r in query, order_by: [{^direction, r.remark}, desc: r.id]

      _ ->
        from r in query, order_by: [{^direction, r.inserted_at}, desc: r.id]
    end
  end

  defp validate_policy_belongs_to_corporate(policy, corporate_id) do
    if policy.ref_corporate_id == corporate_id do
      :ok
    else
      {:error, "Selected corporate does not match the current policy"}
    end
  end

  defp get_cd_account_policy(%MasterCdAccount{policy_id: nil}) do
    {:error, "Selected CD number is not linked to a policy"}
  end

  defp get_cd_account_policy(%MasterCdAccount{policy_id: policy_id}) do
    case Policies.get_policy(policy_id) do
      nil ->
        {:error, "Selected CD number is linked to an invalid policy"}

      policy ->
        {:ok, policy}
    end
  end

  defp corporate_policy_id(policy_id), do: policy_id

  defp require_field(errors, upload_id, row_number, field, value) do
    if normalize_string(value) == "" do
      [build_error(upload_id, row_number, field, "#{humanize(field)} is required") | errors]
    else
      errors
    end
  end

  defp validate_integer(errors, _upload_id, _row_number, _field, ""), do: errors

  defp validate_integer(errors, upload_id, row_number, field, value) do
    case Integer.parse(value) do
      {_, ""} ->
        errors

      _ ->
        [
          build_error(upload_id, row_number, field, "#{humanize(field)} must be an integer")
          | errors
        ]
    end
  end

  defp validate_decimal(errors, _upload_id, _row_number, _field, ""), do: errors

  defp validate_decimal(errors, upload_id, row_number, field, value) do
    case Decimal.parse(value) do
      {_, ""} ->
        errors

      _ ->
        [build_error(upload_id, row_number, field, "#{humanize(field)} must be numeric") | errors]
    end
  end

  defp validate_date(errors, _upload_id, _row_number, _field, ""), do: errors

  defp validate_date(errors, upload_id, row_number, field, value) do
    if Regex.match?(~r/^\d{1,2}[-\/]\d{1,2}[-\/]\d{4}$/, value) do
      errors
    else
      [
        build_error(
          upload_id,
          row_number,
          field,
          "#{humanize(field)} must be in DD-MM-YYYY format"
        )
        | errors
      ]
    end
  end

  defp validate_regex(errors, _upload_id, _row_number, _field, "", _regex, _message), do: errors

  defp validate_regex(errors, upload_id, row_number, field, value, regex, message) do
    if Regex.match?(regex, value) do
      errors
    else
      [build_error(upload_id, row_number, field, message) | errors]
    end
  end

  defp build_error(upload_id, row, column_name, message) do
    %{
      ref_doc_id: upload_id,
      row: row,
      column_name: column_name,
      errors: message
    }
  end

  defp normalize_header(header) do
    header
    |> String.trim()
    |> String.downcase()
  end

  defp humanize(field) do
    field
    |> String.replace("_", " ")
    |> String.capitalize()
  end

  defp normalize_search(nil), do: ""
  defp normalize_search(value), do: value |> to_string() |> String.trim()

  defp normalize_page(value) when is_integer(value), do: max(value, 1)

  defp normalize_page(value) when is_binary(value) do
    case Integer.parse(value) do
      {page, ""} -> max(page, 1)
      _ -> 1
    end
  end

  defp normalize_page(_), do: 1

  defp normalize_direction("asc"), do: :asc
  defp normalize_direction(_), do: :desc

  defp normalize_string(nil), do: ""
  defp normalize_string(value), do: value |> to_string() |> String.trim()

  defp blank_to_nil(value) do
    case normalize_string(value) do
      "" -> nil
      normalized -> normalized
    end
  end

  defp parse_int(value, message) do
    case value do
      value when is_integer(value) ->
        {:ok, value}

      value when is_binary(value) ->
        case Integer.parse(value) do
          {int, ""} -> {:ok, int}
          _ -> {:error, message}
        end

      _ ->
        {:error, message}
    end
  end

  defp parse_optional_integer(""), do: nil
  defp parse_optional_integer(nil), do: nil
  defp parse_optional_integer(value), do: value |> String.trim() |> String.to_integer()

  defp parse_optional_decimal(""), do: nil
  defp parse_optional_decimal(nil), do: nil
  defp parse_optional_decimal(value), do: Decimal.new(String.trim(value))
end
