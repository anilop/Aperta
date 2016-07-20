# Serializes AdhocAttachmnent(s).
class AdhocAttachmentSerializer < ActiveModel::Serializer
  has_one :task, embed: :id, polymorphic: true

  attributes :id, :title, :caption, :kind, :src, :status, :preview_src, :detail_src, :filename, :type
end