#!/usr/bin/env python2
# -*- coding: utf-8 -*-
"""
Page Object Model for the Journal specific Admin Page. Validates global and dynamic elements and their styles
This is really a shell of a test. It minimally validates the page elements, and not yet any of their functions.
We can extend this at a later time.
"""

import logging
import time

from selenium.webdriver.common.by import By
from selenium.webdriver.common.keys import Keys

from Base.PostgreSQL import PgSQL
from Base.CustomException import ElementDoesNotExistAssertionError
from admin import AdminPage

__author__ = 'jgray@plos.org'


class JournalAdminPage(AdminPage):
  """
  Model an aperta Journal specific Admin page
  """
  def __init__(self, driver, url_suffix='/'):
    super(JournalAdminPage, self).__init__(driver, url_suffix)

    # Locators - Instance members
    # Journals Admin Page
    self._journal_admin_users_title = (By.CLASS_NAME, 'admin-section-title')
    self._journal_admin_user_search_field = (By.CLASS_NAME, 'admin-user-search-input')
    self._journal_admin_user_search_button = (By.CLASS_NAME, 'admin-user-search-button')
    self._journal_admin_user_search_default_state_text = (By.CLASS_NAME, 'admin-user-search-default-state-text')
    self._journal_admin_user_search_results_table = (By.CLASS_NAME, 'admin-users')
    self._journal_admin_user_search_results_table_uname_header = (By.XPATH, '//table[1]/tr/th[1]')
    self._journal_admin_user_search_results_table_fname_header = (By.XPATH, '//table[1]/tr/th[2]')
    self._journal_admin_user_search_results_table_lname_header = (By.XPATH, '//table[1]/tr/th[3]')
    self._journal_admin_user_search_results_table_rname_header = (By.XPATH, '//table[1]/tr/th[4]')
    self._journal_admin_user_search_results_row = (By.CLASS_NAME, 'user-row')

    self._journal_admin_user_row_username = (By.CSS_SELECTOR, 'tr.user-row td')
    self._journal_admin_user_row_fname = (By.CSS_SELECTOR, 'tr.user-row td + td')
    self._journal_admin_user_row_lname = (By.CSS_SELECTOR, 'tr.user-row td + td + td')
    self._journal_admin_user_row_roles = (By.CSS_SELECTOR, 'tr.user-row td div ul.select2-choices li div')
    self._journal_admin_user_row_role_delete = (By.CSS_SELECTOR, 'tr.user-row td div ul.select2-choices li a')
    self._journal_admin_user_row_role_add = (By.CSS_SELECTOR, 'tr.user-row td div span.assign-role-button')
    self._journal_admin_user_row_role_add_field = (By.CSS_SELECTOR,
                                                   'tr.user-row td div div ul li.select2-search-field input')
    self._journal_admin_user_row_role_search_result_item = (By. CSS_SELECTOR, 'ul.select2-results li div')

    self._journal_admin_roles_title = (By.XPATH, '//div[@class="admin-section"][1]/h2')
    self._journal_admin_roles_add_new_role_btn = (By.CSS_SELECTOR, 'div.admin-section button')
    self._journal_admin_roles_role_table = (By.CLASS_NAME, 'admin-roles')
    self._journal_admin_roles_role_name_heading = (By.CSS_SELECTOR, 'div.admin-roles div.admin-roles-header')
    self._journal_admin_roles_permission_heading = (By.CSS_SELECTOR,
                                                    'div.admin-roles div.admin-roles-header + div.admin-roles-header')
    self._journal_admin_roles_role_listing_row = (By.CSS_SELECTOR, 'div.admin-roles div.admin-role')

    self._journal_admin_avail_task_types_div = (By.XPATH, '//div[@class="admin-section"][2]')
    self._journal_admin_avail_task_types_title = (By.XPATH, '//div[@class="admin-section"][2]/h2')
    self._journal_admin_avail_task_types_edit_btn = (By.XPATH, '//div[@class="admin-section"][2]/div')

    self._journal_admin_att_overlay_task_title_heading = (By.CSS_SELECTOR, 'div.task-headers h3')
    self._journal_admin_att_overlay_role_heading = (By.CSS_SELECTOR, 'div.task-headers h3 + h3')
    self._journal_admin_att_overlay_row = (By.CSS_SELECTOR, '.individual-task-type')
    self._journal_admin_att_overlay_row_taskname = (By.TAG_NAME, 'p')
    self._journal_admin_att_overlay_row_selector = (By.CSS_SELECTOR, 'div div.select2-container')
    self._journal_admin_att_overlay_row_clear_btn = (By.CSS_SELECTOR, 'div button')

    self._journal_admin_manu_mgr_templates_title = (By.XPATH, '//div[@class="admin-section"][3]/h2')
    self._journal_admin_manu_mgr_templates_button = (By.XPATH, '//div[@class="admin-section"][3]/button')
    self._journal_admin_manu_mgr_thumbnail = (By.CLASS_NAME, 'mmt-thumbnail')
    self._journal_admin_manu_mgr_thumb_title = (By.CSS_SELECTOR, 'h3.mmt-thumbnail-title')
    self._journal_admin_manu_mgr_thumb_phases = (By.TAG_NAME, 'span')

    self._journal_admin_style_settings_title = (By.XPATH, '//div[@class="admin-section"][4]/h2')
    self._journal_admin_upload_epub_cvr_btn = (By.CSS_SELECTOR, 'span.epub-cover-upload span.fileinput-button')
    self._journal_admin_epub_cvr_image_text = (By.CSS_SELECTOR, 'span.epub-cover-image p')
    self._journal_admin_epub_cvr_image_link = (By.CSS_SELECTOR, 'a.epub-cover')
    self._journal_admin_edit_epub_css_btn = (By.ID, 'edit-epub-css')
    self._journal_admin_edit_pdf_css_btn = (By.ID, 'edit-pdf-css')
    self._journal_admin_edit_ms_css_btn = (By.ID, 'edit-manuscript-css')

    self._journal_styles_css_overlay_field_label = (By.CSS_SELECTOR, 'div.overlay-header + p')
    self._journal_styles_css_overlay_field = (By.CSS_SELECTOR, 'div.overlay-header + p + textarea')
    self._journal_styles_css_overlay_cancel = (By.CSS_SELECTOR, 'div.overlay-action-buttons a')
    self._journal_styles_css_overlay_save = (By.CSS_SELECTOR, 'div.overlay-action-buttons a + button')

    self._mmt_template_name_field = (By.CSS_SELECTOR, 'input.edit-paper-type-field')
    self._mmt_template_error_msg = (By.CSS_SELECTOR, 'div.mmt-edit-error-message')
    self._mmt_template_save_button = (By.CSS_SELECTOR, 'div.paper-type-form a.paper-type-save-button')
    self._mmt_template_cancel_link = (By.CSS_SELECTOR, 'div.paper-type-form a.paper-type-cancel-button')
    self._mmt_template_add_phase_icons = (By.CSS_SELECTOR, 'i.fa-plus-square-o')
    self._mmt_template_columns = (By.CSS_SELECTOR, 'div.ember-view.column')
    self._mmt_template_column_title = (By.CSS_SELECTOR, 'div.column-header div h2')
    self._mmt_template_column_no_cards_card = (By.CSS_SELECTOR, 'div.sortable-no-cards')
    self._mmt_template_column_add_new_card_btn = (By.CSS_SELECTOR, 'a.button-secondary')

  # POM Actions
  def validate_users_section(self, journal):
    """
    Validate the elements and functions of the User search and role assignment areas of the page
    :param journal: journal to which to validate this section
    :return: void function
    """
    users_title = self._get(self._journal_admin_users_title)
    self.validate_application_h2_style(users_title)
    jid = PgSQL().query('SELECT id FROM journals WHERE name = %s;', (journal,))[0][0]
    logging.debug(jid)
    role_list = PgSQL().query('SELECT * FROM old_roles WHERE journal_id = %s;', (jid,)) or []
    logging.debug(role_list)
    roles_count = 0
    for role in role_list:
      rcount = PgSQL().query('SELECT count(user_id) from user_roles WHERE old_role_id in (%s);', (role[0],))[0][0]
      roles_count = roles_count + rcount
    logging.debug(roles_count)
    self._get(self._journal_admin_user_search_field)
    self._get(self._journal_admin_user_search_button)
    if roles_count > 0:
      self._get(self._journal_admin_user_search_results_table_uname_header)
      self._get(self._journal_admin_user_search_results_table_fname_header)
      self._get(self._journal_admin_user_search_results_table_lname_header)
      self._get(self._journal_admin_user_search_results_table_rname_header)
      self._get(self._journal_admin_user_search_results_table)
      page_user_list = self._gets(self._journal_admin_user_search_results_row)
      for user in page_user_list:
        print(user.text)
        print('\n')
    else:
      logging.info('No users assigned roles in journal: {}, so will add one...'.format(journal))
      self._add_user_with_role('jgray_author', 'Flow Manager')
      logging.info('Verifying added user')
      self._validate_user_with_role('jgray_author', 'Flow Manager')
      logging.info('Deleting newly added user')
      self._delete_user_with_role()
      time.sleep(3)

  def _add_user_with_role(self, user, role):
    """
    For user and role names, add to current journal
    :param user: existing user
    :param role: existing role
    :return: void function
    """
    user_title = self._get(self._journal_admin_users_title)
    self._actions.move_to_element(user_title).perform()
    user_input = self._get(self._journal_admin_user_search_field)
    search_btn = self._get(self._journal_admin_user_search_button)
    user_input.clear()
    self._actions.send_keys_to_element(user_input, user).perform()
    search_btn.click()
    self._get(self._journal_admin_user_row_role_add).click()
    role_search_field = self._get(self._journal_admin_user_row_role_add_field)
    self._actions.send_keys_to_element(role_search_field, role + Keys.RETURN).perform()

  def _validate_user_with_role(self, user, role):
    """
    For named user and role, ensure this exists for current journal
    :param user: user to validate
    :param role: role to validate
    :return: void function
    """
    page_user_list = self._gets(self._journal_admin_user_search_results_row)
    for row in page_user_list:
      assert user in row.text, row.text
      assert role in row.text, row.text

  def _delete_user_with_role(self):
    """
    Delete user role
    :return: void function
    """
    user_role_pill = self._get(self._journal_admin_user_row_roles)
    # For whatever reason, using action chains move_to_element() is failing here so doing a simple click
    user_role_pill.click()
    delete_role = self._get(self._journal_admin_user_row_role_delete)
    delete_role.click()

  def validate_roles_section(self):
    """
    Validate the elements and function of the Roles section of the journal admin page
    :return: void function
    """
    roles_title = self._get(self._journal_admin_roles_title)
    self._actions.move_to_element(roles_title).perform()
    self.validate_application_h2_style(roles_title)
    self._get(self._journal_admin_roles_add_new_role_btn)
    self._get(self._journal_admin_roles_role_table)
    role_rows = self._gets(self._journal_admin_roles_role_listing_row)
    count = 1
    for row in role_rows:
      logging.info(row.text)
      self._role_edit_icon = \
          (By.XPATH,
           "//div[@class='ember-view admin-role not-editing'][{}]\
              /div/i[@class='admin-role-action-button fa fa-pencil']".format(count))
      self._get(self._role_edit_icon)
      self._role_name = (By.XPATH, "//div[@class='ember-view admin-role not-editing'][{}]\
          /div/span".format(count))
      role_name = self._get(self._role_name)
      if role_name.text not in ('Admin', 'Flow Manager', 'Editor'):
        self._role_delete_icon = (By.XPATH,
            "//div[@class='ember-view admin-role not-editing'][{}]\
            /div/i[@class='admin-role-action-button role-delete-button fa fa-trash']".format(count))
        self._get(self._role_delete_icon)
      self._role_permissions_div = (By.XPATH, "//div[@class='ember-view admin-role not-editing'][{}]\
           /div[@class='admin-role-permissions']".format(count))
      self._get(self._role_permissions_div)
      self._role_assigned_permission = (By.XPATH, "//div[@class='ember-view admin-role not-editing'][{}]\
          /div[@class='admin-role-permissions']/label".format(count))
      self.set_timeout(1)
      try:
        self._gets(self._role_assigned_permission)
      except ElementDoesNotExistAssertionError:
        logging.warning('No permissions found for role {}'.format(role_name.text))
      try:
        self._get(self._role_permissions_div).find_elements(*self._role_assigned_permission)
      except ElementDoesNotExistAssertionError:
        logging.warning('No permissions found for role: {}'.format(role_name.text))
      self.restore_timeout()
      count += 1

  def validate_task_types_section(self):
    """
    Assert the existence and function of the elements of the Available Task Types section and overlay.
    It is expected that this section will change radically following the roles and permissions work,
    so not investing too much here at present.
    :return: void function
    """
    att_section = self._get(self._journal_admin_avail_task_types_div)
    task_names = ['Ad-hoc', 'Additional Information', 'Assign Admin', 'Assign Team', 'Authors', 'Billing',
                  'Competing Interests', 'Cover Letter', 'Data Availability', 'Editor Discussion', 'Ethics Statement',
                  'Figures', 'Final Tech Check', 'Financial Disclosure', 'Initial Decision', 'Initial Tech Check',
                  'Invite Academic Editor', 'Invite Reviewers', 'New Taxon', 'Production Metadata', 'Register Decision',
                  'Reporting Guidelines', 'Reviewer Candidates', 'Revision Tech Check', 'Send to Apex',
                  'Supporting Info', 'Upload Manuscript']
    att_title = self._get(self._journal_admin_avail_task_types_title)
    self.validate_application_h2_style(att_title)
    assert 'Available Task Types' in att_title.text, att_title.text
    edit_tt_btn = self._get(self._journal_admin_avail_task_types_edit_btn)
    assert 'EDIT TASK TYPES' in edit_tt_btn.text
    self._actions.move_to_element(att_section).perform()
    time.sleep(.5)
    edit_tt_btn.click()
    # time for animation of overlay
    time.sleep(.5)
    self._get(self._overlay_header_close)
    title = self._get(self._overlay_header_title)
    assert 'Available Task Types' in title.text, title.text
    task_title_heading = self._get(self._journal_admin_att_overlay_task_title_heading)
    assert 'Title' in task_title_heading.text
    role_heading = self._get(self._journal_admin_att_overlay_role_heading)
    assert 'Role' in role_heading.text, role_heading.text
    tasks = self._gets(self._journal_admin_att_overlay_row)
    for task in tasks:
      # There is little value in validating anything other than name as role assignment is up in the air.
      name = task.find_element(*self._journal_admin_att_overlay_row_taskname)
      assert name.text in task_names, name.text
      task.find_element(*self._journal_admin_att_overlay_row_selector)
      task.find_element(*self._journal_admin_att_overlay_row_clear_btn)

  def validate_mmt_section(self):
    """
    Assert the existence and function of the elements of the Manuscript Manager Templates section.
    Validate Add new template, edit existing templates, validate presentation of staging.
    :return: void function
    """
    time.sleep(1)
    dbmmts = []
    dbids = []
    mmts = []
    manu_mgr_title = self._get(self._journal_admin_manu_mgr_templates_title)
    self.validate_application_h2_style(manu_mgr_title)
    assert 'Manuscript Manager Templates' in manu_mgr_title.text, manu_mgr_title.text
    add_mmt_btn = self._get(self._journal_admin_manu_mgr_templates_button)
    assert 'ADD NEW TEMPLATE' in add_mmt_btn.text, add_mmt_btn.text
    try:
      mmts = self._gets(self._journal_admin_manu_mgr_thumbnail)
    except ElementDoesNotExistAssertionError:
      logging.error('No extant MMT found for Journal. This should never happen.')
    curr_journal_id = self._driver.current_url.split('/')[-1]
    db_mmts = PgSQL().query('SELECT paper_type, id '
                            'FROM manuscript_manager_templates '
                            'WHERE journal_id = %s;', (curr_journal_id,))
    for dbmmt in db_mmts:
      dbmmts.append(dbmmt[0])
      dbids.append(dbmmt[1])
    if mmts:
      count = 0
      for mmt in mmts:
        name = mmt.find_element(*self._journal_admin_manu_mgr_thumb_title)
        logging.info(name.text)
        assert name.text in dbmmts
        phases = mmt.find_element(*self._journal_admin_manu_mgr_thumb_phases)
        db_phase_count = PgSQL().query('SELECT count(*) '
                                       'FROM phase_templates '
                                       'WHERE manuscript_manager_template_id = %s;', (dbids[count],))[0][0]
        assert phases.text == str(db_phase_count), phases.text + ' != ' + str(db_phase_count)
        self._actions.move_to_element(mmt).perform()
        self._journal_admin_manu_mgr_thumb_edit = (By.CSS_SELECTOR, 'a.fa-pencil')
        mmt.find_element(*self._journal_admin_manu_mgr_thumb_edit)
        # Journals must have at least one MMT, so if only one, no delete icon is present
        if len(mmts) > 1:
          self._journal_admin_manu_mgr_thumb_delete = (By.CSS_SELECTOR, 'span.fa.fa-trash.animation-scale-in')
          mmt.find_element(*self._journal_admin_manu_mgr_thumb_delete)
        count += 1
    # Need to ensure the Add New Template button is not under the top toolbar
    att_title = self._get(self._journal_admin_avail_task_types_title)
    self._actions.move_to_element(att_title).perform()
    add_mmt_btn.click()
    time.sleep(2)
    self._validate_mmt_template_items()

  def validate_style_settings_section(self):
    """
    Validate the Roles section elements and permission assignment functions of the journal admin page
    :return: void function
    """
    styles_title = self._get(self._journal_admin_style_settings_title)
    self.validate_application_h2_style(styles_title)
    assert 'Style Settings' in styles_title.text, styles_title.text
    upload_epub_cover_btn = self._get(self._journal_admin_upload_epub_cvr_btn)
    self._actions.move_to_element(upload_epub_cover_btn).perform()
    assert 'UPLOAD EPUB COVER' in upload_epub_cover_btn.text
    self.set_timeout(1)
    try:
      epub_cvr_status_text = self._get(self._journal_admin_epub_cvr_image_text)
      assert epub_cvr_status_text.text == 'There is currently no default ePub cover.', epub_cvr_status_text.text
    except ElementDoesNotExistAssertionError:
      epub_cvr_img = self._get(self._journal_admin_epub_cvr_image_link)
      logging.info('An ePub Cover image has been uploaded for this journal: {0}'.format(epub_cvr_img.text))
    self.restore_timeout()
    edit_epub_css_btn = self._get(self._journal_admin_edit_epub_css_btn)
    assert edit_epub_css_btn.text == 'EDIT EPUB CSS', edit_epub_css_btn.text
    edit_epub_css_btn.click()
    time.sleep(.5)
    closer = self._get(self._overlay_header_close)
    title = self._get(self._overlay_header_title)
    assert 'ePub CSS' in title.text, title.text
    label = self._get(self._journal_styles_css_overlay_field_label)
    assert label.text == 'Enter or edit CSS to format the ePub output for this journal\'s papers.', label.text
    self._get(self._journal_styles_css_overlay_field)
    self._get(self._journal_styles_css_overlay_cancel)
    self._get(self._journal_styles_css_overlay_save)
    closer.click()
    time.sleep(.5)
    edit_pdf_css_btn = self._get(self._journal_admin_edit_pdf_css_btn)
    assert edit_pdf_css_btn.text == 'EDIT PDF CSS', edit_pdf_css_btn.text
    edit_pdf_css_btn.click()
    time.sleep(.5)
    self._get(self._overlay_header_close)
    title = self._get(self._overlay_header_title)
    assert 'PDF CSS' in title.text, title.text
    label = self._get(self._journal_styles_css_overlay_field_label)
    assert label.text == 'Enter or edit CSS to format the PDF output for this journal\'s papers.', label.text
    self._get(self._journal_styles_css_overlay_field)
    cancel = self._get(self._journal_styles_css_overlay_cancel)
    self._get(self._journal_styles_css_overlay_save)
    cancel.click()
    time.sleep(.5)
    edit_ms_css_btn = self._get(self._journal_admin_edit_ms_css_btn)
    assert edit_ms_css_btn.text == 'EDIT MANUSCRIPT CSS', edit_ms_css_btn.text
    edit_ms_css_btn.click()
    time.sleep(.5)
    self._get(self._overlay_header_close)
    title = self._get(self._overlay_header_title)
    assert 'Manuscript CSS' in title.text, title.text
    label = self._get(self._journal_styles_css_overlay_field_label)
    assert label.text == 'Enter or edit CSS to format the manuscript editor and output for this journal.', label.text
    self._get(self._journal_styles_css_overlay_field)
    self._get(self._journal_styles_css_overlay_cancel)
    save = self._get(self._journal_styles_css_overlay_save)
    save.click()

  def _validate_mmt_template_items(self):
    """
    Validate the elements of the manuscript manager template (aka paper type)
    :return: void function
    """
    template_field = self._get(self._mmt_template_name_field)
    # The default name should be Research
    assert 'Research' in template_field.get_attribute('value'), template_field.get_attribute('value')
    self._get(self._mmt_template_save_button)
    template_cancel = self._get(self._mmt_template_cancel_link)
    self._gets(self._mmt_template_add_phase_icons)
    time.sleep(3)
    columns = self._gets(self._mmt_template_columns)
    # For each column, validate its widgets
    for column in columns:
      col_title = column.find_element(*self._mmt_template_column_title)
      time.sleep(1)
      # For a reason I can't fathom, the first click is not always registered, second is always.
      col_title.click()
      col_title.click()
      # The click should pull up some column editing widgets.
      # We sometimes have a delayed drawing of these items
      time.sleep(1)
      self._mmt_template_column_delete = (By.CSS_SELECTOR, 'span.remove-icon')
      column.find_element(*self._mmt_template_column_delete)
      self._mmt_template_column_title_edit_cancel_btn = (By.CSS_SELECTOR, 'button.column-header-update-cancel')
      self._mmt_template_column_title_edit_save_btn = (By.CSS_SELECTOR, 'button.column-header-update-save')
      col_cancel = column.find_element(*self._mmt_template_column_title_edit_cancel_btn)
      column.find_element(*self._mmt_template_column_title_edit_save_btn)
      col_cancel.click()
      column.find_element(*self._mmt_template_column_no_cards_card)
      column.find_element(*self._mmt_template_column_add_new_card_btn)
    template_cancel.click()
    # Time to clear the overlay
    time.sleep(2)

  def add_new_mmt_template(self):
    """
    A function to add a new mmt (paper type) template to a journal
    :return: void function
    """
    logging.info('Add New Template called')
    # Need to ensure the Add New Template button is not under the top toolbar
    att_title = self._get(self._journal_admin_avail_task_types_title)
    self._actions.move_to_element(att_title).perform()
    add_mmt_btn = self._get(self._journal_admin_manu_mgr_templates_button)
    add_mmt_btn.click()
    time.sleep(.5)
    template_field = self._get(self._mmt_template_name_field)
    save_template_button = self._get(self._mmt_template_save_button)
    template_field.click()
    template_field.send_keys(Keys.ARROW_DOWN + '<-False')
    time.sleep(1)
    # If this mmt template already exists, this save should return an error and the name link won't exist
    save_template_button.click()
    time.sleep(1)
    self.set_timeout(2)
    try:
      logging.info('The following message will only be found if there is a particular data state, it is not an error.')
      msg = self._get(self._mmt_template_error_msg)
    except ElementDoesNotExistAssertionError:
      self._mmt_template_name_link = (By.CSS_SELECTOR, 'div.paper-type-name')
      self._get(self._mmt_template_name_link)
      self._journal_admin_manu_mgr_back_link = (By.CSS_SELECTOR, 'div.paper-type-form div + a')
      back_btn = self._get(self._journal_admin_manu_mgr_back_link)
      back_btn.click()
      self.restore_timeout()
      return
    assert 'Has already been taken' in msg.text, msg.text
    cancel = self._get(self._mmt_template_cancel_link)
    cancel.click()
    time.sleep(1)

  def delete_new_mmt_template(self):
    """
    A function to delete a newly added mmt (paper type) template to a journal
    :return: void function
    """
    logging.info('Delete New Template called')
    mmts = self._gets(self._journal_admin_manu_mgr_thumbnail)
    if mmts:
      count = 0
      for mmt in mmts:
        name = mmt.find_element(*self._journal_admin_manu_mgr_thumb_title)
        logging.info(name.text)
        self._actions.move_to_element(mmt).perform()
        self._journal_admin_manu_mgr_thumb_edit = (By.CSS_SELECTOR, 'a.fa-pencil')
        mmt.find_element(*self._journal_admin_manu_mgr_thumb_edit)
        # Journals must have at least one MMT, so if only one, no delete icon is present
        if len(mmts) > 1:
          self._journal_admin_manu_mgr_thumb_delete = (By.CSS_SELECTOR, 'span.fa.fa-trash.animation-scale-in')
          if name.text == 'Research<-False':
            logging.info('Found MMT to delete - moving to trash icon')
            time.sleep(1)
            delete_mmt = mmt.find_element(*self._journal_admin_manu_mgr_thumb_delete)
            logging.info('Clicking on MMT trash icon')
            self._actions.click(delete_mmt).perform()
            time.sleep(1)
            self._journal_admin_manu_mgr_delete_confirm_paragraph = (By.CSS_SELECTOR,
                                                                     'div.mmt-thumbnail-overlay-confirm-destroy p')
            confirm_text = self._get(self._journal_admin_manu_mgr_delete_confirm_paragraph)
            assert 'This will permanently delete your template. Are you sure?' in confirm_text.text, confirm_text.text
            self._journal_admin_manu_mgr_thumb_delete_cancel = (By.CSS_SELECTOR,
                                                                'div.mmt-thumbnail-overlay-confirm-destroy p + button')
            self._journal_admin_manu_mgr_thumb_delete_confirm = (By.CSS_SELECTOR, 'button.mmt-thumbnail-delete-button')
            time.sleep(1)
            self._get(self._journal_admin_manu_mgr_thumb_delete_cancel)  # cancel mmt delete should be present
            confirm_delete = self._get(self._journal_admin_manu_mgr_thumb_delete_confirm)
            confirm_delete.click()
            # If this mmt is found before the end of the list of mmt, the DOM will be stale so
            break
          else:
            mmt.find_element(*self._journal_admin_manu_mgr_thumb_delete)
        count += 1
