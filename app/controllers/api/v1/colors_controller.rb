# frozen_string_literal: true

module API
  module V1
    class ColorsController < API::V1::APIController
      include API::Concerns::ActAsAPIRequest
      before_action :authenticate_user!
      before_action :set_color, only: [:destroy]

      def index
        @colors = current_user.colors
        render json: @colors
      end

      private

      def set_color
        @color = current_user.colors.find(params[:id])
      rescue ActiveRecord::RecordNotFound
        render json: { error: 'Color not found' }, status: :not_found
      end
    end
  end
end
