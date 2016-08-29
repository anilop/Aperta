class InvitationSerializer < ActiveModel::Serializer
  attributes :id,
             :body,
             :created_at,
             :decline_reason,
             :email,
             :invitee_role,
             :reviewer_suggestions,
             :state,
             :updated_at

  has_one :invitee, serializer: UserSerializer, embed: :id, root: :users, include: true
  has_one :task, embed: :id, polymorphic: true
  has_many :attachments, embed: :id, polymorphic: true, include: true
  has_one :primary, embed: :id
  has_many :alternates, embed: :id
end
