module V1
  class GlobalSettingsController < ApplicationController
    skip_before_action :require_user_token

    def index
      @global_settings = GlobalSetting.all.to_a
    end
  end
end
