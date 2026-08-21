defmodule CorporatePolicy.Policies.SampleDocuments do
  @moduledoc """
  Encapsulates access to the centrally defined sample/template documents.
  """

  @doc """
  Retrieves sample document metadata based on the upload/data type name.
  """
  def get_sample_document(type) do
    case type do
      "Inception Data" ->
        {:ok,
         %{
           filename: "inception_template.csv",
           path: "/uploads/samples/inception_template.csv",
           content_type: "text/csv"
         }}

      "Endorsement Data" ->
        {:ok,
         %{
           filename: "endorsement_template.csv",
           path: "/uploads/samples/endorsement_template.csv",
           content_type: "text/csv"
         }}

      "Claim Dumps" ->
        {:ok,
         %{
           filename: "claim_template.csv",
           path: "/uploads/samples/claim_template.csv",
           content_type: "text/csv"
         }}

      "Ecards" ->
        {:ok,
         %{
           filename: "ecard_template.zip",
           path: "/uploads/samples/ecard_template.zip",
           content_type: "application/zip"
         }}

      "CD Statement" ->
        {:ok,
         %{
           filename: "cd_ledger.csv",
           path: "/uploads/samples/cd_ledger.csv",
           content_type: "text/csv"
         }}

      _ ->
        {:error, "Unknown sample document type"}
    end
  end
end
