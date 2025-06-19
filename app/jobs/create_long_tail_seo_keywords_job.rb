class CreateLongTailSeoKeywordsJob < ApplicationJob
  queue_as :default

  def perform(seed_keyword:, count: 5)
    result = Ai::Seo::LongTailKeywordsService.new(seed_keyword: seed_keyword, count: count).call
    SeoKeyword.search_intents.keys.each do |search_intent|
      keywords = result["keywords_by_intent"][search_intent]
      keywords.each do |lt_keyword|
        next if SeoKeyword.exists?(name: lt_keyword["long_tail_keyword"], search_intent: search_intent)
        SeoKeyword.create!(
          name: lt_keyword["long_tail_keyword"].downcase,
          is_long_tail: true,
          search_intent: search_intent,
          pillar: seed_keyword,
          competition: lt_keyword["difficulty"],
          search_volume: lt_keyword["search_volume"]
        )
      end
    end
  end
end