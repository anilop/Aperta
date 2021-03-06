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

module TahiStandardTasks
  class PaperEditorTask < Task
    include ClientRouteHelper
    include Rails.application.routes.url_helpers
    DEFAULT_TITLE = 'Invite Academic Editor'.freeze
    DEFAULT_ROLE_HINT = 'admin'.freeze

    include Invitable

    def task_added_to_paper(paper)
      super
      create_invitation_queue!
    end

    def academic_editors
      paper.academic_editors
    end

    def invitation_invited(invitation)
      invitation.body = add_invitation_link(invitation)
      invitation.save!
      PaperEditorMailer.delay.notify_invited invitation_id: invitation.id
    end

    def invitation_accepted(invitation)
      add_invitee_as_academic_editor_on_paper!(invitation)
    end

    def invitation_rescinded(invitation)
      if invitation.invitee.present?
        invitation.invitee.resign_from!(assigned_to: invitation.task.journal,
                                        role: invitation.invitee_role)
      end
    end

    def active_invitation_queue
      self.invitation_queue || InvitationQueue.create(task: self)
    end

    def invitee_role
      Role::ACADEMIC_EDITOR_ROLE
    end

    def add_invitation_link(invitation)
      old_invitation_url = client_dashboard_url
      new_invitation_url = client_dashboard_url(
        invitation_token: invitation.token
      )
      invitation.body.gsub old_invitation_url, new_invitation_url
    end

    private

    # rubocop:enable Metrics/LineLength, Metrics/MethodLength

    def add_invitee_as_academic_editor_on_paper!(invitation)
      invitee = User.find(invitation.invitee_id)
      paper.add_academic_editor(invitee)
    end

    def abstract
      return 'Abstract is not available' unless paper.abstract
      paper.abstract
    end
  end
end
