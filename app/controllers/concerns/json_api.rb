module JsonApi
  extend ActiveSupport::Concern

  included do
    before_action :force_json

    rescue_from ActiveRecord::RecordNotFound do |_|
      render_json_error 'Record Not Found', status: :not_found
    end

    rescue_from ActiveRecord::RecordInvalid do |e|
      render_json_error e.message
    end

    rescue_from CanCan::AccessDenied do |e|
      render_json_error('Access Denied', messages: [e.message], status: :unauthorized)
    end
  end

  def render_json_error(error, messages: nil, status: :unprocessable_entity)
    render json: { status: 'error', error: error, error_messages: messages || [error] }, status: status
  end

  def force_json
    request.format = :json
  end
end
