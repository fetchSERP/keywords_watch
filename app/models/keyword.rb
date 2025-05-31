class Keyword < ApplicationRecord
  belongs_to :user
  belongs_to :domain
  has_many :rankings, dependent: :destroy
  has_many :search_engine_results, dependent: :destroy
  after_commit :append_to_dom, on: :create
  after_update :update_dom
  after_commit :track, on: :create
  after_update :track, if: -> { saved_change_to_is_tracked? }
  validates :name, presence: true, uniqueness: { scope: :user_id }

  private

  def track
    if self.is_tracked
      check_indexation
      create_search_engine_results
      get_search_volume if self.avg_monthly_searches.nil?
    end
  end

  def check_indexation
    CheckKeywordIndexationJob.perform_later(self)
  end

  def create_search_engine_results
    CreateSearchEngineResultsJob.perform_later(keyword: self, search_engine: "google", pages_number: 2)
  end

  def get_search_volume
    GetSearchVolumeJob.perform_later(keyword: self)
  end

  def update_dom
    Turbo::StreamsChannel.broadcast_replace_to(
      "streaming_channel_#{user_id}",
      target: "keyword_#{id}",
      partial: "app/keywords/keyword",
      locals: { keyword: self }
    )
    Turbo::StreamsChannel.broadcast_update_to(
      "streaming_channel_#{user_id}",
      target: "indexed_keywords_count",
      partial: "app/domains/indexed_keywords_count",
      locals: { domain: domain }
    )
    Turbo::StreamsChannel.broadcast_update_to(
      "streaming_channel_#{user_id}",
      target: "ranked_keywords_count",
      partial: "app/domains/ranked_keywords_count",
      locals: { domain: domain }
    )
    Turbo::StreamsChannel.broadcast_update_to(
      "streaming_channel_#{user_id}",
      target: "domain_avg_rank",
      partial: "app/domains/avg_rank",
      locals: { domain: domain }
    )
  end

  def append_to_dom
    Turbo::StreamsChannel.broadcast_append_to(
      "streaming_channel_#{user_id}",
      target: "keywords",
      partial: "app/keywords/keyword",
      locals: { keyword: self }
    )
    Turbo::StreamsChannel.broadcast_update_to(
      "streaming_channel_#{user_id}",
      target: "keywords_count",
      partial: "app/domains/keywords_count",
      locals: { domain: domain }
    )
  end
end
