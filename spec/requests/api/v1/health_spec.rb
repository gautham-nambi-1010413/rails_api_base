# frozen_string_literal: true

require 'rails_helper'
require 'httparty'
require 'webmock/rspec'

describe 'GET api/v1/delayed_jobs' do
  context 'when there are delayed jobs in the system' do
    before do
      # Stub the Delayed::Job.count method to return 3
      allow(Delayed::Job).to receive(:count).and_return(3)
      
      # Make the request
      get api_v1_delayed_jobs_path
    end

    it 'returns status 200 ok' do
      expect(response).to be_successful
    end

    it 'returns the correct count of delayed jobs' do
      expect(json['count']).to eq(3)
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

    it 'returns a count of zero' do
      expect(json['count']).to eq(0)
    end
  end

  context 'when there is an extremely large number of delayed jobs' do
    before do
      # Stub the Delayed::Job.count method to return a very large number
      # Using 10 million as an example of an extremely large number
      allow(Delayed::Job).to receive(:count).and_return(10_000_000)
      
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
end

describe 'GET api/v1/rest' do
  context 'when the external API returns a 200 status code and valid data' do
    let(:mock_data) do
      [
        { 'id' => '1', 'name' => 'Object 1', 'data' => { 'key1' => 'value1' } },
        { 'id' => '2', 'name' => 'Object 2', 'data' => { 'key2' => 'value2' } }
      ]
    end

    before do
      allow(HTTParty).to receive(:get).with('https://api.restful-api.dev/objects').and_return(
        double(code: 200, body: mock_data.to_json)
      )

      get api_v1_rest_path
    end

    it 'returns status 200 ok' do
      expect(response).to be_successful
    end

    it 'returns the data from the external API' do
      expect(JSON.parse(response.body)).to eq(mock_data)
    end
  end

  context 'when the external API times out' do
    before do
      stub_request(:get, 'https://api.restful-api.dev/objects').to_timeout
      get api_v1_rest_path
    end

    it 'returns status code 400' do
      expect(response).to have_http_status(:bad_request)
    end

    it 'returns an error message' do
      expect(json['error']).to eq('execution expired')
    end
  end

  context 'when the external API returns a non-JSON response' do
    before do
      allow(HTTParty).to receive(:get).and_return(
        double(code: 200, body: '<html><body><h1>Error</h1></body></html>')
      )

      get api_v1_rest_path
    end

    it 'returns status 400 bad request' do
      expect(response).to have_http_status(:bad_request)
    end

    it 'returns an error message' do
      expect(json['error']).to be_present
    end
  end

  context 'when the external API returns data with null values' do
    before do
      # Stub the HTTParty.get method to return a response with null values
      allow(HTTParty).to receive(:get).and_return(
        double(
          code: 200,
          body: '[{"id": null, "name": null, "data": null}]'
        )
      )

      # Make the request
      get api_v1_rest_path
    end

    it 'returns status 200 ok' do
      expect(response).to be_successful
    end

    it 'returns the data with null values' do
      parsed_response = JSON.parse(response.body)
      expect(parsed_response).to eq([{"id" => nil, "name" => nil, "data" => nil}])
    end
  end
  
  # [Tusk] FAILING TEST
  context 'when the external API returns a valid JSON object instead of an array' do
    before do
      # Mock the HTTParty.get method to return a JSON object
      allow(HTTParty).to receive(:get).and_return(
        double(
          code: 200,
          body: { id: 1, name: 'Test', data: 'Test Data' }.to_json
        )
      )

      # Make the request to the rest endpoint
      get api_v1_rest_path
    end

    it 'returns status 400 bad request' do
      expect(response).to have_http_status(:bad_request)
    end

    it 'returns an error message' do
      expect(json['error']).to eq('Invalid response format')
    end
  end
end
