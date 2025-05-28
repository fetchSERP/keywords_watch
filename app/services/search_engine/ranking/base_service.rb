class SearchEngine::Ranking::BaseService < BaseService
  def get_lang(country)
    iso_country = ISO3166::Country[country.upcase]
    iso_country.languages.first
  end
end