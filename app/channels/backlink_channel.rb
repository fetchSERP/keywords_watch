class BacklinkChannel < ApplicationCable::Channel
  def subscribed
    stream_from "backlinks"
  end

  def unsubscribed
    # Any cleanup needed when channel is unsubscribed
  end
end
