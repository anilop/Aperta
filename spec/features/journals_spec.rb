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

require 'rails_helper'
require 'support/pages/admin_dashboard_page'

# rubocop:disable Metrics/BlockLength
feature "Journal Administration", js: true do
  let(:user) { create :user, :site_admin }
  let!(:journal) { create :journal, :with_roles_and_permissions, description: 'journal 1 description' }
  let!(:journal2) { create :journal, :with_roles_and_permissions, description: 'journal 2 description' }

  before do
    login_as(user, scope: :user)
    visit "/"
  end

  let(:admin_page) { AdminDashboardPage.visit }
  let(:journal_page) { admin_page.visit_journal(journal) }

  describe "viewing your journals" do
    scenario "defaults to the showing workflows", selenium: true do
      expect(admin_page).to have_text('Workflow Catalogue')

      within(".left-drawer") do
        [journal.name, journal2.name].each do |journal_name|
          expect(admin_page).to have_css(".admin-drawer-item", text: journal_name)
        end
      end
    end
  end

  describe "creating a journal" do
    scenario "create new journal via new journal form after clicking on 'Add new journal' button" do
      admin_page
      click_on "Add New Journal"
      within(".admin-new-journal-overlay") do
        fill_in "name", with: "New Journal Cool Cool"
        fill_in "description", with: "New journal description cool cool"
        fill_in "doiJournalPrefix", with: "journal.prefix"
        fill_in "doiPublisherPrefix", with: "prefix"
        fill_in "lastDoiIssued", with: "1000001"
        click_on "Save"
      end

      using_wait_time(120) do # Creating a journal takes time
        expect(admin_page).to have_journal_names(journal.name, journal2.name, 'New Journal Cool Cool')
      end

      admin_page.reload sync_on: 'Add new journal'
      expect(admin_page).to have_journal_names(journal.name, journal2.name, 'New Journal Cool Cool')
    end
  end

  describe "editing a journal thumbnail", selenium: true do
    scenario "shows edit form after clicking on journal in sidebar, then settings" do
      journal_edit_form = admin_page.edit_journal journal.name
      journal_edit_form.name = "Edited journal"
      journal_edit_form.description = "Edited journal description"
      # FIXME: Waiting on the s3 work to be done
      # journal_edit_form.attach_cover_image 'yeti.jpg', journal.id
      journal_edit_form.save

      journal_edit_form = admin_page.edit_journal "Edited journal"
      journal_edit_form.name = "cancel Edited journal"
      journal_edit_form.description = "cancel Edited journal description"
      journal_edit_form.cancel

      expect(admin_page).to have_journal_names('Edited journal', journal2.name)
      admin_page.reload sync_on: 'Add new journal'
      expect(admin_page).to have_journal_names('Edited journal', journal2.name)
    end
  end
end
