class CreateWebPagesJob < ApplicationJob
  queue_as :default

  def perform(domain:, count: 10)
    web_pages = FetchSerp::ClientService.new(user: domain.user).scrape_domain(domain.name, count)
    pages = web_pages.dig("data", "web_pages") || []

    pages.each do |web_page|
      begin
        doc = Nokogiri::HTML(web_page["html"])
        body_content = doc.at("body")&.text.to_s

        internal_links = doc.css("a").map { |a| a["href"] }.compact.select do |href|
          href.start_with?("/") || href.include?(domain.name)
        end

        external_links = doc.css("a").map { |a| a["href"] }.compact.reject do |href|
          href.start_with?("/") || href.include?(domain.name)
        end

        domain.web_pages.create!(
          user: domain.user,
          url: web_page["url"],
          title: doc.title,
          meta_description: doc.at_css("meta[name='description']")&.[]("content"),
          meta_keywords: doc.at_css("meta[name='keywords']")&.[]("content")&.split(",") || [],
          h1: doc.css("h1").map(&:text),
          h2: doc.css("h2").map(&:text),
          h3: doc.css("h3").map(&:text),
          h4: doc.css("h4").map(&:text),
          h5: doc.css("h5").map(&:text),
          body: body_content,
          word_count: body_content.split.size,
          internal_links: internal_links,
          external_links: external_links,
          canonical_url: doc.at_css("link[rel='canonical']")&.[]("href"),
          indexed: true,
        )
      rescue => e
        Rails.logger.error("Failed to process web page #{web_page['url']}: #{e.message}")
      end
    end

    KeywordsAiScoreJob.perform_later(domain: domain, count: 10)
  end
end