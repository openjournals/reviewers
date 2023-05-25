# Reviewers

Reviewers is a Ruby on Rails application to manage a database of a journal's reviewers. Users can volunteer to review by signing into the site and filling their profile information. Editors can search for reviewers, add reviewers, and provide feedback on them.

The Reviewers instance used for JOSS is deployed in Heroku and configured for the JOSS editors team at GitHub. Its API is also used by the editorial bot to sync data for reviewers activity when reviews start and end.

## URL

An instance of the application is running for the Journal of Open Source Software here:

https://reviewers.joss.theoj.org

## Source code

The source code can be found here: https://github.com/openjournals/reviewers

## Installation & Deployment

Reviewers is a standard Rails application. The only resources needed to deploy the application are a Ruby version installed (>3) and a Postgres database. The capacity to run background tasks is also needed, so something like `cron` or `Heroku Scheduler` should be available.

A server configuration is included in the `config/puma.rb` file, so the app can be run with:

```
bundle exec puma -C config/puma.rb
```

To recognize editors there is a rake task available that can be run periodically (recommendation: hourly) in the background with:
```
bin/rails reviewers:editors:sync
```

## Configuration

Multiple elements are needed to configure the application:

### GitHub OAuth application

Users log in the Reviewers app using their [GitHub](https://github.com) identifier. In order for the authentication to work, an OAuth application [created at GitHub](https://github.com/settings/developers) is needed. It should be configured to receive requests from the reviewers app and the authorization callback URL should be `<REVIEWERS_APP_URL>/auth/github/callback`

### ORCID OAuth application

Users can add their [ORCID](https://orcid.org) identifier to their profile. An OAuth application [created at orcid.org](https://orcid.org/developer-tools) is needed. It should be configured to receive requests from the reviewers app and the valid redirect URI should include `<REVIEWERS_APP_URL>/auth/orcid/callback`

### Enviroment variables

For the GitHub authentication to work, once the GitHub OAuth app is created, two ENV VARs are needed to store the cliend_id and secret:

- REVIEWERS_GH_CLIENT_ID
- REVIEWERS_GH_CLIENT_SECRET

To assign ORCID identifiers to users the app uses the ORCID OAuth application client_id and secret:

- REVIEWERS_ORCID_CLIENT_ID
- REVIEWERS_ORCID_CLIENT_SECRET

For the API to work:

- REVIEWERS_API_TOKEN: A random string that will be used by the bot to authenticate when calling the Reviewers app API

To recognize editors there is an `editors:sync` Rake task defined in the `lib/tasks/editors.rake` file and that uses two variables:

- REVIEWERS_EDITOR_TEAM_ID: The id of the GitHub team with the list of editors
- REVIEWERS_GH_TOKEN: The GitHub token to be able to use the GitHub API

To configure links to the journal owning the reviewers database there are three env variables available. These variables are optional as values can also be set in the settings file. If present the value in the ENV VAR will take precedence over the one in the config file.

- JOURNAL_NAME: The name of the journal
- JOURNAL_ALIAS: The short name for the journal
- JOURNAL_URL: The URL of the journals' site

### Settings file

There is a YAML file located in `config\reviewers_settings.yml` where some configuration options can be defined:

```yaml
  all_reviews_url_template: "https://joss.theoj.org/papers/reviewed_by/{{github}}"
  active_reviews_url_template: "https://github.com/openjournals/joss-reviews/issues?q=is:issue+is:open+label:review+mentions:{{github}}"
  journal:
    name: The Journal of Open Source Software
    alias: JOSS
    url: https://joss.theoj.org
```
