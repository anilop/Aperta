# This class represents a customized Task built with CardContent
class CustomCardTask < Task
  DEFAULT_TITLE = 'Custom Card'.freeze

  # unlike other answerables, a CustomCardTask class does not have
  # a concept of a latest card_version.  This is only determinable
  # from an instance of a CustomCardTask
  def self.latest_published_card_version
    # noop
  end
end
