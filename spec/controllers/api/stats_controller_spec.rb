require 'rails_helper'

RSpec.describe Api::StatsController, type: :controller do

  before do
    request.headers["TOKEN"] = "test-token"
  end

  it "Needs authorization" do
    request.headers["TOKEN"] = "Wrong token"
    put :update, params: {username: "any", what: "any"}
    expect(response.status).to eq(401)
  end

  describe "Updating review stats" do
    it "Should validate params" do
      put :update, params: {username: "lolo", what: ""}
      expect(response.status).to eq(422)
      expect(response.body).to eq("Invalid param: action")

      put :update, params: {username: "lolo", what: "incorrect-action"}
      expect(response.status).to eq(422)
      expect(response.body).to eq("Invalid param: action")
    end

    it "should discard repeated actions" do
      reviewer = create(:reviewer)
      expect(reviewer.stat.last_action_key).to be_blank
      expect(reviewer.stat.active_reviews).to eq(0)
      expect(reviewer.stat.reviews_all_time).to eq(0)

      put :update, params: {username: reviewer.github, what: "review_assigned", idempotency_key: "testing"}
      expect(response).to be_no_content

      expect(reviewer.stat.reload.last_action_key).to eq("testing")
      expect(reviewer.stat.active_reviews).to eq(1)
      expect(reviewer.stat.reviews_all_time).to eq(1)

      put :update, params: {username: reviewer.github, what: "review_assigned", idempotency_key: "testing"}
      expect(response).to be_bad_request

      expect(reviewer.stat.reload.last_action_key).to eq("testing")
      expect(reviewer.stat.active_reviews).to eq(1)
      expect(reviewer.stat.reviews_all_time).to eq(1)
    end

    describe "New active review" do
      before do
        @reviewer = create(:reviewer)
        user_stats = @reviewer.stat
        user_stats.active_reviews = 2
        user_stats.reviews_all_time = 7
        user_stats.save!
      end

      it "when receiving review_started" do
        put :update, params: {username: @reviewer.github, what: "review_started"}
        expect(response).to be_no_content

        expect(@reviewer.stat.reload.active_reviews).to eq(3)
        expect(@reviewer.stat.reviews_all_time).to eq(8)
        expect(@reviewer.stat.last_review_on).to be_nil
      end

      it "when receiving review_assigned" do
        put :update, params: {username: @reviewer.github, what: "review_assigned"}
        expect(response).to be_no_content

        expect(@reviewer.stat.reload.active_reviews).to eq(3)
        expect(@reviewer.stat.reviews_all_time).to eq(8)
      end
    end

    describe "Finished review" do
      before do
        @reviewer = create(:reviewer)
        user_stats = @reviewer.stat
        user_stats.active_reviews = 2
        user_stats.reviews_all_time = 7
        user_stats.save!
      end

      it "when receiving review_finished" do
        put :update, params: {username: @reviewer.github, what: "review_finished"}
        expect(response).to be_no_content

        expect(@reviewer.stat.reload.active_reviews).to eq(1)
        expect(@reviewer.stat.reviews_all_time).to eq(7)
      end

      it "when receiving review_unassigned" do
        put :update, params: {username: @reviewer.github, what: "review_unassigned"}
        expect(response).to be_no_content

        expect(@reviewer.stat.reload.active_reviews).to eq(1)
        expect(@reviewer.stat.reviews_all_time).to eq(7)
      end

      it "updates last_review_on" do
        expect(@reviewer.stat.last_review_on).to be_nil
        put :update, params: {username: @reviewer.github, what: "review_unassigned"}
        expect(response).to be_no_content

        expect(@reviewer.stat.reload.last_review_on).to eq(Time.now.to_date)
      end
    end

    it "should not decrement counters already at zero" do
      reviewer = create(:reviewer)
      expect(reviewer.stat.active_reviews).to eq(0)
      expect(reviewer.stat.reviews_all_time).to eq(0)

      put :update, params: {username: reviewer.github, what: "review_unassigned"}
      expect(response).to be_no_content

      expect(reviewer.stat.reload.active_reviews).to eq(0)
      expect(reviewer.stat.reviews_all_time).to eq(0)
    end
  end
end
