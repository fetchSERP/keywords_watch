class ToolCallingAgentJob < ApplicationJob
  queue_as :default

  def perform(user_id, user_prompt)
    Ai::Openai::ToolCallingAgentService.new(user_id, user_prompt).call
  end
end