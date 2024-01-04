module JsonPayload
  def payload
    JSON.parse(response.body)
  end
end

RSpec.configure do |config|
  config.include JsonPayload, type: :controller
  config.include JsonPayload, type: :request
end
