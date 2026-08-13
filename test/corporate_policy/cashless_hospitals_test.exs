defmodule CorporatePolicy.CashlessHospitalsTest do
  use CorporatePolicy.DataCase, async: true

  alias CorporatePolicy.Policies
  alias CorporatePolicy.Repo

  alias CorporatePolicy.Policies.{
    Insurer,
    Tpa,
    CashlessHospitalUpload
  }

  setup do
    lob =
      Repo.insert!(%CorporatePolicy.Policies.LineOfBusiness{
        line_of_business_value: "Health",
        display_id: 1,
        status: 1
      })

    insurer =
      Repo.insert!(%Insurer{
        name: "Test Insurer Acko",
        ref_md_line_of_businesses_id: lob.id,
        status: 1
      })

    tpa =
      Repo.insert!(%Tpa{
        name: "Test Tpa Internal",
        status: 1
      })

    {:ok, insurer: insurer, tpa: tpa}
  end

  test "search insurers and TPAs by name", %{insurer: insurer, tpa: tpa} do
    assert [i] = Policies.search_insurers_by_name("Acko")
    assert i.id == insurer.id

    assert [t] = Policies.search_tpas_by_name("Internal")
    assert t.id == tpa.id

    assert [] = Policies.search_insurers_by_name("NonExistent")
    assert [] = Policies.search_tpas_by_name("NonExistent")
  end

  test "create_cashless_hospital_import parses CSV and inserts records", %{
    insurer: insurer,
    tpa: tpa
  } do
    csv_content = """
    Hospital Name,Hospital Address,Location,Landmark,City,State,Pincode,Email,Std Code,Phone,Latitude,Longitude
    Appolo Hospital,123 Main Road,Downtown,Near Park,Chennai,Tamil Nadu,600001,appolo@example.com,044,2837382,12.9715987,77.5945627
    """

    tmp_path = Path.join(System.tmp_dir!(), "cashless_test.csv")
    File.write!(tmp_path, csv_content)

    attrs = %{
      ref_insurer_id: insurer.id,
      insurer_name: insurer.name,
      ref_tpa_id: tpa.id,
      tpa_name: tpa.name,
      ch_upload_data: tmp_path,
      original_file_name: "cashless_test.csv"
    }

    assert {:ok, cashless_hospital} = Policies.create_cashless_hospital_import(attrs)
    assert cashless_hospital.ref_insurer_id == insurer.id
    assert cashless_hospital.ref_tpa_id == tpa.id
    assert cashless_hospital.original_file_name == "cashless_test.csv"

    # Verify upload rows
    uploads = Repo.all(CashlessHospitalUpload)
    assert length(uploads) == 1
    [upload] = uploads
    assert upload.hospital_name == "Appolo Hospital"
    assert upload.hospital_address == "123 Main Road"
    assert upload.city == "Chennai"
    assert upload.state == "Tamil Nadu"
    assert upload.pincode == 600_001
    assert upload.email == "appolo@example.com"
    assert upload.phone == "2837382"
    assert upload.ref_insurer_id == insurer.id
    assert upload.ref_tpa_id == to_string(tpa.id)
    assert Decimal.to_float(upload.latitude) == 12.9715987
    assert Decimal.to_float(upload.longitude) == 77.5945627

    # Verify paginated listing
    result = Policies.list_cashless_hospitals_paginated()
    assert result.total_entries == 1
    assert length(result.entries) == 1
    assert Enum.at(result.entries, 0).insurer_name == insurer.name

    # Test Corporate TPA filtering and pagination
    res_tpa = Policies.list_cashless_hospitals_by_tpa_paginated(tpa.id)
    assert res_tpa.total_entries == 1
    assert length(res_tpa.entries) == 1
    assert Enum.at(res_tpa.entries, 0).hospital_name == "Appolo Hospital"

    # Test search
    res_search = Policies.list_cashless_hospitals_by_tpa_paginated(tpa.id, search: "Appolo")
    assert res_search.total_entries == 1

    res_no_match =
      Policies.list_cashless_hospitals_by_tpa_paginated(tpa.id, search: "NonExistent")

    assert res_no_match.total_entries == 0

    # Test CSV Export
    csv_data = Policies.export_cashless_hospitals_csv(tpa.id)
    assert String.contains?(csv_data, "HOSPITAL NAME")
    assert String.contains?(csv_data, "Appolo Hospital")

    File.rm!(tmp_path)
  end
end
