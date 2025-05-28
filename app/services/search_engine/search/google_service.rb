class SearchEngine::Search::GoogleService < SearchEngine::Search::BaseService
  def parse_results(html, position_offset)
    doc = Nokogiri::HTML(html)
    search_results = doc.css('.ezO2md').take(10).map.with_index do |result, index|
      main_link = result.at_css('a.fuLhoc')
      title = main_link&.at_css('.CVA68e')&.text&.strip
      site_info = result.at_css('.dXDvrc .fYyStc')&.text&.strip
      description = result.at_css('.FrIlee .fYyStc')&.text&.strip
      url = main_link&.attr('href')
      url = url&.gsub('/url?q=', '')&.split('&')&.first if url
      {
        site_name: site_info,
        url: url || 'N/A',
        title: title || 'N/A',
        description: description || 'N/A',
        ranking: position_offset + index + 1
      }
    end
    {
      search_results: search_results
    }
  end

  def get_page_url(query, page_number)
    page_number == 0 ? 
      "https://www.google.com/search?q=#{CGI.escape(query)}&hl=#{@country}&ie=UTF-8&oe=UTF-8" :
      "https://www.google.com/search?q=#{CGI.escape(query)}&hl=#{@country}&start=#{page_number * 10}&ie=UTF-8&oe=UTF-8"
  end

  def results_per_page
    10
  end
end
