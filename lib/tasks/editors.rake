namespace :editors do
  desc "Synchronize editorial team statuses"
  task sync: :environment do
    gh_client = Octokit::Client.new(access_token: ENV['GH_TOKEN'])
    editors = gh_client.team_members(ENV['EDITOR_TEAM_ID']).collect { |e| e.login }.sort

    editors.each do |editor|
      if user = User.find_by(github: editor, editor: false)
        user.editor = true
        user.save
      end
    end
  end
end
