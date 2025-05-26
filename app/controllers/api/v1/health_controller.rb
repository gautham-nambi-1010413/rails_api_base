# frozen_string_literal: true

module API
  module V1
    class HealthController < API::V1::APIController
      skip_before_action :authenticate_user!
      skip_after_action :verify_authorized

      def get_delayed_jobs
        begin
          response = HTTParty.get('https://api.restful-api.dev/objects')

          if response.code == 200
            render json: { count: Delayed::Job.count }
          else
            render json: { error: 'External API request failed' }, status: :bad_request
          end
        rescue StandardError => e
          render json: { error: e.message }, status: :bad_request
        end
      end

      def status
        render json: { online: true }
      end
    end
  end
end
