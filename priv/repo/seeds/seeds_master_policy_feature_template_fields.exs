alias CorporatePolicy.Repo
alias CorporatePolicy.Policies.MasterPolicyFeatureTemplateField

defmodule SQLParserHelper do
  def parse_tuples(str) do
    parse_chars(str, [], nil, false)
  end

  def parse_chars("", acc, _, _), do: Enum.reverse(acc)
  def parse_chars(str, acc, current, in_string) do
    first = String.first(str)
    case {first, in_string} do
      {nil, _} -> Enum.reverse(acc)
      {"'", true} ->
        next = String.at(str, 1)
        if next == "'" do
          parse_chars(String.slice(str, 2..-1//1), acc, current <> "''", true)
        else
          parse_chars(String.slice(str, 1..-1//1), acc, current <> "'", false)
        end
      {"\\", true} ->
        next = String.at(str, 1) || ""
        parse_chars(String.slice(str, 2..-1//1), acc, current <> "\\" <> next, true)
      {"'", false} ->
        parse_chars(String.slice(str, 1..-1//1), acc, (current || "") <> "'", true)
      {"(", false} when is_nil(current) ->
        parse_chars(String.slice(str, 1..-1//1), acc, "", false)
      {")", false} when not is_nil(current) ->
        parse_chars(String.slice(str, 1..-1//1), [current | acc], nil, false)
      {char, val} ->
        new_curr = if current, do: current <> char, else: nil
        parse_chars(String.slice(str, 1..-1//1), acc, new_curr, val)
    end
  end

  def split_values(tuple_str) do
    parse_values(tuple_str, [], "", false)
  end

  def parse_values("", acc, curr, _) do
    Enum.reverse([String.trim(curr) | acc])
  end

  def parse_values(str, acc, curr, in_string) do
    first = String.first(str)
    case {first, in_string} do
      {"'", true} ->
        next = String.at(str, 1)
        if next == "'" do
          parse_values(String.slice(str, 2..-1//1), acc, curr <> "''", true)
        else
          parse_values(String.slice(str, 1..-1//1), acc, curr <> "'", false)
        end
      {"\\", true} ->
        next = String.at(str, 1) || ""
        parse_values(String.slice(str, 2..-1//1), acc, curr <> "\\" <> next, true)
      {"'", false} ->
        parse_values(String.slice(str, 1..-1//1), acc, curr <> "'", true)
      {",", false} ->
        parse_values(String.slice(str, 1..-1//1), [String.trim(curr) | acc], "", false)
      {char, val} ->
        parse_values(String.slice(str, 1..-1//1), acc, curr <> char, val)
    end
  end

  def parse_int(nil), do: nil
  def parse_int("NULL"), do: nil
  def parse_int(val) do
    case Integer.parse(val) do
      {num, ""} -> num
      _ -> nil
    end
  end

  def parse_string(nil), do: nil
  def parse_string("NULL"), do: nil
  def parse_string("'" <> rest) do
    val = String.slice(rest, 0..-2//1)
    val
    |> String.replace("''", "'")
    |> String.replace("\\'", "'")
    |> String.replace("\\n", "\n")
    |> String.replace("\\r", "\r")
    |> String.replace("\\t", "\t")
  end
  def parse_string(other), do: other

  def parse_datetime(nil), do: nil
  def parse_datetime("NULL"), do: nil
  def parse_datetime(val) do
    str = parse_string(val)
    if str do
      case NaiveDateTime.from_iso8601(String.replace(str, " ", "T")) do
        {:ok, ndt} -> ndt
        _ -> nil
      end
    else
      nil
    end
  end
end

sql_path = Path.expand("live_vibe_engine_master_policy_feature_template_fields.sql")

if File.exists?(sql_path) do
  IO.puts("Seeding master policy feature template fields from SQL reference...")
  sql = File.read!(sql_path)

  case String.split(sql, "INSERT INTO `master_policy_feature_template_fields` VALUES") do
    [_, data_part] ->
      rows = SQLParserHelper.parse_tuples(String.trim(data_part))
      IO.puts("Parsed #{length(rows)} rows from SQL reference.")

      now = NaiveDateTime.utc_now() |> NaiveDateTime.truncate(:second)

      # Clean table first
      Repo.delete_all(MasterPolicyFeatureTemplateField)

      inserted_count = Enum.reduce(rows, 0, fn row_str, acc ->
        vals = SQLParserHelper.split_values(row_str)

        template_field_id = SQLParserHelper.parse_int(Enum.at(vals, 0))
        name = SQLParserHelper.parse_string(Enum.at(vals, 1))
        placeholder = SQLParserHelper.parse_string(Enum.at(vals, 2))
        field_type_id = SQLParserHelper.parse_int(Enum.at(vals, 3))
        template_id = SQLParserHelper.parse_int(Enum.at(vals, 4))
        status = SQLParserHelper.parse_int(Enum.at(vals, 5))
        created_at = SQLParserHelper.parse_datetime(Enum.at(vals, 6)) || now
        updated_at = SQLParserHelper.parse_datetime(Enum.at(vals, 7)) || now
        deleted_at = SQLParserHelper.parse_datetime(Enum.at(vals, 8))
        is_mandatory = SQLParserHelper.parse_int(Enum.at(vals, 9)) || 0
        policyidentifier_id = SQLParserHelper.parse_int(Enum.at(vals, 10))
        description = SQLParserHelper.parse_string(Enum.at(vals, 11)) || ""
        fieldgrouping_id = SQLParserHelper.parse_string(Enum.at(vals, 12))
        created_by = SQLParserHelper.parse_int(Enum.at(vals, 13))
        updated_by = SQLParserHelper.parse_int(Enum.at(vals, 14))

        Repo.insert_all(
          MasterPolicyFeatureTemplateField,
          [%{
            template_field_id: template_field_id,
            policy_feature_template_field_name: name,
            policy_feature_template_field_placeholder: placeholder,
            ref_master_temp_field_Type: field_type_id,
            ref_template_id: template_id,
            status: status,
            is_mandatory: is_mandatory,
            ref_policyidentifier_id: policyidentifier_id,
            field_description: description,
            ref_fieldgrouping_id: fieldgrouping_id,
            created_by: created_by,
            updated_by: updated_by,
            created_at: created_at,
            updated_at: updated_at,
            deleted_at: deleted_at
          }]
        )
        acc + 1
      end)

      IO.puts("Successfully seeded #{inserted_count} Master Policy Feature Template Fields from SQL reference!")
    _ ->
      IO.puts("Error: INSERT INTO master_policy_feature_template_fields VALUES not found in SQL file.")
  end
else
  IO.puts("Warning: live_vibe_engine_master_policy_feature_template_fields.sql not found at #{sql_path}")
end
