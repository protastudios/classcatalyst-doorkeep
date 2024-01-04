module V1
  class UserController < ApplicationController
    include OauthAware

    skip_before_action :require_user_token, only: %i[create confirm_email]
    load_and_authorize_resource

    def create
      @user = User.find_by(email: auth_params[:email]) || User.create!(create_params)
      @token = authenticate_user(auth_params[:email], auth_params[:password])
      if @token.present?
        link_identity!(@user)
        render :show
      else
        render_json_error 'This email address has already been registered'
      end
    end

    def show; end

    def confirm_email
      @user = User.find_by(email_validation_token: auth_params[:token])
      if @user.present?
        @user.email_validation_token = nil
        @user.save(validate: false)
        render json: 'Thanks. Your email has been confirmed.'
      else
        render json: 'Did not find validation code. Please try signing up again.'
      end
    end

    def update
      @user = current_user

      if @user.update(update_params)
        render :show
      else
        render_json_error 'Unable to update user', messages: @user.errors.messages
      end
    end

    def destroy
      result = @user.destroy
      if result.respond_to?(:errors) && result.errors.present?
        render_json_error 'Unable to remove user', messages: resource.errors.messages
      else
        render json: { status: 'success' }
      end
    end

    private

    def auth_params
      params.require(:user).permit(:email, :password, :token)
    end

    def update_params
      params.require(:user).permit(:first_name, :last_name)
    end

    def create_params
      params.require(:user).permit(
        :email,
        :first_name,
        :last_name,
        :name,
        :password,
        :password_confirmation
      )
    end
  end
end
