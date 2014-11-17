require 'sinatra'
require 'octokit'
require 'sinatra_auth_github'

enable :sessions

set :github_options, {
  :scopes    => "repo",
  :secret    => ENV['GITHUB_CLIENT_SECRET'],
  :client_id => ENV['GITHUB_CLIENT_ID'],
}

register Sinatra::Auth::Github

get '/forum/login' do
  authenticate!
  redirect '/forum'
end

get '/forum/logout' do
  logout!
  redirect '/forum'
end

# The main repository for our discussions
main_repo = "daguar/github-lite"

get '/forum' do
  '''
    A list of all the discussions happening in the main repo.
  '''
  if authenticated?
    @issues = github_user.api.list_issues(main_repo)
    # Show each issues labels as well.
    for issue in @issues do
      issue.labels = github_user.api.labels_for_issue("#{main_repo}", "#{issue.number}")
    end
  end
  if not authenticated?
    @issues = Octokit.list_issues(main_repo)
    # Show each issues labels as well.
    for issue in @issues do
      issue.labels = Octokit.labels_for_issue("#{main_repo}", "#{issue.number}")
    end
  end
  erb :index
end

get '/forum/i/:issue_number/?' do
  issue_number = params[:issue_number]
  @issue = github_user.api.issue("#{main_repo}", issue_number, :accept => 'application/vnd.github.html')
  @comments = github_user.api.issue_comments("#{main_repo}", issue_number, :accept => 'application/vnd.github.html')
  erb :issue
end
