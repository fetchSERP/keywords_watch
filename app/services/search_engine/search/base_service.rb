require 'countries'

class SearchEngine::Search::BaseService < BaseService
  def initialize(country: "us", pages_number: 1)
    @country = country
    @pages_number = pages_number.to_i
  end
  attr_reader :country, :pages_number

  def call(query)
    SearchEngine::Search::PaginateResultsService.new(self).call(query)
  end

  def get_lang(country)
    iso_country = ISO3166::Country[country.upcase]
    iso_country.languages.first
  end
end