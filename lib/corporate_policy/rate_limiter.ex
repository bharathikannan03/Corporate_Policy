defmodule CorporatePolicy.RateLimiter do
  use GenServer

  @table :login_rate_limiter
  @limit 5
  @window_ms 60_000

  def start_link(opts) do
    GenServer.start_link(__MODULE__, opts, name: __MODULE__)
  end

  @impl true
  def init(_opts) do
    :ets.new(@table, [:set, :public, :named_table, read_concurrency: true])
    schedule_cleanup()
    {:ok, %{}}
  end

  @doc """
  Checks if the request from the given IP address is allowed.
  Returns `{:ok, attempts_remaining}` if allowed, or `{:error, :rate_limited}` if blocked.
  """
  def check_rate(ip_address) do
    GenServer.call(__MODULE__, {:check_rate, ip_address})
  end

  def clear do
    GenServer.call(__MODULE__, :clear)
  end

  @impl true
  def handle_call(:clear, _from, state) do
    :ets.delete_all_objects(@table)
    {:reply, :ok, state}
  end

  @impl true
  def handle_call({:check_rate, ip_address}, _from, state) do
    now = System.monotonic_time(:millisecond)
    clean_old_attempts(ip_address, now)

    case :ets.lookup(@table, ip_address) do
      [{^ip_address, attempts}] ->
        if length(attempts) >= @limit do
          {:reply, {:error, :rate_limited}, state}
        else
          new_attempts = [now | attempts]
          :ets.insert(@table, {ip_address, new_attempts})
          {:reply, {:ok, @limit - length(new_attempts)}, state}
        end

      [] ->
        :ets.insert(@table, {ip_address, [now]})
        {:reply, {:ok, @limit - 1}, state}
    end
  end

  @impl true
  def handle_info(:cleanup, state) do
    now = System.monotonic_time(:millisecond)
    clean_all_old_attempts(now)
    schedule_cleanup()
    {:noreply, state}
  end

  defp clean_old_attempts(ip_address, now) do
    cutoff = now - @window_ms

    case :ets.lookup(@table, ip_address) do
      [{^ip_address, attempts}] ->
        filtered = Enum.filter(attempts, &(&1 > cutoff))

        if filtered == [] do
          :ets.delete(@table, ip_address)
        else
          :ets.insert(@table, {ip_address, filtered})
        end

      [] ->
        :ok
    end
  end

  defp clean_all_old_attempts(now) do
    keys = :ets.select(@table, [{{:"$1", :_}, [], [:"$1"]}])

    Enum.each(keys, fn key ->
      clean_old_attempts(key, now)
    end)
  end

  defp schedule_cleanup do
    Process.send_after(self(), :cleanup, @window_ms)
  end
end
