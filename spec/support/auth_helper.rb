module AuthHelper
  def self.before_action(*_foo_); end
  include TokenAuth

  def authenticate(user)
    token = generate_token(user)
    request.headers['Authorization'] = "Token #{token}"
  end
end

RSpec.configure do |config|
  config.include AuthHelper
end
