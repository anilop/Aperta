class Question < ActiveRecord::Base
  belongs_to :task, inverse_of: :questions
  belongs_to :decision
  has_one :question_attachment, dependent: :destroy

  validates :ident, presence: true
end
