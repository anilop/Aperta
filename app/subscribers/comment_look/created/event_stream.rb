class CommentLook::Created::EventStream < EventStreamSubscriber

  def channel
    private_channel_for(record.user)
  end

  def payload
    owner = record.user
    CommentLookSerializer.new(record, user: owner).as_json
  end

end