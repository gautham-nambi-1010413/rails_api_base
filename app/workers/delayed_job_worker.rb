# frozen_string_literal: true

class DelayedJobWorker
  include Sidekiq::Worker

  sidekiq_options queue: 'delayed_job'

  def perform(user_id)
    Rails.logger.info "Processing delayed job for user_id: #{user_id}"
  end
end
