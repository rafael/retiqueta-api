module FacebookClient
  module_function def koala
    @koala_client ||= Koala::Facebook::OAuth.new(
      Rails.application.secrets.fb_client_id,
      Rails.application.secrets.fb_client_secret
    )
  end
end
