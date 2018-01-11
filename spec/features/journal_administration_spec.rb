require 'rails_helper'
require 'support/pages/admin_dashboard_page'
require 'support/pages/dashboard_page'

feature "Journal Administration", js: true do
  let(:user) { create :user, :site_admin }
  let!(:journal) { create :journal, :with_roles_and_permissions, :with_default_mmt }
  let!(:another_journal) { create :journal, :with_roles_and_permissions, :with_default_mmt }

  before do
    login_as(user, scope: :user)
    visit "/"
  end

  let(:admin_page) { AdminDashboardPage.visit }
  let(:journal_page) { admin_page.visit_journal(journal) }

  describe "journal listing" do
    context "when the user is a site admin" do
      let(:user) { create :user, :site_admin }

      scenario "shows all journals" do
        journal_names = [journal, another_journal].map(&:name)
        expect(admin_page).to have_journal_names(*journal_names)
      end
    end

    context "when the user is a journal admin" do
      let(:user) { create :user }
      before { assign_journal_role(journal, user, :admin) }

      scenario "shows assigned journal" do
        # refresh page since we've assigned the journal role
        visit "/"

        expect(admin_page).to have_journal_names(journal.name)
      end
    end

    context "when the user is not a site admin or journal admin" do
      let(:user) { create :user }

      scenario "redirects to dashboard" do
        visit AdminDashboardPage.path
        expect(page).to have_no_content(AdminDashboardPage.admin_section)
      end
    end
  end

  describe "Visiting a journal" do
    scenario "shows workflows" do
      workflow_headers = journal.manuscript_manager_templates.pluck(:paper_type).map { |mmt_name| "#{mmt_name} #{journal.name.upcase}" }
      expect(journal_page.mmt_names).to match_array(workflow_headers)
    end

    scenario "editing a MMT" do
      mmt = journal.manuscript_manager_templates.first
      mmt_page = journal_page.visit_mmt(mmt)
      expect(mmt_page).to have_paper_type(mmt.paper_type)
    end

    describe "deleting a MMT" do
      let!(:mmt_to_delete) { FactoryGirl.create(:manuscript_manager_template, journal: journal) }

      it "deletes MMT" do
        journal_page.delete_mmt(mmt_to_delete)
        expect(journal_page).to have_no_mmt_name(mmt_to_delete.paper_type)
      end
    end
  end

  describe 'roles' do
    let!(:editor) do
      FactoryGirl.create(:user).tap do |editor|
        editor.assignments.create!(
          assigned_to: journal,
          role: journal.internal_editor_role
        )
      end
    end

    let!(:assignee) do
      FactoryGirl.create(:user)
    end

    before do
      admin_page.visit_journal(journal)
      find('.admin-nav-users').click
    end

    scenario 'add a role to a user' do
      find('.admin-user-search input').send_keys(assignee.last_name, :return)
      find('.assign-role-button').click
      find('.select2-focused').send_keys('publish', :return)
      expect(page).to have_content('Publishing Services')
    end

    scenario 'remove a role from a user' do
      find('.select2-container').click
      find('.select2-search-choice-close').click
      expect(page).to_not have_css('.select2-search-choice-close')
    end
  end
end
