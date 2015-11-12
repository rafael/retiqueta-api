ActionMailer::Base.smtp_settings = {
  user_name: Rails.application.secrets.smtp_user_name,
  password: Rails.application.secrets.smtp_password,
  domain: "www.retiqueta.com",
  address: "smtp.mandrillapp.com",
  port: 587,
  authentication: :login,
  enable_starttls_auto: true
}
