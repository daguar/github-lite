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

# The main repository for our discussions
main_repo = "daguar/github-lite"

get '/' do
  '''
    A list of all the discussions happening in the main repo.
  '''
  issues = Octokit.list_issues("#{main_repo}")
  # Show each issues labels as well.
  for issue in issues
    issue.labels = Octokit.labels_for_issue("#{main_repo}", "#{issue.number}")
  end
  erb :index
end

get '/login' do
  authenticate!
  erb :yes
end

get '/logout' do
  logout!
  redirect 'http://localhost:4567'
end

get '/:username/:repo_name/?' do
  @repo_string = "#{params[:username]}/#{params[:repo_name]}"
  @readme_html = Octokit.readme "#{params[:username]}/#{params[:repo_name]}", :accept => 'application/vnd.github.html'
  erb :repo_index
end

get '/:username/:repo_name/discussion/?' do
  @repo_string = "#{params[:username]}/#{params[:repo_name]}"
  @issues = Octokit.list_issues("#{params[:username]}/#{params[:repo_name]}")
  @url = "/#{params[:username]}/#{params[:repo_name]}/discussion"
  erb :issues_layout do
    erb :issues
  end
end

get '/:username/:repo_name/discussion/:issue_number/?' do
  @repo_string = "#{params[:username]}/#{params[:repo_name]}"
  issue_number = params[:issue_number]
  @issue = Octokit.issue(@repo_string, issue_number, :accept => 'application/vnd.github.html')
  @comments = Octokit.issue_comments(@repo_string, issue_number, :accept => 'application/vnd.github.html')
  erb :issues_layout do
    erb :issue
  end
end

post '/:username/:repo_name/discussion/:issue_number' do
  authenticate!
  Octokit.add_comment("#{params[:username]}/#{params[:repo_name]}", "#{params[:issue_number]}", "#{params[:comment]}")
  redirect "/#{params[:username]}/#{params[:repo_name]}/discussion/#{params[:issue_number]}"
end
