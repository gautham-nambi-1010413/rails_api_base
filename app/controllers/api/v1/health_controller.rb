# frozen_string_literal: true

module API
  module V1
    class HealthController < API::V1::APIController
      skip_before_action :authenticate_user!
      skip_after_action :verify_authorized

      def get_delayed_jobs
        render json: { count: Delayed::Job.count }
      end

      def status
        render json: { online: true }
      end
    end
  end
end
