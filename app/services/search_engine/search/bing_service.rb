class SearchEngine::Search::BingService < SearchEngine::Search::BaseService

  def parse_results(html, position_offset)
    doc = Nokogiri::HTML(html)
    search_results = doc.css('ol > li').take(10).map.with_index do |result, index|
      title = result.at_css('h2')&.text&.strip
      url = result.at_css('a')&.attr('href')
      description = result.at_css('p')&.text&.strip
      {
        site_name: result.at_css('div > a > div:nth-child(2) > div')&.text&.strip,
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
    "https://www.bing.com/search?q=#{query}&cc=#{@country}&setlang=#{@country.upcase}&setmkt=#{get_lang(@country)}-#{@country.upcase}&first=#{(page_number.to_i * 10) + 1}"
  end

  def results_per_page
    10
  end

  # def initialize(country: "us", pages_number: 1, options: "{}")
  #   @country = country
  #   @pages_number = pages_number.to_i
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

  # def js_code(query)
  #   <<-JS
  #     const { chromium } = require("playwright-extra");
  #     const stealth = require("puppeteer-extra-plugin-stealth")();
  #     chromium.use(stealth);

  #     const run_script = (positionOffset) => {
  #       return {
  #         next: [...document.querySelectorAll("ol > li > nav > ul > li")][[...document.querySelectorAll("ol > li > nav > ul > li")].length-1]?.querySelector("a")?.getAttribute("href"),
  #         serp_url: document.location.href,
  #         search_results: [...document.querySelectorAll("ol > li")].map((article, index) => ({
  #           site_name: article.querySelector("div > a > div:nth-child(2) > div")?.textContent?.trim() || "N/A",
  #           url: article.querySelector("h2 > a")?.getAttribute("href") || "N/A",
  #           title: article.querySelector("h2")?.textContent?.trim() || "N/A",
  #           description: article.querySelector("p")?.textContent?.trim() || "N/A",
  #           ranking: positionOffset + index + 1
  #         }))
  #       };
  #     };
  #     (async () => {
  #       const browser = await chromium.launch(#{@options});
  #       const page = await browser.newPage();
  #       await page.goto("https://www.bing.com/search?q=#{query}&cc=#{@country}&setlang=#{@country}&setmkt=#{get_lang(@country)}-#{@country.upcase}", { waitUntil: "networkidle" });
  #       const results = [];
  #       let positionOffset = 0;
  #       let pageNb = 0;
  #       while (true) {
  #         pageNb += 1;
  #         const data = await page.evaluate(run_script, positionOffset);
  #         results.push(data);
  #         positionOffset += data.search_results.length;
  #         if (!data.next || pageNb >= #{@pages_number}) {
  #           break;
  #         }
  #         await page.goto("https://www.bing.com" + data.next);
  #       }
  #       console.log(JSON.stringify(results));
  #       await browser.close();
  #     })();
  #   JS
  # end
end
