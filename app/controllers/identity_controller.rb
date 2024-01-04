class IdentityController < ApplicationController
  include OauthAware

  skip_before_action :httpauth
  skip_before_action :require_user_token

  include ActionController::Cookies

  def auth
    if bad_hash
      head :not_found
      return
    end

    @identity = Identity.find_or_create_from_auth_hash(auth_hash)
    store_identity_cookie(@identity.id)
    redirect_to request.env['omniauth.origin'] || '/'
  end

  protected

  def auth_hash
    request.env['omniauth.auth']
  end

  private

  def bad_hash
    auth_hash.blank? || auth_hash['uid'].blank? || params[:provider] != auth_hash['provider']
  end
end
