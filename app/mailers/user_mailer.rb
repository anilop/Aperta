class UserMailer < ApplicationMailer
  include MailerHelper
  add_template_helper ClientRouteHelper
  add_template_helper TemplateHelper
  default from: Rails.configuration.from_email
  layout "mailer"

  class Error < ::StandardError ; end
  class DeliveryError < Error ; end

  after_action :prevent_delivery_to_invalid_recipient

  def add_collaborator(invitor_id, invitee_id, paper_id)
    @paper = Paper.find(paper_id)
    @invitor = User.find_by(id: invitor_id)
    @invitee = User.find_by(id: invitee_id)
    @invitor_name = display_name(@invitor)
    @invitee_name = display_name(@invitee)
    @journal = @paper.journal

    mail(
      to: @invitee.try(:email),
      subject: "You've been added as a collaborator to the manuscript, \"#{@paper.display_title}\"")
  end

  def add_participant(assigner_id, assignee_id, task_id)
    @task = Task.find(task_id)
    @paper = @task.paper
    @journal = @paper.journal
    @assigner = User.find_by(id: assigner_id)
    @assignee = User.find_by(id: assignee_id)
    @assigner_name = display_name(@assigner)
    @assignee_name = display_name(@assignee)

    mail(
      to: @assignee.try(:email),
      subject: "You've been added to a conversation on the manuscript, \"#{@paper.display_title}\"")
  end

  def add_editor_to_editors_discussion(invitee_id, task_id)
    @task = Task.find task_id
    @invitee = User.find invitee_id
    @invitee_name = display_name(@invitee)
    @paper = @task.paper

    mail(
      to: @invitee.email,
      subject: "You've been invited to the editor discussion for the manuscript, \"#{@paper.display_title}\"")
  end

  def mention_collaborator(comment_id, commentee_id)
    @comment = Comment.find(comment_id)
    @commenter = @comment.commenter
    @commentee = User.find(commentee_id)
    @task = @comment.task
    @paper = @task.paper
    @journal = @paper.journal

    mail(
      to: @commentee.try(:email),
      subject: "You've been mentioned on the manuscript, \"#{@paper.display_title}\"")
  end

  def notify_creator_of_check_submission(paper_id)
    @paper = Paper.find(paper_id)
    @author = @paper.creator
    @journal = @paper.journal

    mail(
      to: @author.try(:email),
      subject: "Thank you for submitting your manuscript to #{@journal.name}")
  end

  def notify_creator_of_revision_submission(paper_id)
    @paper = Paper.find(paper_id)
    @author = @paper.creator
    @journal = @paper.journal

    mail(
      to: @author.try(:email),
      subject: "Thank you for submitting your manuscript to #{@journal.name}")
  end

  def notify_creator_of_paper_submission(paper_id)
    @paper = Paper.find(paper_id)
    @author = @paper.creator
    @journal = @paper.journal

    mail(
      to: @author.try(:email),
      subject: "Thank you for submitting your manuscript to #{@journal.name}")
  end

  def notify_coauthor_of_paper_submission(paper_id, coauthor_id, coauthor_type)
    @paper = Paper.find(paper_id)
    @journal = @paper.journal

    return unless @journal.setting(:coauthor_confirmation_enabled).value

    @authors = @paper.all_authors
    @coauthor = coauthor_type.constantize.find(coauthor_id)

    mail(
      to: @coauthor.try(:email),
      reply_to: @journal.staff_email,
      subject: "Authorship Confirmation of Manuscript Submitted to #{@journal.name}")
  end

  def notify_creator_of_initial_submission(paper_id)
    @paper = Paper.find(paper_id)
    @author = @paper.creator
    @journal = @paper.journal
    @title = @paper.display_title(sanitized: false)

    mail(
      to: @author.try(:email),
      subject: "Thank you for submitting to #{@journal.name}")
  end

  def notify_staff_of_paper_withdrawal(paper_id)
    @paper = Paper.find paper_id
    @journal = @paper.journal
    @withdrawal = @paper.latest_withdrawal
    @authors = @paper.corresponding_authors

    if @journal.staff_email.blank?
      raise DeliveryError, <<-ERROR.strip_heredoc
        Journal (id=#{@journal.id} name=#{@journal.name}) has no staff email configured.
        The notify_staff_of_paper_withdrawal email cannot be sent.
      ERROR
    end

    mail(
      to: @journal.staff_email,
      subject: "#{@paper.doi} - Manuscript Withdrawn"
    )
  end

  def notify_mention_in_discussion(user_id, topic_id, reply_id = nil)
    @user = User.find(user_id)
    @reply = DiscussionReply.find(reply_id) if reply_id
    @topic = DiscussionTopic.find(topic_id)
    @paper = Paper.find(@topic.paper.id)

    mail(
      to: @user.email,
      subject: "Discussion on #{@paper.journal.name} manuscript #{@paper.short_doi}")
  end

  def notify_added_to_topic(invitee_id, invitor_id, topic_id)
    @invitor = User.find(invitor_id)
    @invitee = User.find(invitee_id)
    @topic = DiscussionTopic.find(topic_id)
    @paper = Paper.find(@topic.paper.id)

    mail(
      to: @invitee.email,
      subject: "#{@paper.short_doi}: Added to discussion by #{@invitor.first_name} #{@invitor.last_name}")
  end
end
