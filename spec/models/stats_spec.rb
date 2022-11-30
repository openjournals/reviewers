require 'rails_helper'

RSpec.describe Stat, type: :model do

  it "belongs to user" do
    association = Stat.reflect_on_association(:user)
    expect(association.macro).to eq(:belongs_to)
  end

  it "#reviews_url uses the template" do
    user = create(:user, email: "tester21@reviewers.test", orcid: "0000-0000-0000-0000", github: "testuser21")
    stat = Stat.create(user: user, reviews_url_template: "https://joss.theoj.org/papers/reviewed_by/@{{github}}")

    expect(stat.reviews_url).to eq("https://joss.theoj.org/papers/reviewed_by/@testuser21")

    stat.reviews_url_template = "https://jour.nal/reviews/{{orcid}}/{{email}}/{{github}}"
    expect(stat.reviews_url).to eq("https://jour.nal/reviews/0000-0000-0000-0000/tester21@reviewers.test/testuser21")
  end

  it "#active_reviews_url uses the template" do
    user = create(:user, email: "tester21@reviewers.test", orcid: "0000-0000-0000-0000", github: "testuser21")
    stat = Stat.create(user: user, active_reviews_url_template: "https://github.com/openjournals/joss-reviews/issues?q=is%3Aissue+assignee%3A{{github}}")

    expect(stat.active_reviews_url).to eq("https://github.com/openjournals/joss-reviews/issues?q=is%3Aissue+assignee%3Atestuser21")

    stat.active_reviews_url_template = "https://jour.nal/active/{{orcid}}/{{email}}/{{github}}"
    expect(stat.active_reviews_url).to eq("https://jour.nal/active/0000-0000-0000-0000/tester21@reviewers.test/testuser21")
  end

end
