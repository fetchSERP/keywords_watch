class SearchEngine::Search::YandexService < SearchEngine::Search::BaseService

  # def parse_results(html, position_offset)
  #   doc = Nokogiri::HTML(html)
  #   binding.pry
  #   search_results = doc.css('div > ul > li').take(10).map.with_index do |result, index|
  #     title = result.at_css('.OrganicTitle-LinkText')&.text&.strip
  #     url = result.at_css('.OrganicTitle-Link')&.attr('href')
  #     description = result.at_css('.OrganicTextContentSpan')&.text&.strip
  #     { 
  #       site_name: result.at_css('.organic__path')&.text&.strip,
  #       url: url || 'N/A',
  #       title: title || 'N/A',
  #       description: description || 'N/A',
  #       ranking: position_offset + index + 1
  #     } 
  #   end
  #   {
  #     search_results: search_results
  #   }
  # end

  # def get_page_url(query, page_number)
  #   start = (page_number * 10) + 1
  #   "https://www.yandex.com/search?text=#{query}&lang=#{get_lang(@country)}&p=#{start}"
  # end

  # def results_per_page
  #   10
  # end

  # def initialize(country: "us", pages_number: 10, options: "{slowMo: 650, headless: false}")
  #   @country = country
  #   @pages_number = pages_number
  #   @options = options.gsub("\\", "")
  # end
  # def call(query)
  #   puts js_code(query)
  #   serps = RuntimeExecutor::NodeService.new.call(js_code(query))
  #   results = serps ? serps.map { |serp| serp["search_results"] }.flatten : []
  #   {
  #     errors: serps.present? ? [] : [{ message: "Error while fetching results" }],
  #     results: results
  #   }
  # end

  # private
  # def js_code(query)
  #   <<-JS
  #     const { chromium } = require("playwright-extra");
  #     const stealth = require("puppeteer-extra-plugin-stealth")();
  #     chromium.use(stealth);
  #     const run_script = (positionOffset) => {
  #       return {
  #         next: document.querySelector(".Pager-Item_type_next")?.getAttribute("href"),
  #         serp_url: document.location.href,
  #         search_results: [...document.querySelectorAll("div > ul > li")].map((article, index) => ({
  #           site_name: article.querySelector(".organic__path")?.textContent?.trim() || "N/A",
  #           url: article.querySelector(".OrganicTitle-Link")?.getAttribute("href") || "N/A",
  #           title: article.querySelector(".OrganicTitle-LinkText")?.textContent?.trim() || "N/A",
  #           description: article.querySelector(".OrganicTextContentSpan")?.textContent?.trim() || "N/A",
  #           ranking: positionOffset + index + 1
  #         }))
  #       };
  #     };
  #     (async () => {
  #       const browser = await chromium.launch(#{@options});
  #       const page = await browser.newPage();
  #       await page.goto("https://www.yandex.com/search?text=#{query}&lang=#{get_lang(@country)}");
  #       const results = [];
  #       let positionOffset = 0;
  #       while (true) {
  #         const data = await page.evaluate(run_script, positionOffset);
  #         results.push(data);
  #         positionOffset += data.search_results.length;
  #         if (!data.next || positionOffset / 10 >= #{@pages_number}) {
  #           break;
  #         }
  #         await page.goto("https://www.yandex.com" + data.next);
  #       }
  #       console.log(JSON.stringify(results));
  #       await browser.close();
  #     })();
  #   JS
  # end
end
