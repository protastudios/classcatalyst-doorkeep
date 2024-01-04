require 'jwt'
require 'rbnacl'

class ApplicationController < ActionController::API
  include ActionController::HttpAuthentication::Basic::ControllerMethods
  include TokenAuth
  include JsonApi

  before_action :httpauth
  before_action :ensure_cannonical_host
  before_action :load_global_settings

  def load_global_settings
    @global_settings = Rails.cache.fetch('global_settings', expires_in: 30.seconds) do
      GlobalSetting.order(:name).to_a.each_with_object({}) do |setting, map|
        map[setting.name] = setting.value
      end
    end
  end

  def ensure_cannonical_host
    # quick check to ensure people aren't using our heroku url or whatnot
    host = ENV['WWW_HOST']
    redirect_to "https://#{host}#{request.fullpath}" if host.present? && request.host != host
  end

  def httpauth
    return if current_user.present? # Bypass http_basic if user is already authenticated
    return unless Rails.env.production? && ENV['OPEN_TO_PUBLIC'].blank?

    authenticate_or_request_with_http_basic do |user_name, password|
      user_name == 'CHANGEME' && password == 'CHANGEME'
    end
  end
end
