class AdminController < ApplicationController
  # RailsAdmin support
  include AbstractController::Helpers
  include ActionController::Flash
  include ActionController::RequestForgeryProtection
  include ActionController::MimeResponds
  include ActionController::HttpAuthentication::Basic::ControllerMethods
  include ActionView::Layouts

  skip_before_action :require_user_token
  skip_before_action :force_json
  helper_method :current_user, :current_user!

  def current_user
    @current_user ||= begin
                        super || session_user
                      end
  end

  def current_user=(user)
    sign_in_user(user)
  end

  def current_user!
    raise User::RecordNotFound unless current_user

    current_user
  end

  rescue_from CanCan::AccessDenied do |_exception|
    if current_user.present?
      redirect_to main_app.dashboard_path, alert: 'Oops, you are not allowed to access that.', method: :get
    else
      respond_to do |format|
        format.json { head :forbidden }
        format.html do
          if request.xhr?
            head :forbidden
          else
            session[:redirect_url] = request.original_url
            # redirect_to main_app.sign_in_path
            render status: :unauthorized, layout: false
          end
        end
      end
    end
  end

  private

  def sign_in_user(user)
    @current_user = user
    session[:user_id] = user.id
    cookies.permanent.signed[:user_id] = user.id
    Activity.create(user_id: user.id, activity_type_id: Activity::SIGNED_IN)
  end

  def session_user
    User.find_by(id: session[:user_id]) if session[:user_id].present?
  end
end
