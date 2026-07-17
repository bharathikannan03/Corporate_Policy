alias CorporatePolicy.Repo
alias CorporatePolicy.Policies.MappingPolicyFeatureTemplatesCorporatesPolicy

csv_path = "F:/Vibe elixir/vibe live Db/mapping_policy_feature_templates_corporates_policies.csv"

if File.exists?(csv_path) do
  # Very basic CSV parser for the exact file structure provided
  csv_path
  |> File.stream!()
  |> Stream.drop(1) # Drop header
  |> Stream.map(fn line ->
    line
    |> String.trim_trailing()
    |> String.split(",")
  end)
  |> Enum.each(fn
    # Simple matching if possible (this is fragile to commas inside quotes)
    # A real CSV parser like NimbleCSV should be used in production.
    [val_id, ref_name, val, ref_temp_id, ref_corp_id, ref_policy_id, ref_field_id, ref_type_id, vis_role_ids, status | _rest] ->
      try do
        mapping_data = %{
          policy_feature_template_field_value_id: String.to_integer(val_id),
          ref_policy_feature_template_field_name: String.replace(ref_name, "\"", ""),
          policy_feature_template_field_value: String.replace(val, "\"", ""),
          ref_template_id: if(ref_temp_id != "", do: String.to_integer(ref_temp_id), else: nil),
          ref_coporate_id: if(ref_corp_id != "", do: String.to_integer(ref_corp_id), else: nil),
          ref_policy_id: if(ref_policy_id != "", do: String.to_integer(ref_policy_id), else: nil),
          ref_policy_feature_template_field_id: if(ref_field_id != "", do: String.to_integer(ref_field_id), else: nil),
          ref_policy_feature_template_field_type_id: if(ref_type_id != "", do: String.to_integer(ref_type_id), else: nil),
          policy_feature_template_field_visibility_role_ids: vis_role_ids,
          status: if(status != "", do: String.to_integer(status), else: 0)
        }

        case Repo.get(MappingPolicyFeatureTemplatesCorporatesPolicy, mapping_data.policy_feature_template_field_value_id) do
          nil ->
            %MappingPolicyFeatureTemplatesCorporatesPolicy{}
            |> MappingPolicyFeatureTemplatesCorporatesPolicy.changeset(mapping_data)
            |> Ecto.Changeset.put_change(:policy_feature_template_field_value_id, mapping_data.policy_feature_template_field_value_id)
            |> Repo.insert!()
          
          existing ->
            existing
            |> MappingPolicyFeatureTemplatesCorporatesPolicy.changeset(mapping_data)
            |> Repo.update!()
        end
      rescue
        _ -> IO.puts("Failed to parse row: #{inspect val_id}")
      end
    _ -> nil
  end)
else
  IO.puts("CSV file not found for mapping seeds.")
end
