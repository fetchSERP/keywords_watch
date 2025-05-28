class SearchEngine::Ranking::BingService < SearchEngine::Ranking::BaseService
  def initialize(country: "us", domain:, options: "{}")
    @country = country
    @domain = domain
    @options = options.gsub("\\", "")
  end

  def call(query)
    puts js_code(query)
    result = RuntimeExecutor::NodeService.new.call(js_code(query))
    { results: [result], errors: result["errors"].any? ? result["errors"] : [] }
  end

  private

  def js_code(query)
    <<-JS
      const { chromium } = require("playwright-extra");
      const stealth = require("puppeteer-extra-plugin-stealth")();
      chromium.use(stealth);

      const run_script = (positionOffset) => {
        return {
          next: [...document.querySelectorAll("ol > li > nav > ul > li")][[...document.querySelectorAll("ol > li > nav > ul > li")].length-1]?.querySelector("a")?.getAttribute("href"),
          search_results: [...document.querySelectorAll("ol > li")].map((article, index) => ({
            url: article.querySelector("h2 > a")?.getAttribute("href") || "N/A",
            ranking: positionOffset + index + 1
          }))
        };
      };

      (async () => {
        const browser = await chromium.launch(#{@options});
        const page = await browser.newPage();
        await page.goto("https://www.bing.com/search?q=#{query}&cc=#{@country}&setlang=#{@country}&setmkt=#{get_lang(@country)}-#{@country.upcase}");

        let positionOffset = 0;
        let pageCount = 0;
        while (pageCount < 50) {
          const data = await page.evaluate(run_script, positionOffset);
          for (const result of data.search_results) {
            if (result.url.includes("#{@domain}")) {
              console.log(JSON.stringify({ query: "#{query}", domain: "#{@domain}", url: result.url, ranking: result.ranking, errors: [] }));
              await browser.close();
              return;
            }
          }

          positionOffset += data.search_results.length;
          pageCount += 1;

          if (!data.next) break;

          await page.goto("https://www.bing.com" + data.next);
        }

        console.log(JSON.stringify({ errors: [{ message: "No results found" }] }));
        await browser.close();
      })();
    JS
  end
end