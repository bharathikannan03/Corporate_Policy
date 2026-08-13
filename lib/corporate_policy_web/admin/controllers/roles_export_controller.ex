defmodule CorporatePolicyWeb.Admin.RolesExportController do
  use CorporatePolicyWeb, :controller

  alias CorporatePolicy.Corporates

  def export(conn, _params) do
    records = Corporates.list_roles_configurations()
    csv_data = generate_csv(records)

    conn
    |> put_resp_content_type("text/csv")
    |> send_download({:binary, csv_data}, filename: "roles_configuration_export.csv")
  end

  defp generate_csv(records) do
    headers = [
      "SI NO",
      "Role Name",
      "Access",
      "Mapped To",
      "Status"
    ]

    rows =
      Enum.with_index(records, 1)
      |> Enum.map(fn {rec, index} ->
        status_text = if rec.status == 1, do: "Active", else: "Inactive"
        access_text = Enum.join(rec.access_lines, "; ")

        [
          index,
          rec.role,
          access_text,
          rec.mapped_to_text,
          status_text
        ]
        |> Enum.map(&escape_csv_field/1)
        |> Enum.join(",")
      end)

    ([Enum.join(headers, ",")] ++ rows)
    |> Enum.join("\r\n")
  end

  defp escape_csv_field(nil), do: ""

  defp escape_csv_field(value) do
    str = to_string(value)

    if String.contains?(str, [",", "\"", "\n", "\r"]) do
      "\"" <> String.replace(str, "\"", "\"\"") <> "\""
    else
      str
    end
  end
end
