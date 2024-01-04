# README

## Initial setup

### System dependencies

You'll need the following:
* postgres
* redis
* memcached

If on OSX, install *HomeBrew* and then run:
```
$> brew install postgres redis memcached
```

Customize `./config/database.yml.example` for your application.
Then run `./bin/setup` and you should be good.

## Development

Make sure you've got all the gems installed.
The easiest way to do this is run `./bin/update` (or `./bin/setup` for first-time setup)

Once setup is complete, run `./bin/dev` to start the Rails process and Webpack dev server.

## Production

### ENV variables

* S3_BUCKET-- Name of bucket to store all uploads.
* LANG -- Set this to 'en_US.UTF-8'
* OPEN_TO_PUBLIC -- If set, bypasses the basic-http-auth password protection.
  Must be blank / unset to keep password protection. (See `ApplicationController#httpauth`)
* RACK_ENV -- Set to 'production'
* RAILS_ENV -- Set to 'production'
* RAILS_MASTER_KEY -- This is the master secret for encrypted credentials
* SEND_REAL_EMAIL -- Set this when you want to start sending emails to the indented recipients!
  By default, we hijack all emails and send them to a debugging address. (See `config/initializers/aws.rb`)
* WWW_HOST -- When set, forcefully redirect requests to this host (https) if request comes in using a different hostname

### Heroku

#### Add-Ons

* Heroku Postgres :: Database
* MemCachier
* Heroku Redis :: Redis
* Rollbar
* Scout

#### Build packs

If you need additional dependencies, like xrendr, create a file called `Aptfile` like:
```
libfontconfig1
libxrender1
```

and add the apt buildpack:

```
heroku buildpacks:add -i 1 https://github.com/heroku/heroku-buildpack-apt
```


### ActiveJobs / Sidekiq

If you're using ActiveJob, you will need to enable a 'worker' dyno to process the sidekiq queue.

### Staging
Your staging environment will use the 'production' rails environment configuration.
The only difference will be the configuration variables you set in the environment.
Of note:

* OPEN_TO_PUBLIC -- Do not set this ENV var for staging (we want that password protection)
* SEND_REAL_EMAIL -- Do not set this ENV var for staging (we don't want to send real emails)
* FORCE_DB_SEED -- This will enable injecting seed data into your database. Generally, you'll only want to enable
  this on a one-off basis when initially setting up a new prod or staging environment.

Please setup a staging-specific IAM user / access key pair and pass in via ENV:
* AWS_ACCESS_KEY_ID -- Your (per-application-stage) access key id
* AWS_SECRET_ACCESS_KEY -- Your matching secret access key

### SES

If you want to send email, you need to verify your domain and sender email with SES.

## Code Review

We use GitHub's Pull Requests for all code changes.  Push your change as a feature branch and open a pull request when ready.
Pull requests cannot be merged until they have been reviewed by another Prota developer and they pass all CI checks (rubocop and rspec)

Feel free err on the side of sending code reviews too early, and attempt to keep each independent pull request small and focused.

