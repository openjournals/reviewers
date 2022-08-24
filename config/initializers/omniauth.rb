Rails.application.config.middleware.use OmniAuth::Builder do
  provider :github, ENV['REVIEWERS_GH_CLIENT_ID'], ENV['REVIEWERS_GH_CLIENT_SECRET'], scope: "read:user"
  provider :orcid, ENV['REVIEWERS_ORCID_CLIENT_ID'], ENV['REVIEWERS_ORCID_CLIENT_SECRET']
end