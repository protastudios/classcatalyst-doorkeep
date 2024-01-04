module V1
  class TranslationsController < ApplicationController
    skip_before_action :require_user_token
    before_action :find_translation

    authorize_resource

    def show; end

    private

    def find_translation
      @translation = Translation.find_by!(locale: show_params[:locale] || 'en', key: show_params[:key])
    end

    def show_params
      params.permit(:locale, :key)
    end
  end
end
