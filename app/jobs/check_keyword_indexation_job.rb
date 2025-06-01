class CheckKeywordIndexationJob < ApplicationJob
  queue_as :default

  def perform(keyword)
    begin
      encoded_keyword = URI.encode_www_form_component(keyword.name)
      response = FetchSerp::ClientService.new(user: keyword.user).check_indexation(domain: keyword.domain.name, keyword: encoded_keyword)
      indexation = response["data"]["indexation"]
      if indexation["indexed"]
        keyword.update!(indexed: true, urls: indexation["urls"])
        Turbo::StreamsChannel.broadcast_replace_to(
          "streaming_channel_#{keyword.user_id}",
          target: "keyword_#{keyword.id}",
          partial: "app/keywords/keyword",
          locals: { keyword: keyword }
        )
        Turbo::StreamsChannel.broadcast_update_to(
          "streaming_channel_#{keyword.user_id}",
          target: "indexed_keywords_count",
          partial: "app/domains/indexed_keywords_count",
          locals: { domain: keyword.domain }
        )
        CreateRankingsJob.perform_later(keyword: keyword)
      end
    rescue => e
      # binding.pry
      Rails.logger.error("Error checking indexation for keyword #{keyword.name}: #{e.message}")
    end
  end
end
