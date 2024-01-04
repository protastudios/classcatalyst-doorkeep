module RailsAdmin
  module Extensions
    module CanCanCan2
      class AuthorizationAdapter < RailsAdmin::Extensions::CanCanCan::AuthorizationAdapter
        # Extra explicit `authorize!` call to make `check_authorization` happy
        def authorize(action, abstract_model = nil, model_object = nil)
          @controller.authorize!(:manage, :activeadmin)
          super
        end
      end
    end
  end
end

RailsAdmin.add_extension(:cancancan2, RailsAdmin::Extensions::CanCanCan2, authorization: true)

RailsAdmin.config do |config|
  # Ensure we get helpers from ApplicationController
  config.parent_controller = '::AdminController'

  ### Popular gems integration

  ## == Devise ==
  # config.authenticate_with do
  #   warden.authenticate! scope: :user
  # end
  config.current_user_method(&:current_user)
  # config.current_user_method do
  #   user = User.find_by(id: session[:user_id]) if session[:user_id].present?
  #   user ||= User.find_by(id: cookies.signed[:user_id]) if cookies.signed[:user_id].present?
  #   user
  # end

  ## == Cancan ==
  config.authorize_with :cancancan2

  config.included_models = %w[User Role GlobalSetting Translation]

  ## == PaperTrail ==
  # config.audit_with :paper_trail, 'User', 'PaperTrail::Version' # PaperTrail >= 3.0.0

  ### More at https://github.com/sferik/rails_admin/wiki/Base-configuration

  ## == Gravatar integration ==
  ## To disable Gravatar integration in Navigation Bar set to false
  config.show_gravatar = false

  config.actions do
    dashboard do
      authorization_key :railsadmin
      statistics false
    end
    index
    new
    import
    export
    bulk_delete
    show
    edit
    delete
    show_in_app

    ## With an audit adapter, you can add:
    # history_index
    # history_show
  end
end
