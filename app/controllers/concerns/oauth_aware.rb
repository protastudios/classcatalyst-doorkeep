module OauthAware
  extend ActiveSupport::Concern
  include ActionController::Cookies
  include TokenAuth

  protected

  ID_COOKIE_KEY = 'si'.freeze

  def store_identity_cookie(id)
    cookies.encrypted[ID_COOKIE_KEY] = { value: id, httponly: true }
  end

  def check_identity_cookie
    identity_id = cookies.encrypted[ID_COOKIE_KEY]
    Identity.find(identity_id) if identity_id.present?
  end

  def clear_identity_cookie
    cookies.encrypted[ID_COOKIE_KEY] = nil
  end

  def authenticate_identity
    identity = check_identity_cookie
    return nil if identity.blank?

    @current_user = ensure_user(identity)
    return nil if @current_user.blank?

    clear_identity_cookie
    generate_token(@current_user, provider: identity.provider, provider_uid: identity.uid)
  end

  def link_identity!(user)
    identity = check_identity_cookie
    return nil if identity.blank?

    identity.link!(user)
    clear_identity_cookie
  end

  private

  def ensure_user(identity)
    if identity.user.blank?
      if @current_user
        identity.link!(@current_user)
      else
        identity.register
      end
    end
    identity.user
  end
end
