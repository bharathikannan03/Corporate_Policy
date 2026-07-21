defmodule CorporatePolicy.StringUtils do
  @moduledoc false

  def normalize(nil), do: ""

  def normalize(value) when is_binary(value) do
    value
    |> String.trim()
  end

  def normalize(value), do: value |> to_string() |> normalize()

  def blank?(value), do: normalize(value) == ""

  def downcase(value) do
    value
    |> normalize()
    |> String.downcase()
  end

  def comparison_key(value) do
    value
    |> downcase()
    |> String.replace(~r/\s+/, " ")
  end

  def enum_key(value) do
    value
    |> comparison_key()
    |> String.replace(~r/[\s-]+/, "_")
  end

  def equal?(left, right), do: comparison_key(left) == comparison_key(right)

  def in?(value, values) do
    value_key = comparison_key(value)
    Enum.any?(values, &(comparison_key(&1) == value_key))
  end

  def canonicalize(value, allowed_values) do
    value_key = comparison_key(value)
    Enum.find(allowed_values, &(comparison_key(&1) == value_key))
  end

  def canonicalize_enum(value, allowed_values) do
    value_key = enum_key(value)
    Enum.find(allowed_values, &(enum_key(&1) == value_key))
  end
end
