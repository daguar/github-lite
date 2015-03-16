
# Forum / GitHub Lite

A simplified interface to GitHub Issues, intended to make it easier to participate in discussions on GitHub

## Status

This is a very early-stage prototype / proof-of-concept.

The main contributors to-date are:

- @daguar (Dave Guarino)
- @ondrae (Andrew Hyder)

## Local setup

This is a Ruby app using the Sinatra microframework.

1. Make sure you have Ruby installed (see this [howto](https://github.com/codeforamerica/howto/blob/master/Ruby.md) for help)
2. `git clone` the repo and `cd` into the project directory
3. `bundle install` to install Ruby dependencies
4. Register a new GitHub application on your account (for API access) at https://github.com/settings/applications/new and set the authorization callback URL to `http://localhost:9292/auth/github/callback`
5. Run `cp .env_example .env` and replace the dummy credentials in `.env` with the client ID and secret for your newly-registered GitHub application
6. Run `foreman run rackup` and go to [http://localhost:9292/forum](http://localhost:9292/forum) in your browser to access your local copy of the app!

