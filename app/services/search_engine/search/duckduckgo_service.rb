class SearchEngine::Search::DuckduckgoService < SearchEngine::Search::BaseService

  def parse_results(html, position_offset = 0)
    doc = Nokogiri::HTML(html)
    search_results = []

    results_table = doc.css('table').find { |table| table.css('tr').any? { |tr| tr.at_css('td:first-child')&.text&.strip&.match?(/^\d+\./) } }
    
    if results_table
      results_table.css('tr').each do |row|
        ranking_cell = row.at_css('td:first-child')
        next unless ranking_cell&.text&.strip&.match?(/^\d+\./)
        
        title_cell = row.at_css('td:last-child')
        title_link = title_cell&.at_css('a.result-link')
        next unless title_link
        
        description_row = row.next_element
        description = description_row&.at_css('td.result-snippet')&.text&.strip
        
        site_row = description_row&.next_element
        site_url = site_row&.at_css('td span.link-text')&.text&.strip
        
        url = title_link['href']
        if url
          url = url.match(/uddg=(.*?)&/)[1] if url.include?('uddg=')
          url = CGI.unescape(url)
        end
        
        search_results << {
          title: title_link.text.strip,
          url: url || 'N/A',
          description: description || 'N/A',
          site_name: site_url || 'N/A',
          ranking: position_offset + search_results.length + 1
        }
      end
    end

    {
      search_results: search_results,
      next_page: doc.at_css('form.next_form') ? true : false
    }
  end

  def get_page_url(query, page_number)
    start = (page_number * 10) + 1
    "https://lite.duckduckgo.com/lite/?q=#{query}&amp;s=1&amp;dc=#{start}&amp;v=l&amp;kl=#{@country}-#{get_lang(@country)}&amp;l=#{@country}-#{get_lang(@country)}"
  end

  def results_per_page
    10
  end

  # def initialize(country: "us", pages_number: 10, options: "{}")
  #   @country = country
  #   @pages_number = pages_number.to_i - 1
  #   @options = options.gsub("\\", "")
  # end
  # def call(query)
  #   url = "https://duckduckgo.com/?t=h_&q=#{query}&kl=#{@country}-#{get_lang(@country)}"
  #   serp = Scraper::PageEvaluatorService.new(url, @options).call(js_code)
  #   {
  #     errors: serp.present? ? [] : [{ message: "Error while fetching results" }],
  #     results: serp["search_results"]
  #   }
  # end

  # private
  # def js_code
  #   <<-JS
  #     const loadMorePromises = [...Array(#{@pages_number})].map(async (_, i) => {
  #       await new Promise(resolve => setTimeout(resolve, i * 500));
  #       const moreResultsButton = document.querySelector("#more-results");
  #       if (!moreResultsButton) return;
  #       moreResultsButton.click();
  #       await new Promise(resolve => setTimeout(resolve, 200));
  #       document.documentElement.scroll({ top: document.documentElement.scrollHeight });
  #     });
  #     return Promise.all(loadMorePromises).then(() => {
  #       return {
  #         serp_url: document.location.href,
  #         search_results: [...document.querySelectorAll("ol > li > article")].map((article, index) => ({
  #           site_name: article.querySelector("article > div:nth-child(2) p")?.textContent?.trim() || "N/A",
  #           url: article.querySelector("article > div:nth-child(3) a")?.getAttribute("href") || "N/A",
  #           title: article.querySelector("article > div:nth-child(3) h2")?.textContent?.trim() || "N/A",
  #           description: article.querySelector("article > div:nth-child(4) div")?.textContent?.trim() || "N/A",
  #           ranking: index + 1
  #         }))
  #       }
  #     });
  #   JS
  # end
end
