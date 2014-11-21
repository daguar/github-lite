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

def which_github_client()
  ''' 
    Which github client to use?
    Use the users github api limit if they are logged in
    Use ours for all the lurkers
  '''
  if authenticated?
    client = github_user.api
  end
  if not authenticated?
    client = Octokit
  end
  return client
end

get '/forum/login' do
  authenticate!
  redirect '/forum'
end

get '/forum/logout' do
  logout!
  redirect '/forum'
end

# The main repository for our discussions
main_repo = "codeforamerica/forum"

get '/forum' do
  '''
    A list of all the discussions happening in the main repo.
  '''
  client = which_github_client()
  @labels = client.labels(main_repo)
  @issues = client.list_issues(main_repo)
  # Show each issues labels as well.
  for issue in @issues do
    issue.labels = client.labels_for_issue("#{main_repo}", "#{issue.number}")
  end
  erb :index
end

get '/forum/i/new' do
  authenticate!
  @labels = github_user.api.labels(main_repo)
  erb :new_issue
end

post '/forum/i/new' do
  authenticate!
  puts params[:categories]
  github_user.api.create_issue("#{main_repo}", "#{params[:title]}", "#{params[:body]}", options = {:labels => params[:categories]})
  redirect "/forum"
end

get '/forum/i/:issue_number' do
  client = which_github_client()
  @issue = client.issue("#{main_repo}", "#{params[:issue_number]}")
  @comments = client.issue_comments("#{main_repo}", "#{params[:issue_number]}")
  erb :issue
end

post '/forum/i/:issue_number' do
  authenticate!
  github_user.api.add_comment("#{main_repo}", "#{params[:issue_number]}", "#{params[:comment]}")
  redirect "/forum/i/#{params[:issue_number]}"
end

get '/forum/i/:issue_number/edit' do
  authenticate!
  @issue = github_user.api.issue("#{main_repo}", "#{params[:issue_number]}")
  @comments = github_user.api.issue_comments("#{main_repo}", "#{params[:issue_number]}")
  erb :issue
end

get '/forum/l/:label_name' do
  client = which_github_client()
  @labels = client.labels(main_repo)
  @issues = client.list_issues("#{main_repo}", options = {:labels => "#{:label_name}"})
  erb :index
end
