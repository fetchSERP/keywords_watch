class SearchEngine::Ranking::YahooService < SearchEngine::Ranking::BaseService
  def initialize(country: "us", domain:, options: "{}")
    @country = country
    @domain = domain
    @options = options.gsub("\\", "")
  end

  def call(query)
    result = RuntimeExecutor::NodeService.new.call(js_code(query))
    return { results: [], errors: result["errors"] } if result["errors"].any?
    {
      results: [{
        url: result["url"],
        ranking: result["ranking"]
      }],
      errors: []
    }
  end

  private

  def js_code(query)
    <<-JS
      const { firefox } = require("playwright");

      const run_script = ({ positionOffset, domain }) => {
        const articles = [...document.querySelectorAll("div > ol > li")].slice(3).slice(0, -1);
        const search_results = articles.map((article, index) => {
          const url = article.querySelector("h3 > a")?.getAttribute("href") || "N/A";
          return {
            site_name: article.querySelector(".d-ib.p-abs")?.textContent?.trim() || "N/A",
            url: url,
            title: article.querySelector("h3 > a")?.textContent?.trim() || "N/A",
            description: article.querySelector("div > div > p")?.textContent?.trim() || "N/A",
            ranking: positionOffset + index + 1,
            matched: url.includes(domain)
          };
        });

        const found = search_results.find(r => r.matched) || null;

        return {
          next: document.querySelector("a.next")?.getAttribute("href"),
          serp_url: document.location.href,
          search_results,
          found
        };
      };

      (async () => {
        try {
          const browser = await firefox.launch(#{@options});
          const page = await browser.newPage();
          await page.goto("https://search.yahoo.com/search?p=#{query}&vl=lang_#{get_lang(@country)}&vlb=y&intl=#{@country}");

          try {
            await page.click(".accept-all");
          } catch (e) {
            // No cookie banner
          }

          await page.waitForSelector("div > ol > li", { timeout: 5000 });

          let positionOffset = 0;
          let foundRank = null;
          let pageCount = 0;

          do {
            const data = await page.evaluate(run_script, { positionOffset, domain: "#{@domain}" });
            if (data.found) {
              foundRank = data.found.ranking;
              break;
            }
            positionOffset += data.search_results.length;
            if (!data.next) break;
            await page.goto(data.next);
            await page.waitForSelector("div > ol > li", { timeout: 5000 });
            pageCount += 1;
          } while (pageCount < 50);

          console.log(JSON.stringify({ query: "#{query}", domain: "#{@domain}", ranking: foundRank }));
          await browser.close();
        } catch (err) {
          console.error("Script failed:", err);
          console.log(JSON.stringify({ errors: [{ message: err.message }] }));
        }
      })();
    JS
  end
end