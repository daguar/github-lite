require 'sinatra'
require 'octokit'
require 'sinatra_auth_github'
require 'redcarpet'

enable :sessions

set :github_options, {
  :scopes    => "repo",
  :secret    => ENV['GITHUB_CLIENT_SECRET'],
  :client_id => ENV['GITHUB_CLIENT_ID'],
}

register Sinatra::Auth::Github
markdown = Redcarpet::Markdown.new(Redcarpet::Render::HTML, extensions = {})

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

get '/forum/signup' do
  erb :signup
end

get '/forum/signin' do
  authenticate!
  redirect '/forum'
end

get '/forum/signout' do
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
  erb :index
end

get '/forum/i/new' do
  authenticate!
  @labels = github_user.api.labels(main_repo)
  erb :new_issue
end

post '/forum/i/new' do
  authenticate!
  github_user.api.create_issue("#{main_repo}", "#{params[:title]}", "#{params[:body]}", options = {:labels => params[:categories]})
  redirect "/forum"
end

get '/forum/i/:issue_number' do
  client = which_github_client()
  @issue = client.issue("#{main_repo}", "#{params[:issue_number]}")
  @issue.body = markdown.render(@issue.body)
  @comments = client.issue_comments("#{main_repo}", "#{params[:issue_number]}")
  @comments.each do |comment|
    comment.body = markdown.render(comment.body)
  end
  erb :issue
end

post '/forum/i/:issue_number' do
  authenticate!
  github_user.api.add_comment("#{main_repo}", "#{params[:issue_number]}", "#{params[:comment]}")
  redirect "/forum/i/#{params[:issue_number]}"
end

get '/forum/i/:issue_number/edit' do
  authenticate!
  @labels = github_user.api.labels(main_repo)
  @issue = github_user.api.issue("#{main_repo}", "#{params[:issue_number]}")
  @label_names = Array.new
  @issue.labels.each do |label|
    @label_names.push(label.name)
  end
  erb :edit
end

post '/forum/i/:issue_number/edit' do
  authenticate!
  github_user.api.update_issue("#{main_repo}", "#{params[:issue_number]}", "#{params[:title]}", "#{params[:body]}", options = {:labels => params[:categories]})
  redirect "/forum/i/#{params[:issue_number]}"
end

post '/forum/i/:issue_number/close' do
  authenticate!
  github_user.api.close_issue("#{main_repo}", "#{params[:issue_number]}")
  redirect "/forum"
end

get '/forum/i/:issue_number/comment/:comment_id/edit' do
  authenticate!
  @comment = github_user.api.issue_comment(main_repo, params[:comment_id])
  erb :edit_comment
end

post '/forum/i/:issue_number/comment/:comment_id/edit' do
  authenticate!
  @comment = github_user.api.update_comment(main_repo, params[:comment_id], params[:body])
  redirect "/forum/i/#{params[:issue_number]}"
end

get '/forum/l/:label_name' do
  client = which_github_client()
  @labels = client.labels(main_repo)
  @issues = client.list_issues("#{main_repo}", options = {:labels => "#{params[:label_name]}"})
  erb :index
end
