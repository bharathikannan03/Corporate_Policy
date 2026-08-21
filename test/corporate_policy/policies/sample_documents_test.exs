defmodule CorporatePolicy.Policies.SampleDocumentsTest do
  use CorporatePolicy.DataCase, async: true
  alias CorporatePolicy.Policies.SampleDocuments

  test "get_sample_document/1 returns path and filename for valid type" do
    assert {:ok,
            %{filename: "inception_template.csv", path: "/uploads/samples/inception_template.csv"}} =
             SampleDocuments.get_sample_document("Inception Data")

    assert {:ok,
            %{
              filename: "endorsement_template.csv",
              path: "/uploads/samples/endorsement_template.csv"
            }} =
             SampleDocuments.get_sample_document("Endorsement Data")

    assert {:ok, %{filename: "claim_template.csv", path: "/uploads/samples/claim_template.csv"}} =
             SampleDocuments.get_sample_document("Claim Dumps")

    assert {:ok, %{filename: "ecard_template.zip", path: "/uploads/samples/ecard_template.zip"}} =
             SampleDocuments.get_sample_document("Ecards")

    assert {:ok, %{filename: "cd_ledger.csv", path: "/uploads/samples/cd_ledger.csv"}} =
             SampleDocuments.get_sample_document("CD Statement")
  end

  test "get_sample_document/1 returns error for unknown type" do
    assert {:error, "Unknown sample document type"} =
             SampleDocuments.get_sample_document("Invalid Type")
  end
end
