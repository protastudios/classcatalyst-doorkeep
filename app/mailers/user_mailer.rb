class UserMailer < ApplicationMailer
  default from: 'CHANGEME <hello@CHANGEME_DOMAIN_NAME>'

  def private_beta_invite(to_email, invite_code)
    @invite_code = invite_code
    mail(to: to_email, subject: t('.subject'), cc: from_email)
  end

  def password_reset(to_email, password_reset_token)
    encoded_token = ERB::Util.url_encode(password_reset_token)
    @token_url = "https://CHANGEME/reset_password/#{encoded_token}"
    logger.info "The URL is #{@token_url}" if Rails.env.development?
    mail(to: to_email, subject: t('.subject'))
  end

  def confirm_email(to_email, email_verification_token)
    encoded_token = ERB::Util.url_encode(email_verification_token)
    @token_url = "https://CHANGEME/confirm_email/#{encoded_token}"
    logger.info "The URL is #{@token_url}" if Rails.env.development?
    mail(to: to_email, subject: t('.subject'))
  end
end
