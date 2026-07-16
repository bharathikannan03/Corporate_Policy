defmodule CorporatePolicy.Utils.CSVParser do
  @moduledoc """
  A simple, dependency-free CSV parser utility to handle CSV files line-by-line,
  properly escaping double quotes and handling commas inside quoted fields.
  """

  @doc """
  Parses a CSV line into a list of strings.
  """
  def parse_line(line) do
    line
    |> String.trim_trailing()
    |> do_parse_line([], "")
  end

  defp do_parse_line("", acc, current_field) do
    Enum.reverse([current_field | acc])
  end

  defp do_parse_line(<<?", rest::binary>>, acc, "") do
    parse_quoted(rest, acc, "")
  end

  defp do_parse_line(<<?,, rest::binary>>, acc, current_field) do
    do_parse_line(rest, [current_field | acc], "")
  end

  defp do_parse_line(<<char::utf8, rest::binary>>, acc, current_field) do
    do_parse_line(rest, acc, current_field <> <<char::utf8>>)
  end

  defp parse_quoted(<<?", ?", rest::binary>>, acc, current_field) do
    parse_quoted(rest, acc, current_field <> "\"")
  end

  defp parse_quoted(<<?", ?,, rest::binary>>, acc, current_field) do
    do_parse_line(rest, [current_field | acc], "")
  end

  defp parse_quoted(<<?">>, acc, current_field) do
    Enum.reverse([current_field | acc])
  end

  defp parse_quoted(<<char::utf8, rest::binary>>, acc, current_field) do
    parse_quoted(rest, acc, current_field <> <<char::utf8>>)
  end
end
