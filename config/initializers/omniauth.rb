Rails.application.config.middleware.use OmniAuth::Builder do
  provider :github, ENV['REVIEWERS_GH_CLIENT_ID'], ENV['REVIEWERS_GH_CLIENT_SECRET'], scope: "public_repo"
  provider :orcid, ENV['REVIEWERS_ORCID_CLIENT_ID'], ENV['REVIEWERS_ORCID_CLIENT_SECRET']
end