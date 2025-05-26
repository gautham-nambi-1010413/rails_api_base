# frozen_string_literal: true

module API
  module V1
    class UsersController < API::V1::APIController
      def show
        authorize current_user
      end

      def update
        authorize current_user
        current_user.update!(update_user_params)
        render :show
      end

      private

      def update_user_params
        params.expect(user: %i[first_name last_name email, { user_roles_attributes: [:id, :role_id, :_destroy] } ])
      end
    end
  end
end
