require 'rails_helper'

RSpec.describe "API Token validation", type: :controller do

  class TestController < Api::BaseController
    def index
      render plain: "Hi!"
    end
  end

  before do
    @controller = TestController.new

    Rails.application.routes.draw do
      post '/testing/index', to: 'test#index'
      root to: 'home#index'
    end
  end

  after do
    Rails.application.reload_routes!
  end

  describe "Authentication using REVIEWERS_API_TOKEN" do
    it "should fail if token is not present" do
      post :index

      expect(response).to be_unauthorized
      expect(response.body).to be_empty
    end

    it "should fail if token is incorrect" do
      post :index, params: { token: "wrong-token" }

      expect(response).to be_unauthorized
      expect(response.body).to be_empty
    end

    it "should pass if valid token in params" do
      post :index, params: { token: "test-token" }

      expect(response).to be_ok
      expect(response.body).to eq("Hi!")
    end

    it "should pass if valid token in request header" do
      request.headers["TOKEN"] = "test-token"
      post :index

      expect(response).to be_ok
      expect(response.body).to eq("Hi!")
    end
  end

end
