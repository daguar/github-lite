require 'sinatra'
require 'octokit'

configure do
  Octokit.configure do |c|
    c.login = ENV['GITHUB_USERNAME']
    c.password = ENV['GITHUB_TOKEN']
  end
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
  @issue = Octokit.issue(@repo_string, issue_number)
  @comments = Octokit.issue_comments(@repo_string, issue_number)
  erb :issues_layout do
    erb :issue
  end
end
