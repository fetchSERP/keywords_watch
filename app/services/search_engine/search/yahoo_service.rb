class SearchEngine::Search::YahooService < SearchEngine::Search::BaseService

  def parse_results(html, position_offset)
    doc = Nokogiri::HTML(html)
    search_results = doc.css('#web .algo').take(10).map.with_index do |result, index|
      main_link = result.at_css('.compTitle a')
      
      site_info = result.at_css('.d-ib.p-abs')
      site_name = if site_info
        site_name_span = site_info.at_css('.fc-141414.d-b')
        site_name_span&.text&.strip || site_info.text.strip
      end
      
      title = main_link&.at_css('.d-b.fz-20.lh-24.tc.ls-024.fw-500')&.text&.strip
      
      raw_url = main_link&.attr('href')
      url = clean_url(raw_url)
      
      description = result.at_css('.fc-dustygray.fz-14.lh-22.ls-02.mah-44.ov-h.d-box.fbox-ov.fbox-lc2')&.text&.strip
      
      {
        site_name: site_name || 'N/A',
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

  def clean_url(raw_url)
    return 'N/A' unless raw_url

    # Handle Yahoo redirect URLs
    if raw_url.include?('search.yahoo.com')
      if raw_url =~ /RU=([^\/]+)/
        encoded_url = $1
        decoded_url = CGI.unescape(encoded_url)
        decoded_url.split('/RK=').first
      else
        raw_url
      end
    else
      raw_url
    end
  end

  def get_page_url(query, page_number)
    start = (page_number * 7) + 1
    "https://search.yahoo.com/search?p=#{query}&vl=lang_#{get_lang(@country)}&vlb=y&intl=#{@country}&pz=#{results_per_page}&b=#{start}"
  end

  def results_per_page
    7
  end

  # def initialize(country: "us", pages_number: 10, options: "{slowMo: 650}")
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
  #       const articles = [...document.querySelectorAll("div > ol > li")];
  #       const results = [];

  #       for (let i = 0; i < articles.length; i++) {
  #         const article = articles[i];
  #         const url = article.querySelector("h3 > a")?.getAttribute("href") || "N/A";
  #         const title = article.querySelector("h3 > a")?.textContent?.trim() || "N/A";
  #         const description = article.querySelector("div > div > p")?.textContent?.trim() || "N/A";
  #         const site_name = article.querySelector(".d-ib.p-abs")?.textContent?.trim() || "N/A";

  #         if (url === "N/A") continue;

  #         results.push({
  #           site_name,
  #           url,
  #           title,
  #           description,
  #           ranking: positionOffset + results.length + 1,
  #         });
  #       }

  #       return {
  #         next: document.querySelector("a.next")?.getAttribute("href") || null,
  #         serp_url: document.location.href,
  #         search_results: results
  #       };
  #     };

  #     (async () => {
  #       const browser = await chromium.launch(#{@options});
  #       const page = await browser.newPage();
  #       await page.goto("https://search.yahoo.com/search?p=#{query}&vl=lang_#{get_lang(@country)}&vlb=y&intl=#{@country}");

  #       try {
  #         await page.click(".accept-all");
  #       } catch (_) {}

  #       await page.waitForSelector("div > ol > li", { timeout: 5000 });

  #       const results = [];
  #       let positionOffset = 0;
  #       let pageCount = 0;

  #       while (pageCount < #{@pages_number}) {
  #         const data = await page.evaluate(run_script, positionOffset);
  #         results.push(data);
  #         positionOffset += data.search_results.length;
  #         pageCount++;

  #         if (!data.next || pageCount >= #{@pages_number}) break;

  #         await page.goto(data.next);
  #         await page.waitForSelector("div > ol > li", { timeout: 5000 });
  #       }

  #       console.log(JSON.stringify(results));
  #       await browser.close();
  #     })();
  #   JS
  # end
end