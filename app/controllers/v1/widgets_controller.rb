# DEMO
module V1
  class WidgetsController < ApplicationController
    # All the basics come from the BasicCrud concern
    include BasicCrud

    private

    # Restrict creation params
    def create_params
      params.require(:widget).permit(:name, :multiplier)
    end

    # Only let users update the multiplier
    def update_params
      params.require(:widget).permit(:multiplier)
    end
  end
end
