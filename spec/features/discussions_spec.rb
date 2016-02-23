require 'rails_helper'

feature "Discussions", js: true, selenium: true do
  let(:admin) { FactoryGirl.create :user }
  let(:creator) { FactoryGirl.create :user }
  let!(:journal) { FactoryGirl.create :journal, :with_roles_and_permissions }
  let!(:paper) { FactoryGirl.create :paper, :submitted, :with_tasks, creator: creator, journal: journal }
  let(:discussion_page) { DiscussionsPage.new }

  context 'access paper and manage discussions' do
    scenario 'can add topics, participants, and replies' do
      assign_journal_role journal, admin, :admin

      login_as(admin, scope: :user)
      visit "/papers/#{paper.id}"
      wait_for_ajax

      find('#nav-discussions').click
      wait_for_ajax

      discussion_page.new_topic
      discussion_page.fill_in_topic
      discussion_page.create_topic
      discussion_page.expect_topic_created_succesfully(admin)
      discussion_page.expect_can_add_participant
      discussion_page.add_reply
      discussion_page.expect_reply_created(admin, 2)
    end
  end

  context 'access to paper no access to discussions' do
    let(:user) { create :user }
    let!(:discussion_topic) { FactoryGirl.create :discussion_topic, paper: paper }

    before { paper.add_collaboration(user) }

    scenario 'can view paper, no discussions load' do
      login_as(user, scope: :user)
      visit "/papers/#{paper.id}"
      wait_for_ajax
      find('#nav-discussions').click
      wait_for_ajax
      discussion_page.expect_no_create_button
      discussion_page.expect_view_no_discussions
    end
  end

  context 'access to paper, participant only on a discussion' do
    let(:user) { create :user }
    let!(:discussion_topic) { FactoryGirl.create :discussion_topic, paper: paper }
    let!(:discussion_participant) { FactoryGirl.create :discussion_participant, user: user, discussion_topic: discussion_topic }

    before do
      paper.add_collaboration(user)
      discussion_topic.add_discussion_participant(discussion_participant)
    end

    scenario 'can see discussion and add reply' do
      login_as(user, scope: :user)
      visit "/papers/#{paper.id}/discussions"

      discussion_page.expect_no_create_button
      discussion_page.click_topic
      wait_for_ajax

      discussion_page.expect_view_topic
      discussion_page.expect_view_only_participants
      discussion_page.add_reply
      discussion_page.expect_reply_created(user, 1)
    end
  end
end
