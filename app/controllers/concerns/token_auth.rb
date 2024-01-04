module TokenAuth
  extend ActiveSupport::Concern
  include ActionController::HttpAuthentication::Token::ControllerMethods

  included do
    before_action :require_user_token
  end

  def current_user
    @current_user ||= find_user_for_jwt(raw_auth_token)
  end

  protected

  # Ensure we have a valid JWT token for this request
  def require_user_token
    authenticate_or_request_with_http_token do |raw_token, _options|
      @current_user = find_user_for_jwt(raw_token)
    end
  end

  # Set current_user and return a JWT if email/password combo is valid
  def authenticate_user(email, password)
    user = User.find_by(email: email)
    return nil unless user&.authenticate(password)

    @current_user = user
    generate_token(@current_user)
  end

  private

  AUTH_HEADER = 'Authorization'.freeze
  TOKEN_SCAN = /^(?:Bearer|Token) (.*)$/i.freeze

  def raw_auth_token
    return nil if request.headers[AUTH_HEADER].blank?

    auth = request.headers[AUTH_HEADER].to_s
    auth.scan(TOKEN_SCAN).flatten.last
  end

  def find_user_for_jwt(raw_token)
    return nil if raw_token.blank?

    token = extract_token(raw_token)
    return nil if token.blank?

    payload, _meta = token
    User.find(payload['uid']) if payload && payload['uid']
  end

  def jwt_private_key
    @jwt_private_key ||= RbNaCl::Signatures::Ed25519::SigningKey.new(Rails.application.key_generator.generate_key('jwt', 32))
  end

  def jwt_public_key
    @jwt_public_key ||= jwt_private_key.verify_key
  end

  JWT_ALGO = 'ED25519'.freeze
  JWT_DURATION = 1.hour

  def generate_token(user, extra = {})
    payload = extra.merge(uid: user.uid)
    headers = { typ: 'JWT', exp: (Time.current + JWT_DURATION).to_i }
    JWT.encode(payload, jwt_private_key, JWT_ALGO, headers)
  end

  def extract_token(raw_token)
    JWT.decode(raw_token, jwt_public_key, true, algorithm: JWT_ALGO)
  rescue JWT::ExpiredSignature
    nil
  end
end
