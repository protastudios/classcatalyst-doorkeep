module VerifiedEmail
  extend ActiveSupport::Concern
  include TokenGenerator

  included do
    before_validation :sanitize_email
    validates :email, presence: true, uniqueness: true, format: { with: /\A[^@\s]+@([^@\s]+\.)+[^@\s]+\z/ }
    before_save :generate_email_validation_token, if: proc { |u| u.new_record? }
    after_create :send_email_confirm
  end

  def send_email_confirm
    UserMailer.confirm_email(email, email_validation_token).deliver_later
  end

  private

  def sanitize_email
    self.email = email.strip.delete(' ').downcase if email.present?
  end

  def generate_email_validation_token
    set_token(:email_validation_token)
  end
end
