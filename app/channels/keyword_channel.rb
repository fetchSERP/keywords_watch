class KeywordChannel < ApplicationCable::Channel
  def subscribed
    stream_from "keywords"
  end

  def unsubscribed
    # Any cleanup needed when channel is unsubscribed
  end
end
