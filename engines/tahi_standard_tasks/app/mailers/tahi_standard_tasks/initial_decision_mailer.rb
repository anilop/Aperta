module TahiStandardTasks
  class InitialDecisionMailer < ApplicationMailer
    include Rails.application.routes.url_helpers
    add_template_helper ClientRouteHelper
    layout "mailer"

    default from: ENV.fetch('FROM_EMAIL', 'no-reply@example.com')

    def notify(decision_id:)
      @decision = Decision.find(decision_id)
      @paper = @decision.paper
      @recipient = @paper.creator

      mail(to: @recipient.email,
           subject: "A decision has been registered on the manuscript, \"#{@paper.display_title}\"")
    end
  end
end
