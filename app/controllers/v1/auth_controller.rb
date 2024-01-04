module V1
  class AuthController < ApplicationController
    include OauthAware

    skip_before_action :require_user_token, only: %i[auth request_password_reset reset_password]

    def auth
      @token = authenticate_user(auth_params[:email], auth_params[:password])
      @token ||= authenticate_identity
      if @token.blank?
        head :unauthorized
      else
        @user = @current_user
        render 'v1/user/show'
      end
    end

    def check
      head :ok
    end

    def request_password_reset
      @user = User.find_by(email: auth_params[:email].strip.downcase)
      @user&.send_password_reset
      head :ok
    end

    def reset_password
      if User.reset_password!(auth_params[:token], auth_params[:password])
        head :ok
      else
        head :unauthorized
      end
    end

    private

    def auth_params
      params.permit(:email, :password, :token)
    end
  end
end
