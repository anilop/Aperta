# TAHI

[![CircleCI](https://circleci.com/gh/Aperta-project/Aperta.svg?style=svg&circle-token=053baf28a00d1f8a35d40014fe8e3d840eadbd10)](https://circleci.com/gh/Aperta-project/Aperta)

# Initial Setup

## Overview

1. Run the setup script (`bin/setup`)
1. Make sure the following servers are already running:
    - PostgreSQL
    - Redis (run manually with `redis-server`)
1. Make sure the following ports are clear:
    - 4567 (Slanger API)
    - 40604 (Slanger websocket)
    - 5000 (Rails server)
1. Setup S3
1. Run `foreman start`

## Automated Setup

- Clone the repo, then run

```console
./bin/setup
```

Running this script will:
- Install dependencies
- Create the following config files:
    - .env.development
    - .foreman
    - Procfile.local
    - config/database.yml
- Create a new database

## Configuring S3 direct uploads

To set up a new test bucket for your own use, run:

```bash
rake s3:create_bucket
```

You will be prompted for an AWS key/secret key pair. You can ask a team member
for these: they should only be used to bootstrap your new settings.

Your new settings will be printed to stdout, and you can copy these settings
into your `.env.development` file.

## Run the server

Run `foreman start` to start the web server, worker, and slanger.

# Troubleshooting

TODO

# Further information

## Environment Variables

Tahi uses the [Dotenv](https://github.com/bkeepers/dotenv/) gem to manage its environment
variables in non-deployment environments (where Heroku manages the ENV). All necessary files
should be generated by the `bin/setup` script.

There are 4 important environment files: `.env`, `.env.development`, `.env.test`, `.env.local`.
`Dotenv` will load them in _that order_. Settings from `.env` will be overridden in the
`.env.(development/test)`, which will be overridden by the `.env.local`. Only the `.env` and
`.env.test` files are checked in. The `.env` file specifies some reasonable defaults for most
developer setups.

It is recommended to make machine specific modifications to the `.env.development`. Making
changes to the `.env.local` will override any settings from the `.env.test` (this can lead
to surprising differences between your machine and the CI server). This differs from the
"Dotenv best practices" which encourage making local changes to `.env.local`; we do not recommend
that approach.

foreman can also load environment variables. It is recommended that you do not
use it for this purpose, as interaction with dotenv can lead to bizarre `.env`
file load orders. Your `.foreman` file should contain the line:

```
env: ''
```

to prevent `.env` file loading.

## Event server

- The event server (slanger) is automatically installed in the setup script.

When you run `foreman start`, slanger will start up as the event stream server.

By default, slanger will listen on port `4567` for API requests (requests
coming from tahi rails server) and port `40604` for websocket requests (from
tahi browser client).

## Inserting test data

Run `rake db:setup`. This will delete any data you already have in your
database, and insert test users based on what you see in `db/seeds.rb`.

## Sending Emails

In development we sent emails through a simple SMTP server which catches any
message sent to it to display in a web interface

If you are running mailcatcher already you are ready to go, if not, please
follow these instructions:
 - install the gem `gem install mailcatcher`.
 - run in the console `mailcatcher` to start the daemon.
 - Go to http://localhost:1080/

For more information check http://mailcatcher.me/

## Upgrading node packages

To upgrade a node package, e.g., to version 1.0.1, use:
```
cd client
yarn add my-package@1.0.1
```

This should update both the `client/package.json` and
`client/yarn.lock` files. Commit changes to both these files.

# Tests

## Running specs

- RSpec for unit and integration specs
- Capybara and Selenium

### Running application specs

In the project directory, running `rspec` will run all unit and integration
specs for the application. Firefox will pop up to run integration tests.

## Running qunit tests from the command line

You can run the javascript specs via the command line with `rake ember:test`.

## Running qunit tests from the browser

You can also run the javascript specs from the browser. To do this run
`ember test --serve` from `client/` to see the results in the
browser.
You can run a particular test with '--module'. For example, running:
`ember test --serve --module="Integration:Discussions"
will run the Ember test that starts with `module('Integration:Discussions', {`

For help writing ember tests please see the [ember-cli testing section](http://www.ember-cli.com/#testing)

## Other Dependencies

Ghostscript is required to pass some of the tests.  Ghostscript can be installed
by running:

`brew install ghostscript`

# Documentation

Technical documentation lives in the `doc/`.  The git workflow and deploy
process are documented in [doc/git-process.txt](doc/git-process.txt). There is
a [Contribution Guide](CONTRIBUTING.md) that includes a Pull Request Checklist
template.

# Dev Notes

## Page Objects

When creating fragments, you can pass the context, if you wish to have access to
the page the fragment belongs to. You've to pass the context as an option to the
fragment on initializing:

```ruby
EditModalFragment.new(find('tr'), context: page)
```

## PDF Support

The ability to upload and view PDFs is keyed off of a journal setting. To enable PDFs on a journal use:

```
Journal.find(id).update(pdf_allowed: true)
```

That will enable PDF uploads and display. To work with PDFs in a local setting, the pdf.js viewer assets need to be copied into the assets directory.

```
rake rake assets:bypass_pipeline:copy_pdfjsviewer
```

For deployments, the `assets:bypass_pipeline:copy_pdfjsviewer` task runs right after `assets:precompile`.

Finally, the s3 bucket you use for the PDF uploads needs to be correctly configured for CORS GET requests with something like:

```
 <CORSRule>
   <AllowedOrigin>*</AllowedOrigin>
   <AllowedMethod>GET</AllowedMethod>
   <MaxAgeSeconds>3000</MaxAgeSeconds>
   <ExposeHeader>Accept-Ranges</ExposeHeader>
   <ExposeHeader>Content-Range</ExposeHeader>
   <ExposeHeader>Content-Encoding</ExposeHeader>
   <ExposeHeader>Content-Length</ExposeHeader>
   <AllowedHeader>*</AllowedHeader>
 </CORSRule>
```

# Deploying Aperta

Please see the
[Release Information page on confluence](https://developer.plos.org/confluence/display/TAHI/Release+Information)
for information on how to deploy aperta

# Documentation

To generate documentation, run the following command from the application root:

```
rake doc:app
```

Open the generated documentation from `doc/api/index.html` or
`doc/client/index.html` (javascript) in your browser.

Please document Ruby code with
[rdoc](http://docs.seattlerb.org/rdoc/RDoc/Markup.html) and Javascript with
[yuidoc](http://yui.github.io/yuidoc/)
