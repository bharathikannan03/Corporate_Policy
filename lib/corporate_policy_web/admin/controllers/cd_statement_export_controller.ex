defmodule CorporatePolicyWeb.Admin.CdStatementExportController do
  use CorporatePolicyWeb, :controller

  alias CorporatePolicy.CdStatements

  def export(conn, %{"policy_id" => policy_id_param}) do
    with {policy_id, ""} <- Integer.parse(policy_id_param) do
      rows = CdStatements.list_policy_cd_statement_rows_for_export(policy_id)

      csv =
        [
          [
            "#",
            "Policy Number",
            "Particular",
            "Debit Amount (DR)",
            "Credit Amount (CR)",
            "Policy Endorsement No",
            "Endorsement Issued Date",
            "Bank Name",
            "Cheque No",
            "Remark",
            "Created At"
          ]
          | Enum.with_index(rows, 1)
            |> Enum.map(fn {row, index} ->
              [
                index,
                row.policy_number,
                row.particular,
                if(row.debit_amount, do: Decimal.to_string(row.debit_amount), else: ""),
                if(row.credit_amount, do: Decimal.to_string(row.credit_amount), else: ""),
                row.policy_endorsement_no || "",
                row.endorsement_issued_date || "",
                row.bank_name || "",
                row.cheque_no || "",
                row.remark || "",
                Calendar.strftime(row.inserted_at, "%d-%m-%Y %H:%M")
              ]
            end)
        ]
        |> NimbleCSV.RFC4180.dump_to_iodata()

      conn
      |> put_resp_content_type("text/csv")
      |> put_resp_header(
        "content-disposition",
        ~s(attachment; filename="cd_statements_#{policy_id}.csv")
      )
      |> send_resp(200, csv)
    else
      _ ->
        conn
        |> put_flash(:error, "Invalid policy id for CD Statement export.")
        |> redirect(to: ~p"/admin/policy-details")
    end
  end
end
