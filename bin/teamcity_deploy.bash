#!/bin/bash
echo "Deploying release to Production..."
sudo -u aperta -i /bin/bash << "EOF"
cd %teamcity.build.checkoutDir%
export BRANCH_NAME=%teamcity.build.branch%
export VCS_NUMBER=%build.vcs.number%
echo $BRANCH_NAME
echo $VCS_NUMBER
echo $HOME
# Can't use -i as have to stay in checkout directory
# Need to set any needed vars in Parameters as env vars
eval `ssh-agent -s`
echo $SSH_AGENT_PID
ssh-add /home/aperta/.ssh/id_rsa
ssh-add -l
chruby-exec 2.2.3 -- gem install bundler && bundle install && bundle exec cap production deploy || exit 1
EOF
