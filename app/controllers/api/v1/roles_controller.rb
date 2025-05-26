# frozen_string_literal: true

module API
  module V1
    class RolesController < ApplicationController

      def index
        roles = Role.all
        render json: roles.map { |r| r.as_json(only: [:id, :name]) }
      end
    
      def create
        role = Role.new(role_params)
        if role.save
          render json: role.as_json(only: [:id, :name]), status: :created
        else
          render json: { errors: role.errors.full_messages }, status: :unprocessable_entity
        end
      end
    
      private
    
      def role_params
        params.require(:role).permit(:name)
      end
    
    end
  end
end