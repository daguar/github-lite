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
main_repo = "codeforamerica/health"

get '/forum' do
  '''
    A list of all the discussions happening in the main repo.
  '''
  if authenticated?
    @labels = github_user.api.labels(main_repo)
    @issues = github_user.api.list_issues(main_repo)
    # Show each issues labels as well.
    for issue in @issues do
      issue.labels = github_user.api.labels_for_issue("#{main_repo}", "#{issue.number}")
    end
  end
  if not authenticated?
    @labels = Octokit.labels(main_repo)
    @issues = Octokit.list_issues(main_repo)
    # Show each issues labels as well.
    for issue in @issues do
      issue.labels = Octokit.labels_for_issue("#{main_repo}", "#{issue.number}")
    end
  end
  erb :index
end

get '/forum/i/:issue_number/?' do
  if authenticated?
    @issue = github_user.api.issue("#{main_repo}", "#{params[:issue_number]}")
    @comments = github_user.api.issue_comments("#{main_repo}", "#{params[:issue_number]}")
  end
  if not authenticated?
    @issue = Octokit.issue("#{main_repo}", "#{params[:issue_number]}")
    @comments = Octokit.issue_comments("#{main_repo}", "#{params[:issue_number]}")
  end
  erb :issue
end

post '/forum/i/:issue_number' do
  authenticate!
  github_user.api.add_comment("#{main_repo}", "#{params[:issue_number]}", "#{params[:comment]}")
  redirect "/forum/i/#{params[:issue_number]}"
end

get '/forum/i/:issue_number/edit' do
  if authenticated?
    @issue = github_user.api.issue("#{main_repo}", "#{params[:issue_number]}")
    @comments = github_user.api.issue_comments("#{main_repo}", "#{params[:issue_number]}")
  end
  erb :issue
end
