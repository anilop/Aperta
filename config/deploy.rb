# Copyright (c) 2018 Public Library of Science

# Permission is hereby granted, free of charge, to any person obtaining a
# copy of this software and associated documentation files (the "Software"),
# to deal in the Software without restriction, including without limitation
# the rights to use, copy, modify, merge, publish, distribute, sublicense,
# and/or sell copies of the Software, and to permit persons to whom the
# Software is furnished to do so, subject to the following conditions:

# The above copyright notice and this permission notice shall be included in
# all copies or substantial portions of the Software.

# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL
# THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
# FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER
# DEALINGS IN THE SOFTWARE.

# config valid only for current version of Capistrano
lock '3.4.0'

set :application, 'tahi'
set :assets_roles, [:web, :app, :worker]
set :chruby_exec, '/usr/bin/chruby-exec'
set :chruby_ruby, File.read(File.expand_path('../../.ruby-version', __FILE__)).strip
set :linked_dirs, ['log', 'tmp/pids', 'tmp/cache', 'tmp/sockets',
                   'vendor/bundle', 'public/uploads', 'public/system']
set :linked_files, %w(env puma.rb)
set :repo_url, 'git@github.com:aperta-project/aperta.git'
set :web_service_name, 'tahi-web' # used by puma:{start,stop,restart}
set :worker_service_name, 'tahi-worker' # used by sidekiq:{start,stop,restart}
set :nginx_pidfile, '/run/nginx.pid'
set :puma_pidfile, '/var/www/tahi/current/tmp/pids/puma.pid'
set :sidekiq_pidfile, '/var/www/tahi/current/tmp/pids/sidekiq.pid'
set :rails_env, 'production'
set :rack_env, 'production'
# Teamcity sets BRANCH_NAME
set :branch, ENV['BRANCH_NAME']

# Load from an env file managed by salt.
fetch(:bundle_bins).each do |command|
  SSHKit.config.command_map.prefix[command.to_sym]
    .push('bundle exec dotenv -f env')
end

# ember-cli-rails compiles assets, but does not put them anywhere.
after 'deploy:compile_assets', 'deploy:copy_ember_assets'

after 'deploy:migrate', 'deploy:safe_seeds' do
  on primary fetch(:migration_role) do
    within release_path do
      with rails_env: fetch(:rails_env) do
        execute :rake, 'cards:load'
        execute :rake, 'roles-and-permissions:seed'
        execute :rake, 'data:update_journal_task_types'
        execute :rake, 'settings:seed_setting_templates'
        execute :rake, 'create_feature_flags'
        execute :rake, 'seed:letter_templates:populate'
      end
    end
  end
end

before 'deploy:starting', :check_branch do
  raise 'Please set $BRANCH_NAME' unless fetch(:branch)
end
