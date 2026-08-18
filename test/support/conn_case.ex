defmodule CorporatePolicyWeb.ConnCase do
  @moduledoc """
  This module defines the test case to be used by
  tests that require setting up a connection.

  Such tests rely on `Phoenix.ConnTest` and also
  import other functionality to make it easier
  to build common data structures and query the data layer.

  Finally, if the test case interacts with the database,
  we enable the SQL sandbox, so changes done to the database
  are reverted at the end of every test. If you are using
  PostgreSQL, you can even run database tests asynchronously
  by setting `use CorporatePolicyWeb.ConnCase, async: true`, although
  this option is not recommended for other databases.
  """

  use ExUnit.CaseTemplate

  using do
    quote do
      # The default endpoint for testing
      @endpoint CorporatePolicyWeb.Endpoint

      use CorporatePolicyWeb, :verified_routes

      # Import conveniences for testing with connections
      import Plug.Conn
      import Phoenix.ConnTest
      import CorporatePolicyWeb.ConnCase
    end
  end

  setup tags do
    CorporatePolicy.DataCase.setup_sandbox(tags)
    CorporatePolicy.DataCase.seed_roles_and_sequence()

    # Exclude modules that manage their own lookups
    excluded_modules = [
      CorporatePolicyWeb.Admin.ClaimSubmissionLiveTest,
      CorporatePolicyWeb.Admin.CdStatementUploadLiveTest,
      CorporatePolicyWeb.Admin.CdAccountsLiveTest,
      CorporatePolicyWeb.Corporate.CashlessHospitalsLiveTest,
      CorporatePolicyWeb.UploadControllerTest,
      CorporatePolicy.StringHandlingTest,
      CorporatePolicy.PoliciesTest,
      CorporatePolicy.DataUploadServiceTest,
      CorporatePolicy.ClaimsTest,
      CorporatePolicy.CdStatementsTest,
      CorporatePolicy.CashlessHospitalsTest
    ]

    unless tags.module in excluded_modules do
      CorporatePolicy.DataCase.seed_lookups()
    end

    if GenServer.whereis(CorporatePolicy.RateLimiter) do
      CorporatePolicy.RateLimiter.clear()
    end

    {:ok, conn: Phoenix.ConnTest.build_conn()}
  end
end
