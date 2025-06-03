class XPublisherJob < ApplicationJob
  def perform
    Social::X::PublisherService.new.call
  end
end
