defmodule CorporatePolicy.Corporates.LocationImporter do
  @moduledoc """
  Provides reusable functions to parse and bulk-import States, Cities, Pincodes,
  and their mappings from CSV files into the database.
  """
  require Logger
  alias CorporatePolicy.Repo
  alias CorporatePolicy.Corporates.State
  alias CorporatePolicy.Corporates.City
  alias CorporatePolicy.Corporates.Pincode
  alias CorporatePolicy.Corporates.TrnMappingPincodeCityState
  alias CorporatePolicy.Utils.CSVParser

  @doc """
  Imports States from a CSV file.
  """
  def import_states(csv_path) do
    Logger.info("Starting States import from: #{csv_path}")
    now = DateTime.utc_now() |> force_usec()

    result =
      csv_path
      |> File.stream!()
      # Drop header
      |> Stream.drop(1)
      |> Stream.map(&CSVParser.parse_line/1)
      |> Stream.map(fn [
                         state_id_str,
                         state,
                         status_str,
                         created_at_str,
                         updated_at_str,
                         deleted_at_str
                       ] ->
        %{
          state_id: parse_integer(state_id_str),
          state: state,
          status: parse_integer(status_str),
          inserted_at: get_timestamp(created_at_str, now),
          updated_at: get_timestamp(updated_at_str, now),
          deleted_at: parse_datetime(deleted_at_str)
        }
      end)
      |> Stream.chunk_every(1000)
      |> Enum.reduce({0, 0}, fn chunk, {inserted, skipped} ->
        {count, _} = Repo.insert_all(State, chunk, on_conflict: :nothing)
        {inserted + count, skipped + (length(chunk) - count)}
      end)

    reset_sequence("md_states", "state_id")

    Logger.info(
      "Finished States import: #{elem(result, 0)} inserted, #{elem(result, 1)} skipped."
    )

    result
  end

  @doc """
  Imports Cities from a CSV file.
  """
  def import_cities(csv_path) do
    Logger.info("Starting Cities import from: #{csv_path}")
    now = DateTime.utc_now() |> force_usec()

    result =
      csv_path
      |> File.stream!()
      # Drop header
      |> Stream.drop(1)
      |> Stream.map(&CSVParser.parse_line/1)
      |> Stream.map(fn [
                         city_id_str,
                         city,
                         status_str,
                         created_at_str,
                         updated_at_str,
                         deleted_at_str
                       ] ->
        %{
          city_id: parse_integer(city_id_str),
          city: city,
          status: parse_integer(status_str),
          inserted_at: get_timestamp(created_at_str, now),
          updated_at: get_timestamp(updated_at_str, now),
          deleted_at: parse_datetime(deleted_at_str)
        }
      end)
      |> Stream.chunk_every(1000)
      |> Enum.reduce({0, 0}, fn chunk, {inserted, skipped} ->
        {count, _} = Repo.insert_all(City, chunk, on_conflict: :nothing)
        {inserted + count, skipped + (length(chunk) - count)}
      end)

    reset_sequence("md_cities", "city_id")

    Logger.info(
      "Finished Cities import: #{elem(result, 0)} inserted, #{elem(result, 1)} skipped."
    )

    result
  end

  @doc """
  Imports Pincodes from a CSV file.
  """
  def import_pincodes(csv_path) do
    Logger.info("Starting Pincodes import from: #{csv_path}")
    now = DateTime.utc_now() |> force_usec()

    result =
      csv_path
      |> File.stream!()
      # Drop header
      |> Stream.drop(1)
      |> Stream.map(&CSVParser.parse_line/1)
      |> Stream.map(fn [
                         pincode_id_str,
                         pincode_str,
                         status_str,
                         created_at_str,
                         updated_at_str,
                         deleted_at_str
                       ] ->
        %{
          pincode_id: parse_integer(pincode_id_str),
          pincode: parse_integer(pincode_str),
          status: parse_integer(status_str),
          inserted_at: get_timestamp(created_at_str, now),
          updated_at: get_timestamp(updated_at_str, now),
          deleted_at: parse_datetime(deleted_at_str)
        }
      end)
      |> Stream.chunk_every(1000)
      |> Enum.reduce({0, 0}, fn chunk, {inserted, skipped} ->
        {count, _} = Repo.insert_all(Pincode, chunk, on_conflict: :nothing)
        {inserted + count, skipped + (length(chunk) - count)}
      end)

    reset_sequence("md_pincodes", "pincode_id")

    Logger.info(
      "Finished Pincodes import: #{elem(result, 0)} inserted, #{elem(result, 1)} skipped."
    )

    result
  end

  @doc """
  Imports Pincode-City-State Mappings from a CSV file.
  """
  def import_mappings(csv_path) do
    Logger.info("Starting Pincode-City-State mappings import from: #{csv_path}")
    now = DateTime.utc_now() |> force_usec()

    result =
      csv_path
      |> File.stream!()
      # Drop header
      |> Stream.drop(1)
      |> Stream.map(&CSVParser.parse_line/1)
      |> Stream.map(fn [
                         id_str,
                         pincode_id_str,
                         city_id_str,
                         state_id_str,
                         status_str,
                         created_at_str,
                         updated_at_str,
                         deleted_at_str
                       ] ->
        %{
          id: parse_integer(id_str),
          pincode_id: parse_integer(pincode_id_str),
          city_id: parse_integer(city_id_str),
          state_id: parse_integer(state_id_str),
          status: parse_integer(status_str),
          inserted_at: get_timestamp(created_at_str, now),
          updated_at: get_timestamp(updated_at_str, now),
          deleted_at: parse_datetime(deleted_at_str)
        }
      end)
      |> Stream.chunk_every(1000)
      |> Enum.reduce({0, 0}, fn chunk, {inserted, skipped} ->
        {count, _} = Repo.insert_all(TrnMappingPincodeCityState, chunk, on_conflict: :nothing)
        {inserted + count, skipped + (length(chunk) - count)}
      end)

    reset_sequence("trn_mapping_pincode_city_states", "id")

    Logger.info(
      "Finished Pincode-City-State mappings import: #{elem(result, 0)} inserted, #{elem(result, 1)} skipped."
    )

    result
  end

  # Helper Functions

  defp parse_integer("NULL"), do: 0
  defp parse_integer(""), do: 0
  defp parse_integer(nil), do: 0

  defp parse_integer(str) do
    case Integer.parse(str) do
      {num, _} -> num
      _ -> 0
    end
  end

  defp parse_datetime("NULL"), do: nil
  defp parse_datetime(""), do: nil
  defp parse_datetime(nil), do: nil

  defp parse_datetime(str) do
    normalized = String.replace(str, " ", "T")

    case NaiveDateTime.from_iso8601(normalized) do
      {:ok, naive} ->
        naive
        |> DateTime.from_naive!("Etc/UTC")
        |> force_usec()

      _ ->
        nil
    end
  end

  defp force_usec(%DateTime{microsecond: {us, _}} = dt) do
    %{dt | microsecond: {us, 6}}
  end

  defp get_timestamp(val, default) do
    case parse_datetime(val) do
      nil -> default
      dt -> dt
    end
  end

  defp reset_sequence(table, column) do
    query = "SELECT COALESCE(MAX(#{column}), 0) FROM #{table}"

    case Repo.query(query) do
      {:ok, %{rows: [[max_id]]}} when max_id > 0 ->
        seq_name = "#{table}_#{column}_seq"
        # Reset the bigserial auto-increment sequence in Postgres
        case Repo.query("SELECT setval('#{seq_name}', $1)", [max_id]) do
          {:ok, _} -> :ok
          error -> Logger.warning("Failed to reset sequence #{seq_name}: #{inspect(error)}")
        end

      _ ->
        :ok
    end
  end
end
