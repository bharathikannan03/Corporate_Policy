# priv/repo/seeds/md_line_of_businesses.exs
alias CorporatePolicy.Repo
alias CorporatePolicy.Policies.LineOfBusiness

lobs = [
  %{line_of_business_value: "Health", display_id: 1, status: 1},
  %{line_of_business_value: "Life", display_id: 2, status: 1},
  %{line_of_business_value: "Others", display_id: 3, status: 1}
]

Enum.each(lobs, fn attrs ->
  case Repo.get_by(LineOfBusiness, line_of_business_value: attrs.line_of_business_value) do
    nil ->
      %LineOfBusiness{} |> LineOfBusiness.changeset(attrs) |> Repo.insert!()
      IO.puts("✓ LOB: #{attrs.line_of_business_value}")

    _ ->
      :ok
  end
end)
