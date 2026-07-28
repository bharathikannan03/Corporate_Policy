defmodule CorporatePolicy.Emails do
  @moduledoc """
  Constructs emails sent by the application.
  """
  import Swoosh.Email

  @doc """
  Builds the welcome/credentials email for a new corporate contact.
  """
  def welcome_contact(user, plain_text_password) do
    from_email =
      System.get_env("SENDER_EMAIL") || System.get_env("RESEND_FROM_EMAIL") ||
        "no-reply@corppolicy.com"

    new()
    |> to({user.full_name, user.email_address})
    |> from({"CorpPolicy Portal", from_email})
    |> subject("Welcome to CorpPolicy Admin Portal")
    |> html_body("""
      <div style="font-family: 'Inter', sans-serif; color: #1e293b; max-width: 600px; margin: 0 auto; padding: 20px; border: 1px solid #e2e8f0; border-radius: 12px;">
        <h2 style="color: #2563eb;">Welcome to CorpPolicy Portal</h2>
        <p>Dear #{user.full_name},</p>
        <p>Your corporate contact account has been created successfully. You can now access your corporate dashboard using the credentials below:</p>
        
        <div style="background-color: #f8fafc; border: 1.5px solid #e2e8f0; border-radius: 8px; padding: 16px; margin: 20px 0;">
          <p style="margin: 0 0 8px 0;"><strong>Portal URL:</strong> <a href="http://localhost:4000/" style="color: #2563eb; text-decoration: none;">http://localhost:4000/</a></p>
          <p style="margin: 0 0 8px 0;"><strong>Username:</strong> #{user.email_address}</p>
          <p style="margin: 0;"><strong>Password:</strong> #{plain_text_password}</p>
        </div>
        
        <p style="font-size: 13px; color: #64748b;">For security reasons, we recommend changing your password after logging in.</p>
        <p style="margin-top: 24px; border-t: 1px solid #f1f5f9; padding-top: 16px;">
          Best regards,<br/>
          <strong>CorpPolicy Team</strong>
        </p>
      </div>
    """)
    |> text_body("""
      Welcome to CorpPolicy Portal

      Dear #{user.full_name},

      Your corporate contact account has been created successfully. You can now access your corporate dashboard using the credentials below:

      Portal URL: http://localhost:4000/
      Username: #{user.email_address}
      Password: #{plain_text_password}

      For security reasons, we recommend changing your password after logging in.

      Best regards,
      CorpPolicy Team
    """)
  end
end
