class CreateSeoPageJob < ApplicationJob
  queue_as :default

  def perform(seo_keyword)
    return if SeoPage.exists?(seo_keyword: seo_keyword)
    ai_page = Ai::Seo::PageService.new.call(seo_keyword)
    seo_keyword.create_seo_page!(
      slug: seo_keyword.name.parameterize,
      title: ai_page["title"],
      meta_description: ai_page["meta_description"],
      headline: ai_page["headline"],
      subheading: ai_page["subheading"],
      content: ai_page["content"],
      pillar: seo_keyword.pillar.present? ? seo_keyword.pillar.seo_page : nil
    )
  end
end
 