# Be sure to restart your server when you modify this file.

# Avoid CORS issues when API is called from the frontend app.
# Handle Cross-Origin Resource Sharing (CORS) in order to accept cross-origin AJAX requests.

# Read more: https://github.com/cyu/rack-cors

POTENTIAL_DEV_HOSTS = ['localhost'].freeze
POTENTIAL_DEV_PORTS = [3000, 3001, 6006, 8000, 8080, 8888, 9009].freeze
DEV_ORIGINS = POTENTIAL_DEV_HOSTS + POTENTIAL_DEV_HOSTS.map { |host| POTENTIAL_DEV_PORTS.map { |port| "#{host}:#{port}" } }.flatten.freeze

Rails.application.config.middleware.insert_before 0, Rack::Cors do
  allow do
    case Rails.env
    when 'production'
      origins 'CHANGEME_DOMAIN_NAME', 'CHANGEME_FIREBASE_URL'
    when 'development', 'test'
      origins(*DEV_ORIGINS)
    else
      raise "No CORS config for this Rails.env: #{Rails.env}"
    end

    resource '*',
             headers: :any,
             credentials: true,
             methods: %i[get post put patch delete options head]
  end
end
