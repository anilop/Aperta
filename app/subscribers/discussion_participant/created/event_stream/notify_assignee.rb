class DiscussionParticipant::Created::EventStream::NotifyAssignee < EventStreamSubscriber

  def channel
    private_channel_for(record.user)
  end

  def payload
    DiscussionParticipantSerializer.new(record).as_json
  end

  # on the client side, we must listen for being added to a discussion topic. when this
  # event comes down, we fetch our new topic and subscribe to it's eventstream channel.
  def action
    'discussion-participant-created'
  end

end
