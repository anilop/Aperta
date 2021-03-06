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

class TasksController < ApplicationController
  before_action :authenticate_user!

  before_action :unmunge_empty_arrays, only: [:update]
  respond_to :json

  ## /paper/tasks/
  def index
    requires_user_can :view, paper
    tasks = paper.tasks.includes(:paper, :participations, :assigned_user, :card, :journal)

    # use task serializer instead of custom task serializer becuase it is lighter weight
    respond_with tasks, each_serializer: TaskSerializer
  end

  def show
    requires_user_can :view, task
    respond_with(task, location: task_url(task), include_card_version: true)
  end

  def create
    requires_user_can :manage_workflow, paper
    if does_not_violate_single_billing_task_condition?
      @task = TaskFactory.create(task_type, new_task_params)
    else
      return render status: :forbidden, text: 'Unable to add Billing Task because a Billing Task already exists for this paper. Note that you may not have permission to view the Billing Task card.'
    end

    respond_with(task, location: task_url(task))
  end

  def update
    requires_user_can :edit, task
    # If user is going to be removed get it to log Activity event
    last_assigned_user = task.assigned_user

    if task.completed?
      # If the task is already completed, all the user can do is uncomplete it,
      # assign an user or move it to a different phase in the workflow.
      attrs = task_params(task.class).slice(:completed, :assigned_user_id, :phase_id, :position)
      task.assign_attributes(attrs)
    else
      # At this point, the user could be doing one of two things.
      # 1. They are toggling the completed flag.
      # 2. They are updating the body or something else.
      task.assign_attributes(task_params(task.class))
      if task.completed_changed? && !task.ready?
        # They are marking the task completed, but the fields are not ready.
        # Roll back the change.
        render json: task.reload, serializer: TaskAnswerSerializer
        return
      end
    end

    task.save!
    task.after_update
    Activity.task_updated! task, user: current_user, last_assigned_user: last_assigned_user

    render task.update_responder.new(task, view_context).response
  end

  def update_position
    requires_user_can :manage_workflow, paper
    task.update!(position: params[:position])
    head 204
  end

  def destroy
    requires_user_can :manage_workflow, paper
    task.destroy
    respond_with(task)
  end

  def send_message
    requires_user_can :edit, task
    users = User.where(id: task_email_params[:recipients])
    users.each do |user|
      GenericMailer.delay.send_email(
        subject: task_email_params[:subject],
        body: task_email_params[:body],
        to: user.email,
        task: task
      )
    end
    head :no_content
  end

  # rubocop:disable Metrics/AbcSize
  # rubocop:disable Metrics/MethodLength
  def send_message_email
    requires_user_can :edit, task
    users = User.where(email: params[:recipients])
    sent_to_users = []
    users.each do |user|
      sent_to_users << user.email
      GenericMailer.delay.send_email(
        subject: params[:subject],
        body: params[:body],
        to: user.email,
        task: task
      )
    end
    trigger_email_sent_event(task)
    d = Time.now.getlocal
    initiator = current_user.email
    render json: {
      letter_template: {
        to: sent_to_users,
        from: initiator,
        date: d.strftime("%h %d, %Y %r"),
        subject: params[:subject],
        body: params[:body]
      }
    }
  end

  def sendback_email
    letter_template = task.journal.letter_templates.find_by(ident: 'preprint-sendbacks')
    letter_template.render(TechCheckScenario.new(task), check_blanks: false)

    GenericMailer.delay.send_email(
      subject: letter_template.subject,
      body: letter_template.body,
      to: letter_template.to,
      task: task
    )
    task.paper.minor_check!
    head :no_content
  end

  def nested_questions
    requires_user_can :view, task
    # Exclude the root node
    content = task.card.try(:content_for_version_without_root, :latest) || []
    respond_with(
      content,
      each_serializer: CardContentAsNestedQuestionSerializer,
      root: "nested_questions"
    )
  end

  def nested_question_answers
    requires_user_can :view, task
    respond_with(
      task.answers,
      each_serializer: AnswerAsNestedQuestionAnswerSerializer,
      root: "nested_question_answers"
    )
  end

  def load_email_template
    requires_user_can :edit, task
    template = render_email_template(task, params[:letter_template_name])
    render json: template
  end

  def render_template
    template = render_email_template(task, params[:ident])
    return head 404 if template.errors.present?
    render json: template
  end

  private

  def trigger_email_sent_event(task)
    Event.new(name: 'paper.email_sent', paper: task.paper, task: task, user: current_user).trigger
  end

  def render_email_template(task, template_ident)
    # This can only render templates whose scenarios wrap Task, Paper, or Journal as is
    # In the future LetterTemplates could define their own custom object selection mechanisms
    # Which would allow them to be rendered for custom objects
    template = task.paper.journal.letter_templates.find_by(ident: template_ident)
    template.render(template.scenario_class.new(template.object_for_task(task)))
  end

  def paper
    paper_id = params[:paper_id] || params.dig(:task, :paper_id)
    unless paper_id
      task = Task.find(params[:id] || params[:task_id])
      paper_id = task.paper_id
    end
    @paper ||= Paper.find_by_id_or_short_doi(paper_id)
  end

  def does_not_violate_single_billing_task_condition?
    billing_type_string = 'PlosBilling::BillingTask'
    if task_type.to_s == billing_type_string
      paper.tasks.where(type: billing_type_string).count.zero?
    else
      true
    end
  end

  def task
    @task ||= begin
      if params[:id].present?
        Task.find(params[:id])
      elsif params[:task_id].present?
        Task.find(params[:task_id])
      end
    end
  end

  def task_type
    Task.safe_constantize(params[:task][:type])
  end

  def new_task_params
    task_params(task_type).dup.tap do |new_params|
      new_params[:paper] = paper
      new_params[:creator] = paper.creator

      if params[:task][:card_id]
        # assign a specific card version
        card = paper.journal.cards.find(params[:task][:card_id])
        new_params[:card_version] = card.latest_published_card_version
      end
    end
  end

  def unmunge_empty_arrays
    unmunge_empty_arrays!(:task, task.array_attributes)
  end

  def task_params(task_klass)
    attributes = task_klass.permitted_attributes
    params.require(:task).permit(*attributes).tap do |whitelisted|
      whitelisted[:body] = params[:task][:body] || []
    end
  end

  def task_email_params
    params.require(:task).permit(:subject, :body, recipients: []).tap do |whitelisted|
      whitelisted[:subject] ||= "No subject"
      whitelisted[:body] ||= "Nothing to see here."
      whitelisted[:recipients] ||= []
    end
  end
end
