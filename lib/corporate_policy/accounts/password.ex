defmodule CorporatePolicy.Accounts.Password do
  @moduledoc false

  @algorithm "pbkdf2_sha256"
  @digest :sha256
  @iterations 100_000
  @key_length 32
  @salt_length 16

  def hash_password(password) when is_binary(password) do
    salt = random_salt()
    encoded_hash = derive_hash(password, salt, @iterations)

    Enum.join([@algorithm, Integer.to_string(@iterations), salt, encoded_hash], "$")
  end

  def valid_password?(password, stored_password)
      when is_binary(password) and is_binary(stored_password) do
    case String.split(stored_password, "$", parts: 4) do
      [@algorithm, iterations, salt, encoded_hash] ->
        verify_pbkdf2_password(password, iterations, salt, encoded_hash)

      _ ->
        legacy_sha256(password) == stored_password
    end
  end

  def valid_password?(_, _), do: false

  defp verify_pbkdf2_password(password, iterations, salt, encoded_hash) do
    case Integer.parse(iterations) do
      {parsed_iterations, ""} ->
        parsed_hash = derive_hash(password, salt, parsed_iterations)
        secure_compare(parsed_hash, encoded_hash)

      _ ->
        false
    end
  end

  defp derive_hash(password, salt, iterations) do
    salt
    |> Base.url_decode64!(padding: false)
    |> then(&:crypto.pbkdf2_hmac(@digest, password, &1, iterations, @key_length))
    |> Base.url_encode64(padding: false)
  end

  defp random_salt do
    @salt_length
    |> :crypto.strong_rand_bytes()
    |> Base.url_encode64(padding: false)
  end

  defp secure_compare(left, right) when byte_size(left) == byte_size(right) do
    :crypto.hash_equals(left, right)
  end

  defp secure_compare(_, _), do: false

  defp legacy_sha256(password) do
    :crypto.hash(:sha256, password)
    |> Base.encode16(case: :lower)
  end
end
