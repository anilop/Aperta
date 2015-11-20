#!/usr/bin/env python2
# -*- coding: utf-8 -*-
"""
This behavioral test case validates the Aperta Create New Submission through Submit process.
This test requires the following data:
A journal named "PLOS Wombat"
An MMT in that journal with no cards populated in its workflow, named "NoCards"
An MMT in that journal with only the initial decision card populated in its workflow, named "OnlyInitialDecisionCard"
The test document tarball from http://bighector.plos.org/aperta/docs.tar.gz extracted into frontend/assets/docs/
"""
__author__ = 'jgray@plos.org'

import os
import random
import time

from Base.Decorators import MultiBrowserFixture
from Base.Resources import login_valid_pw, au_login, rv_login, fm_login, ae_login, he_login, sa_login, oa_login
from frontend.common_test import CommonTest
from Cards.initial_decision_card import InitialDecisionCard
from Pages.dashboard import DashboardPage
from Pages.login_page import LoginPage
from Pages.manuscript_viewer import ManuscriptViewerPage
from Pages.workflow_page import WorkflowPage

users = [au_login]
admin_users = [oa_login, sa_login]

docx = ['2014_04_27 Bakowski et al main text_subm.docx',
        '120220_PLoS_Genetics_review.docx',
        'CRX.pone.0103411.docx',
        'GIANT-gender-main_20130310.docx',
        'NF-kB-Paper_manuscript.docx',
        'NorenzayanetalPLOS.docx',
        'pgen.1004127.docx',
        'PGENETICS-D-13-02065R1_FTC.docx',
        'PLosOne_Main_Body_Ravi_Bansal_Brad_REVISED.docx',
        'PONE-D-12-25504.docx',
        'PONE-D-12-27950.docx',
        'PONE-D-13-02344.docx',
        'PONE-D-13-14162.docx',
        'PONE-D-13-19782.docx',
        'PONE-D-13-38666.docx',
        'PONE-D-14-12686.docx',
        'PONE-D-14-17217.docx',
        'pone.0100365.docx',
        'pone.0100948.docx',
        'ppat.1004210.docx',
        'PPATHOGENS-D-14-01213.docx',
        'RTN.pone.0072333.docx',
        'Schallmo_PLOS_RevisedManuscript.docx',
        'Spindler_2014_rerevised.docx',
        'Thammasri_PONE_D13_12078_wo.docx',
        ]

cards = ['cover_letter',
         'billing',
         'figures',
         'authors',
         'supporting_info',
         'upload_manuscript',
         'prq',
         'review_candidates',
         'revise_task',
         'competing_interests',
         'data_availability',
         'ethics_statement',
         'financial_disclosure',
         'new_taxon',
         'reporting_guidelines',
         'changes_for_author',
         ]


@MultiBrowserFixture
class ApertaBDDCreatetoNormalSubmitTest(CommonTest):
  """
  Self imposed AC:
  Two separate tests: First test: Normal Submit
  1. Login as Author
  2. Create doc for full submission mmt
  3. Confirm db state for:
     publishing_state: unsubmitted
     gradual_engagement: true
  4. submit manuscript
  5. validate overlay elements and styles
  6. cancel submit
  7. ensure overlay clears Submit button still present
  8. submit again
  9. confirm submit
  10. ensure overlay clears Submitted message appears, submit button no longer shown
  11. Confirm db state for:
      publishing_state: submitted
      submitted_at: neither NULL nor ''
  """
  def test_validate_full_submit(self):
    """
    Validates the presence of the following elements:
      Optional Invitation Welcome text and button,
      My Submissions Welcome Text, button, info text and manuscript display
      Modals: View Invites and Create New Submission
    """
    user_type = random.choice(users)
    print('Logging in as user: ' + user_type)
    login_page = LoginPage(self.getDriver())
    login_page.enter_login_field(user_type)
    login_page.enter_password_field(login_valid_pw)
    login_page.click_sign_in_button()

    dashboard_page = DashboardPage(self.getDriver())
    # Validate Create New Submissions modal
    dashboard_page.click_create_new_submission_button()
    # We recently became slow drawing this overlay (20151006)
    time.sleep(.5)
    title = dashboard_page.title_generator()
    dashboard_page.enter_title_field(title)
    dashboard_page.select_journal_and_type('PLOS Wombat', 'NoCards')
    doc2upload = random.choice(docx)
    print('Sending document: ' + os.path.join(os.getcwd() + '/frontend/assets/docs/' + doc2upload))
    fn = os.path.join(os.getcwd() + '/frontend/assets/docs/' + doc2upload)
    if os.path.isfile(fn):
      self._driver.find_element_by_id('upload-files').send_keys(fn)
    else:
      raise IOError('Docx file not found')
    self._driver.find_element_by_id('upload-files').send_keys(fn)
    dashboard_page.click_upload_button()
    # Time needed for iHat conversion. This is not quite enough time in all circumstances
    time.sleep(5)
    manuscript_page = ManuscriptViewerPage(self.getDriver())
    manuscript_page.validate_ihat_conversions_success()
    manuscript_page.close_flash_message()
    time.sleep(2)
    paper_title_from_page = manuscript_page.get_paper_title_from_page()
    paper_id = manuscript_page.get_current_url().split('papers/')[1]
    manuscript_page.click_submit_btn()
    manuscript_page.validate_so_overlay_elements_styles('full_submit', paper_title_from_page)
    manuscript_page.confirm_submit_cancel()
    # The overlay mush be cleared to interact with the submit button
    # and it takes time
    time.sleep(.5)
    manuscript_page.click_submit_btn()
    manuscript_page.confirm_submit_btn()
    # Now we get the submit confirmation overlay
    # Sadly, we take time to switch the overlay
    time.sleep(1)
    manuscript_page.validate_so_overlay_elements_styles('congratulations', paper_title_from_page)
    manuscript_page.close_submit_overlay()
    manuscript_page.validate_submit_success()
    sub_data = manuscript_page.get_db_submission_data(paper_id)
    assert sub_data[0][0] == 'submitted', sub_data[0][0]
    assert sub_data[0][1] == False, 'Gradual Engagement: ' + sub_data[0][1]
    assert sub_data[0][2], sub_data[0][2]


@MultiBrowserFixture
class ApertaBDDCreatetoInitialSubmitTest(CommonTest):
  """
  Self imposed AC:
  Two separate tests: Second test: Initial Submit
  1. Login as Author
  2. Create doc for initial submission mmt
  3. Confirm db state for:
     publishing_state: unsubmitted
     gradual_engagement: true
  4. submit manuscript
  5. validate initial submit overlay elements and styles
  6. cancel submit
  7. ensure overlay clears Submit button still present
  8. submit again
  9. confirm submit
  10. ensure overlay clears Submitted message appears, submit button no longer shown
  11. Confirm db state for:
      publishing_state: initially_submitted
      submitted_at: neither NULL nor ''
  12. Log out as Author, Log in as Admin
  13. Open workflow page for document created in step 2)
  14. Open Initial Decision Card
  15. Randomly select to either:
      a. Reject; or
      b. Invite for Full Submission
  16. Enter appropriate text for email
  17. Click send feedback
  18. Close Card
  19. Confirm db state for:
      publishing state: a. rejected or b. in_revision
      If rejected, end test
  20. Log out as Admin, Log in as Author
  21. Open the relevant paper in the manuscript viewer, ensure editable and Submit (full)
  22. validate initial submit (final) overlay elements and style
  23. cancel submit
  24. resubmit (full)
  25. confirm submit
  26. Confirm db state for:
      publishing_state: submitted
      gradual_engagement: true
  """
  def test_validate_initial_submit(self):
    """
    Validates the presence of the following elements:
      Optional Invitation Welcome text and button,
      My Submissions Welcome Text, button, info text and manuscript display
      Modals: View Invites and Create New Submission
    """
    user_type = random.choice(users)
    print('Logging in as user: ' + user_type)
    login_page = LoginPage(self.getDriver())
    login_page.enter_login_field(user_type)
    login_page.enter_password_field(login_valid_pw)
    login_page.click_sign_in_button()

    dashboard_page = DashboardPage(self.getDriver())
    # Validate Create New Submissions modal
    dashboard_page.click_create_new_submission_button()
    # We recently became slow drawing this overlay (20151006)
    time.sleep(.5)
    title = dashboard_page.title_generator()
    dashboard_page.enter_title_field(title)
    dashboard_page.select_journal_and_type('PLOS Wombat', 'OnlyInitialDecisionCard')
    doc2upload = random.choice(docx)
    print('Sending document: ' + os.path.join(os.getcwd() + '/frontend/assets/docs/' + doc2upload))
    fn = os.path.join(os.getcwd() + '/frontend/assets/docs/' + doc2upload)
    if os.path.isfile(fn):
      self._driver.find_element_by_id('upload-files').send_keys(fn)
    else:
      raise IOError('Docx file not found')
    dashboard_page.click_upload_button()
    # Time needed for iHat conversion. This is not quite enough time in all circumstances
    time.sleep(7)
    manuscript_page = ManuscriptViewerPage(self.getDriver())
    manuscript_page.validate_ihat_conversions_success()
    manuscript_page.close_flash_message()
    time.sleep(2)
    paper_title_from_page = manuscript_page.get_paper_title_from_page()
    paper_url = manuscript_page.get_current_url()
    print('The paper ID of this newly created paper is: ' + paper_url)
    paper_id = paper_url.split('papers/')[1]
    manuscript_page.click_submit_btn()
    manuscript_page.validate_so_overlay_elements_styles('full_submit', paper_title_from_page)
    manuscript_page.confirm_submit_cancel()
    # The overlay mush be cleared to interact with the submit button
    # and it takes time
    time.sleep(.5)
    manuscript_page.click_submit_btn()
    manuscript_page.confirm_submit_btn()
    # Now we get the submit confirmation overlay
    # Sadly, we take time to switch the overlay
    time.sleep(2)
    manuscript_page.validate_so_overlay_elements_styles('congratulations', paper_title_from_page)
    manuscript_page.close_submit_overlay()
    manuscript_page.validate_initial_submit_success()
    sub_data = manuscript_page.get_db_submission_data(paper_id)
    assert sub_data[0][0] == 'initially_submitted', sub_data[0][0]
    assert sub_data[0][1] == True, 'Gradual Engagement: ' + sub_data[0][1]
    assert sub_data[0][2], sub_data[0][2]
    manuscript_page.logout()
    time.sleep(2)
    user_type = random.choice(admin_users)
    login_page = LoginPage(self.getDriver())
    login_page.enter_login_field(user_type)
    login_page.enter_password_field(login_valid_pw)
    login_page.click_sign_in_button()
    # Need time to finish initial redirect to dashboard page
    time.sleep(3)
    new_paper_url = paper_url + '/workflow'
    self._driver.get(new_paper_url)
    self._driver.navigated = True
    # time.sleep(20)
    workflow_page = WorkflowPage(self.getDriver())
    workflow_page.click_card('initial_decision')
    id_card = InitialDecisionCard(self.getDriver())
    id_card.validate_styles()
    decision = id_card.execute_decision()
    print(decision)
    id_card.click_close_button()
    sub_data = workflow_page.get_db_submission_data(paper_id)
    if decision == 'reject':
      assert sub_data[0][0] == 'rejected', sub_data[0][0]
      assert sub_data[0][1] == True, 'Gradual Engagement: ' + sub_data[0][1]
      assert sub_data[0][2], sub_data[0][2]
      return True
    elif decision == 'invite':
      assert sub_data[0][0] == 'in_revision', sub_data[0][0]
      assert sub_data[0][1] == True, 'Gradual Engagement: ' + sub_data[0][1]
      assert sub_data[0][2], sub_data[0][2]
    else:
      print('ERROR: no initial decision rendered')
      print(decision)
      return False
    workflow_page.logout()
    time.sleep(2)
    user_type = random.choice(users)
    login_page = LoginPage(self.getDriver())
    login_page.enter_login_field(user_type)
    login_page.enter_password_field(login_valid_pw)
    login_page.click_sign_in_button()
    # Need time to finish initial redirect to dashboard page
    time.sleep(3)
    self._driver.get(paper_url)
    self._driver.navigated = True
    time.sleep(2)
    manuscript_page = ManuscriptViewerPage(self.getDriver())
    paper_title_from_page = manuscript_page.get_paper_title_from_page()
    manuscript_page.click_submit_btn()
    manuscript_page.validate_so_overlay_elements_styles('initial_submit_full', paper_title_from_page)
    manuscript_page.confirm_submit_cancel()
    # The overlay mush be cleared to interact with the submit button
    # and it takes time
    time.sleep(.5)
    manuscript_page.click_submit_btn()
    manuscript_page.confirm_submit_btn()
    # Now we get the submit confirmation overlay
    # Sadly, we take time to switch the overlay
    time.sleep(2)
    manuscript_page.validate_so_overlay_elements_styles('congratulations', paper_title_from_page)
    manuscript_page.close_submit_overlay()
    manuscript_page.validate_submit_success()
    sub_data = manuscript_page.get_db_submission_data(paper_id)
    assert sub_data[0][0] == 'submitted', sub_data[0][0]
    assert sub_data[0][1] == True, 'Gradual Engagement: ' + sub_data[0][1]
    assert sub_data[0][2], sub_data[0][2]

if __name__ == '__main__':
  CommonTest._run_tests_randomly()
