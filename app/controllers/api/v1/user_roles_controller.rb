# frozen_string_literal: true

module API
  module V1
    class UserRolesController < ApplicationController

      def create
        user_role = UserRole.new(user_role_params)
        if user_role.save
          render json: {
            id: user_role.id,
            user_id: user_role.user_id,
            role_id: user_role.role_id
          }, status: :created
        else
          render json: { errors: user_role.errors.full_messages }, status: :unprocessable_entity
        end
      end
    
      private
    
      def user_role_params
        params.require(:user_role).permit(:user_id, :role_id)
      end    

    end
  end
end
