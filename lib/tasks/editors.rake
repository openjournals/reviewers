namespace :reviewers do
  namespace :editors do
    desc "Synchronize editorial team statuses"
    task sync: :environment do
      if ENV['REVIEWERS_GH_TOKEN'].blank? || ENV['REVIEWERS_EDITOR_TEAM_ID'].blank?
        error_msg = "[reviewers:editors:sync] Error running task: Missing configuration values for REVIEWERS_GH_TOKEN or REVIEWERS_EDITOR_TEAM_ID"
        Rails.logger.info error_msg
        puts error_msg
      else
        gh_client = Octokit::Client.new(access_token: ENV['REVIEWERS_GH_TOKEN'], auto_paginate: true)
        editors = gh_client.team_members(ENV['REVIEWERS_EDITOR_TEAM_ID']).collect { |e| e.login }.sort

        editors.each do |editor|
          if user = User.find_by(github: editor, editor: false)
            user.editor = true
            user.reviewer = false
            user.save
            puts " ✨ Granted editor status to #{editor}"
          end
        end
      end
    end
  end
end
