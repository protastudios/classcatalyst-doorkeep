Rails.application.config.middleware.use OmniAuth::Builder do
  # Support the NO SECURITY developer provider for non-production testing
  provider :developer unless Rails.env.production?

  # LinkedIn
  linkedin_key = ENV['LINKEDIN_KEY'] || Rails.application.credentials.dig(:linkedin, :key)
  linkedin_secret = ENV['LINKEDIN_SECRET'] || Rails.application.credentials.dig(:linkedin, :secret)
  provider :linkedin, linkedin_key, linkedin_secret if linkedin_key.present?

  # Facebook
  fb_id = ENV['FACEBOOK_ID'] || Rails.application.credentials.dig(:facebook, :id)
  fb_secret = ENV['FACEBOOK_SECRET'] || Rails.application.credentials.dig(:facebook, :secret)
  provider :facebook, fb_id, fb_secret, scope: 'email,user_friends,public_profile' if fb_id.present?
end
