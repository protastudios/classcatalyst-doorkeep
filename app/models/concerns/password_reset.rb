module PasswordReset
  extend ActiveSupport::Concern

  def generate_password_reset_token
    raise 'Missing email' if email.blank?

    payload = {
      email: email,
      exp: (Time.current + 2.hours).to_i
    }
    header = {
      typ: 'JWT'
    }
    JWT.encode(payload, password_reset_secret, 'HS256', header)
  end

  def send_password_reset
    token = generate_password_reset_token
    self.password_reset_token = token
    User.transaction do
      update_columns(password_reset_sent_at: Time.current, password_reset_token: token) # rubocop:disable Rails/SkipsModelValidations
      UserMailer.password_reset(email, password_reset_token).deliver_later
    end
  end

  class_methods do
    def reset_password!(token, password)
      return false if token.blank?

      transaction do
        subject = find_by(password_reset_token: token)
        subject&.reset_password!(token, password)
      end
    end
  end

  def reset_password!(token, password)
    return false unless verify_password_reset_token(token)

    update!(password: password)
  end

  def verify_password_reset_token(token)
    return false unless password_reset_token_valid?(token)

    clear_password_reset_token!
    true
  end

  def password_reset_token_valid?(token)
    return false unless password_reset_token.present? && password_reset_token == token

    payload, _header = JWT.decode(token, password_reset_secret, true, algorithm: 'HS256')
    payload['email'] == email
  rescue JWT::DecodeError
    false
  end

  private

  def clear_password_reset_token!
    update_columns(password_reset_token: nil, password_reset_sent_at: nil) # rubocop:disable Rails/SkipsModelValidations
    self.password_reset_token = nil
    self.password_reset_sent_at = nil
  end

  def password_reset_secret
    @password_reset_secret ||= Rails.application.key_generator.generate_key("pw_reset:#{id}")
  end
end
