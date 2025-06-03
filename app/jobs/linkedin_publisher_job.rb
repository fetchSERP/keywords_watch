class LinkedinPublisherJob < ApplicationJob
  def perform
    Social::Linkedin::PublisherService.new.call
  end
end
