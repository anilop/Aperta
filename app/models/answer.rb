##
# This model will store the answer given to a piece of
# CardContent.
#
class Answer < ActiveRecord::Base
  acts_as_paranoid

  include Readyable

  belongs_to :card_content
  belongs_to :owner, polymorphic: true
  belongs_to :paper

  has_many :attachments, -> { order('id ASC') },
                              dependent: :destroy,
                              as: :owner,
                              class_name: 'QuestionAttachment'

  validates :card_content, presence: true
  validates :owner, presence: true
  validates :paper, presence: true

  delegate :value_type, to: :card_content

  TRUTHY_VALUES_RGX = /^(t|true|y|yes|1)/i

  validates :value, value: true, on: :ready

  # validates :value,
  #   on: :ready,
  #   presence: true,
  #   if: lambda {
  #     if card_content.ready_required_check == 'required'
  #       true
  #     elsif card_content.ready_required_check == 'if_parent_yes'
  #       card_content.try(:yes_no_value) == YES
  #     end
  #   }

  def children
    Answer.where(owner: owner, card_content: card_content.children)
  end

  # Just like the old NestedQuestionAnswer, the type of the 'value' column
  # in the database is a string, so any values that come out will have to
  # be coerced to the appropriate type before use.
  def string_value
    self[:value]
  end

  # 'value' is the coerced value of the answer, based on the value_type for
  # this answer's card content
  def value
    CoerceAnswerValue.coerce(string_value, value_type)
  end

  # The primary reason an answer will need to find its task is for permission
  # checks in various controllers, since our R&P system normally speaks in
  # Tasks rather than at a more granular level
  def task
    if owner.is_a?(Task)
      owner
    elsif owner.respond_to?(:task)
      owner.task
    else
      raise NotImplementedError, <<-ERROR.strip_heredoc
        The owner (#{owner.inspect}) is not a Task and does not respond to
        #task. This is currently unsupported on #{self.class.name} and if you
        meant it to work you may need to update the implementation.
      ERROR
    end
  end
end
