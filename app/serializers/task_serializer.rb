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

# Serializes properties for Ember
# rubocop:disable Style/PredicateName
class TaskSerializer < AuthzSerializer
  attributes :id,
             :assigned_to_me,
             :body,
             :card_version_id,
             :completed,
             :completed_proxy,
             :display_status,
             :is_metadata_task,
             :is_snapshot_task,
             :is_submission_task,
             :is_workflow_only_task,
             :links,
             :owner_type_for_answer,
             :paper_id,
             :phase_id,
             :position,
             :title,
             :type,
             :viewable

  has_one :assigned_user, embed: :id

  self.root = :task

  has_one :card_version, embed: :id, include: true

  def viewable
    scope.can?(:view, object)
  end

  def include_card_version?
    @options[:include_card_version] && object.custom?
  end

  def is_metadata_task
    object.metadata_task?
  end

  def is_submission_task
    object.submission_task?
  end

  def is_snapshot_task
    object.snapshottable?
  end

  def completed_proxy
    object.completed
  end

  def is_workflow_only_task
    object.latest_published_card_version.try(:workflow_display_only?) || false
  end

  def assigned_to_me
    # Reviewers are not participants on their own task
    if object.reviewer.blank?
      object.participations.map(&:user).include? scope
    else
      object.reviewer == scope
    end
  end

  def links
    {
      attachments: task_attachments_path(object),
      comments: task_comments_path(object),
      participations: task_participations_path(object),
      nested_questions: task_nested_questions_path(object),
      repetitions: task_repetitions_path(object),
      answers: answers_for_owner_path(owner_id: object.id, owner_type: object.class.name.underscore),
      nested_question_answers: task_nested_question_answers_path(object),
      snapshots: task_snapshots_path(object)
    }
  end
end
