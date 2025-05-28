class App::ChatMessagesController < App::ApplicationController
  def index
    @chat_messages = Current.user.chat_messages
  end

  def create
    @chat_message = Current.user.chat_messages.build(chat_message_params.merge(author: Current.user.email_address))
    if @chat_message.save
      render turbo_stream: [
        turbo_stream.prepend("chat_messages", partial: "app/chat_messages/message", locals: { message: @chat_message }),
        turbo_stream.replace("chat_input_form", partial: "app/chat_messages/form"),
        turbo_stream.prepend("chat_messages", partial: "app/chat_messages/temp_message")
      ]
      ToolCallingAgentJob.perform_later(Current.user.id, @chat_message.body)
    else
      render turbo_stream: turbo_stream.append("chat_messages", partial: "app/chat_messages/error", locals: { error: @chat_message.errors.full_messages.join(", ") })
    end
  end

  private
  def chat_message_params
    params.require(:chat_message).permit(:body)
  end
end