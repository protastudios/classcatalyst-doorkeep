Rails.application.configure do
  config.lograge.enabled = !Rails.env.test?
end
