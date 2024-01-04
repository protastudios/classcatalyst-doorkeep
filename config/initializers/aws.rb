unless Rails.env.development? || Rails.env.test? || ENV['SEND_REAL_EMAIL']
  # Reroute all email for private production site (eg, a staging environment)
  class Hook
    def self.delivering_email(message)
      message.from = 'CHANGEME <CHANGEME@CHANGEME_DOMAIN_NAME>'
      message.to  = 'CHANGEME@CHANGEME_DOMAIN_NAME'
      message.cc  = nil unless message.cc.nil?
      message.bcc = nil unless message.bcc.nil?
    end
  end
  ActionMailer::Base.register_interceptor(Hook)
end

# Inject AWS credentials into SES client
id = ENV['AWS_ACCESS_KEY_ID'] || Rails.application.credentials.dig(:aws, :access_key_id)
key = ENV['AWS_SECRET_ACCESS_KEY'] || Rails.application.credentials.dig(:aws, :secret_access_key)
region = ENV['AWS_REGION'] || Rails.application.credentials.dig(:aws, :region) || 'us-east-1'
if id.present? && key.present?
  creds = Aws::Credentials.new(id, key)
  # Set default AWS config
  Aws.config.update(
    credentials: creds,
    region: region
  )
  Aws::Rails.add_action_mailer_delivery_method(:aws_sdk)
end
