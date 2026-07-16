defmodule CorporatePolicy.MailQueueTest do
  use CorporatePolicyWeb.ConnCase, async: false
  import Swoosh.TestAssertions

  alias CorporatePolicy.Accounts
  alias CorporatePolicy.Corporates
  alias CorporatePolicy.Emails.MailQueue

  setup do
    Process.register(self(), :test_process)

    # Start a local unsupervised MailQueue process for this test run
    queue_pid = start_supervised!({MailQueue, [name: :test_mail_queue]})
    Ecto.Adapters.SQL.Sandbox.allow(CorporatePolicy.Repo, self(), queue_pid)

    {:ok, user} =
      Accounts.create_user(%{
        first_name: "Test",
        last_name: "User",
        full_name: "Test User",
        email_address: "testuser@gmail.com",
        password: "temp_password123",
        status: 1
      })

    {:ok, user: user, queue: queue_pid}
  end

  test "queues welcome email, delivers it, and records a log", %{user: user, queue: queue} do
    MailQueue.queue_welcome_email(user, "temp_password123", queue)
    # Synchronize with the GenServer using :sys.get_state/1 twice
    # First get_state ensures the job is processed and deliver/1 is called (which sends {:email, email} to GenServer)
    _ = :sys.get_state(queue)
    # Second get_state ensures the GenServer has processed the forwarded email message
    _ = :sys.get_state(queue)

    assert_email_sent(
      to: {"Test User", "testuser@gmail.com"},
      subject: "Welcome to CorpPolicy Admin Portal"
    )

    assert Corporates.email_logged?(user.id)

    log = CorporatePolicy.Repo.get_by(Corporates.ContactEmailLog, user_id: user.id)
    assert log.sent_status == "sent"
    assert log.error_message == nil
  end

  test "suppresses email delivery if duplicate (email already logged)", %{
    user: user,
    queue: queue
  } do
    {:ok, _log} =
      Corporates.create_email_log(%{
        user_id: user.id,
        sent_status: "sent"
      })

    MailQueue.queue_welcome_email(user, "another_password", queue)

    _ = :sys.get_state(queue)

    refute_email_sent(
      to: {"Test User", "testuser@gmail.com"},
      subject: "Welcome to CorpPolicy Admin Portal"
    )
  end
end
