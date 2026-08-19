defmodule CorporatePolicy.TwoFactorClientTest do
  use ExUnit.Case, async: false

  alias CorporatePolicy.TwoFactorClient

  setup do
    original_config = Application.get_env(:corporate_policy, :two_factor)

    on_exit(fn ->
      Application.put_env(:corporate_policy, :two_factor, original_config)
    end)

    :ok
  end

  test "returns error if api_key is missing" do
    Application.put_env(:corporate_policy, :two_factor, api_key: nil)
    assert {:error, :missing_api_key} = TwoFactorClient.send_otp("9876543210", "123456")
  end

  test "returns error if mobile number is missing" do
    Application.put_env(:corporate_policy, :two_factor, api_key: "mock_key")
    assert {:error, :missing_mobile_number} = TwoFactorClient.send_otp(nil, "123456")
    assert {:error, :missing_mobile_number} = TwoFactorClient.send_otp("", "123456")
  end

  test "sends OTP successfully using stubbed Req without template" do
    Application.put_env(:corporate_policy, :two_factor,
      api_key: "mock_key",
      template_name: nil,
      req_options: [plug: {Req.Test, CorporatePolicy.TwoFactorClient}]
    )

    Req.Test.stub(CorporatePolicy.TwoFactorClient, fn conn ->
      # Validate URL components
      assert conn.request_path == "/API/V1/mock_key/SMS/9876543210/123456"
      assert conn.method == "GET"

      Req.Test.json(conn, %{"Status" => "Success", "Details" => "OTP Sent"})
    end)

    assert :ok = TwoFactorClient.send_otp("9876543210", "123456")
  end

  test "sends OTP successfully using stubbed Req with template" do
    Application.put_env(:corporate_policy, :two_factor,
      api_key: "mock_key",
      template_name: "MyTemplateName",
      req_options: [plug: {Req.Test, CorporatePolicy.TwoFactorClient}]
    )

    Req.Test.stub(CorporatePolicy.TwoFactorClient, fn conn ->
      assert conn.request_path == "/API/V1/mock_key/SMS/9876543210/123456/MyTemplateName"
      Req.Test.json(conn, %{"Status" => "Success", "Details" => "OTP Sent"})
    end)

    assert :ok = TwoFactorClient.send_otp("9876543210", "123456")
  end

  test "handles error response from 2Factor API" do
    Application.put_env(:corporate_policy, :two_factor,
      api_key: "mock_key",
      template_name: nil,
      req_options: [plug: {Req.Test, CorporatePolicy.TwoFactorClient}]
    )

    Req.Test.stub(CorporatePolicy.TwoFactorClient, fn conn ->
      Req.Test.json(conn, %{"Status" => "Error", "Details" => "Invalid API Key"})
    end)

    assert {:error, %{"Status" => "Error", "Details" => "Invalid API Key"}} =
             TwoFactorClient.send_otp("9876543210", "123456")
  end
end
