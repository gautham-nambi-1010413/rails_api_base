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
            response_data = JSON.parse(response.body)
            first_item = response_data.first

            if first_item && first_item.key?('id') && first_item.key?('name') && first_item.key?('data')
              render json: { count: Delayed::Job.count }
            else
              render json: { error: 'Invalid response format' }, status: :bad_request
            end
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
