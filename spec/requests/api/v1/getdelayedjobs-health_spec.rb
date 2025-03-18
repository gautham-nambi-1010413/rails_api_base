# frozen_string_literal: true

require 'rails_helper'

describe 'GET api/v1/delayed_jobs' do
  context 'when there are delayed jobs in the system with oldest timestamp' do
    let(:oldest_timestamp) { Time.new(2023, 1, 1, 12, 0, 0).utc }
    let(:oldest_job) { instance_double('Delayed::Job', created_at: oldest_timestamp) }
    
    before do
      # Stub the Delayed::Job.count method to return 3
      allow(Delayed::Job).to receive(:count).and_return(3)
      
      # Stub the order chain to return the oldest job
      job_relation = double('ActiveRecord::Relation')
      allow(Delayed::Job).to receive(:order).with(:created_at).and_return(job_relation)
      allow(job_relation).to receive(:first).and_return(oldest_job)
      
      # Make the request
      get api_v1_delayed_jobs_path
    end

    it 'returns status 200 ok' do
      expect(response).to be_successful
    end

    it 'returns the correct count of delayed jobs' do
      expect(json['count']).to eq(3)
    end

    it 'returns the creation timestamp of the oldest delayed job' do
      expect(json['oldest']).to eq(oldest_timestamp.as_json)
    end
  end

  context 'when there are no delayed jobs in the system' do
    before do
      # Stub the Delayed::Job.count method to return 0
      allow(Delayed::Job).to receive(:count).and_return(0)
      
      # Make the request
      get api_v1_delayed_jobs_path
    end

    it 'returns status 200 ok' do
      expect(response).to be_successful
    end

    it 'returns a message indicating no delayed jobs' do
      expect(json['msg']).to eq('No delayed jobs found')
    end

    it 'does not include a count in the response' do
      expect(json).not_to have_key('count')
    end
  end

  context 'when there is an extremely large number of delayed jobs' do
    before do
      # Stub the Delayed::Job.count method to return a very large number
      # Using 10 million as an example of an extremely large number
      allow(Delayed::Job).to receive(:count).and_return(10_000_000)
      
      # Create a mock job with a creation timestamp
      mock_job = instance_double(Delayed::Job, created_at: Time.new(2023, 1, 1, 12, 0, 0))
      allow(Delayed::Job).to receive_message_chain(:order, :first).and_return(mock_job)
      
      # Make the request
      get api_v1_delayed_jobs_path
    end

    it 'returns status 200 ok' do
      expect(response).to be_successful
    end

    it 'returns the correct large count of delayed jobs' do
      expect(json['count']).to eq(10_000_000)
    end

    it 'returns the count as a number, not a string' do
      # Ensure the JSON parser maintains the numeric type
      parsed_response = JSON.parse(response.body)
      expect(parsed_response['count']).to be_a(Integer)
    end
  end

  context 'when multiple jobs have the same creation timestamp' do
    let(:timestamp) { Time.new(2023, 1, 1, 12, 0, 0) }
    let(:job1) { instance_double(Delayed::Job, created_at: timestamp) }
    let(:job2) { instance_double(Delayed::Job, created_at: timestamp) }
    
    before do
      # Stub the Delayed::Job.count method to return 2
      allow(Delayed::Job).to receive(:count).and_return(2)
      
      # Create a mock for the order chain that returns job1
      ordered_relation = double('ActiveRecord::Relation')
      allow(Delayed::Job).to receive(:order).with(:created_at).and_return(ordered_relation)
      allow(ordered_relation).to receive(:first).and_return(job1)
      
      # Make the request
      get api_v1_delayed_jobs_path
    end

    it 'returns status 200 ok' do
      expect(response).to be_successful
    end

    it 'returns the correct count of delayed jobs' do
      expect(json['count']).to eq(2)
    end

    it 'returns one of the identical timestamps as the oldest' do
      expect(Time.parse(json['oldest'])).to eq(timestamp)
    end
  end
end
