require 'sinatra'
require 'octokit'
require 'pry'

configure do
  Octokit.configure do |c|
    c.login = ENV['GITHUB_USERNAME']
    c.password = ENV['GITHUB_TOKEN']
  end
end

get '/:username/:repo_name/?' do
  @repo_string = "#{params[:username]}/#{params[:repo_name]}"
  @readme_html = Octokit.readme "#{params[:username]}/#{params[:repo_name]}", :accept => 'application/vnd.github.html'
  erb :repo_index, layout: :repo
end

get '/:username/:repo_name/discussion/?' do
  @repo_string = "#{params[:username]}/#{params[:repo_name]}"
  @issues = Octokit.list_issues("#{params[:username]}/#{params[:repo_name]}")
  @url = "/#{params[:username]}/#{params[:repo_name]}/discussion"
  erb :issues, layout: :repo
end

get '/:username/:repo_name/discussion/:issue_number/?' do
  @repo_string = "#{params[:username]}/#{params[:repo_name]}"
  issue_number = params[:issue_number]
  @issue = Octokit.issue(@repo_string, issue_number)
  @comments = Octokit.issue_comments(@repo_string, issue_number)
  erb :issue, layout: :repo
end
