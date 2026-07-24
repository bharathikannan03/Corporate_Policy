defmodule CorporatePolicy.Emails.MailQueue do
  use GenServer
  require Logger

  # Client API

  def start_link(opts \\ []) do
    GenServer.start_link(__MODULE__, :ok, Keyword.put_new(opts, :name, __MODULE__))
  end

  @doc """
  Queues a welcome email for a user with their temporary password.
  """
  def queue_welcome_email(user, password, queue \\ __MODULE__) do
    if queue == __MODULE__ and
         Application.get_env(:corporate_policy, :mail_queue_enabled, true) == false do
      :ok
    else
      GenServer.cast(queue, {:queue_email, user, password})
    end
  end

  # Server Callbacks

  @impl true
  def init(:ok) do
    {:ok, %{queue: :queue.new(), processing: false}}
  end

  @impl true
  def handle_cast({:queue_email, user, password}, state) do
    new_queue = :queue.in({user, password}, state.queue)
    new_state = %{state | queue: new_queue}

    if not state.processing do
      send(self(), :process_next)
      {:noreply, %{new_state | processing: true}}
    else
      {:noreply, new_state}
    end
  end

  @impl true
  def handle_info(:process_next, state) do
    case :queue.out(state.queue) do
      {{:value, {user, password}}, remaining_queue} ->
        process_job(user, password)
        send(self(), :process_next)
        {:noreply, %{state | queue: remaining_queue, processing: true}}

      {:empty, _} ->
        {:noreply, %{state | processing: false}}
    end
  end

  @impl true
  def handle_info({:email, _email} = msg, state) do
    test_pid = Process.whereis(:test_process)

    if test_pid do
      send(test_pid, msg)
    end

    {:noreply, state}
  end

  @impl true
  def handle_info(_msg, state) do
    {:noreply, state}
  end

  defp process_job(user, password) do
    # Check if the user is already logged
    if CorporatePolicy.Corporates.email_logged?(user.id) do
      Logger.debug("Email already sent to user #{user.id}. Skipping.")
    else
      email = CorporatePolicy.Emails.welcome_contact(user, password)

      case CorporatePolicy.Mailer.deliver(email) do
        {:ok, _metadata} ->
          CorporatePolicy.Corporates.create_email_log(%{
            user_id: user.id,
            sent_status: "sent"
          })

          Logger.info("Welcome email sent successfully to user #{user.id}")

        {:error, reason} ->
          CorporatePolicy.Corporates.create_email_log(%{
            user_id: user.id,
            sent_status: "failed",
            error_message: inspect(reason)
          })

          Logger.error("Failed to send welcome email to user #{user.id}: #{inspect(reason)}")
      end
    end
  rescue
    e ->
      Logger.error("Exception in MailQueue process_job for user #{user.id}: #{inspect(e)}")
      # Try to log the failure in DB
      try do
        CorporatePolicy.Corporates.create_email_log(%{
          user_id: user.id,
          sent_status: "failed",
          error_message: inspect(e)
        })
      rescue
        _ -> :ok
      end
  end
end
