class CheckKeywordIndexationJob < ApplicationJob
  queue_as :default

  def perform(keyword)
    response = FetchSerp::ClientService.new.check_indexation(domain: keyword.domain.name, keyword: keyword.name)
    indexation = response["data"]["indexation"]
    if indexation["indexed"]
      keyword.update(indexed: true, urls: indexation["urls"])
      CreateRankingsJob.perform_later(keyword: keyword)
    end
  end
end