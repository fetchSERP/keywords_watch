class SearchEngine::Ranking::YandexService < SearchEngine::Ranking::BaseService
  def initialize(country: "us", domain:, options: "{slowMo: 650}")
    @country = country
    @domain = domain
    @options = options.gsub("\\", "")
  end

  def call(query)
    result = RuntimeExecutor::NodeService.new.call(js_code(query))
    return { results: [], errors: result["errors"] } if result["errors"].any?
    {
      results: [{
        url: (result["found_result"]["url"] rescue nil),
        ranking: (result["found_result"]["ranking"] rescue nil)
      }],
      errors: []
    }
  end

  private

  def js_code(query)
    <<-JS
      const { firefox } = require("playwright");

      (async () => {
        const browser = await firefox.launch(#{@options});
        const page = await browser.newPage();
        await page.goto("https://www.yandex.com/search?text=#{query}&lang=#{get_lang(@country)}");

        let positionOffset = 0;
        let foundResult = null;

        const run_script = (params) => {
          const positionOffset = params.positionOffset;
          const domain = params.domain;
          const articles = [...document.querySelectorAll("div > ul > li")];
          for (let i = 0; i < articles.length; i++) {
            const article = articles[i];
            const url = article.querySelector(".OrganicTitle-Link")?.getAttribute("href") || "N/A";

            if (url.includes(domain)) {
              return {
                found: true,
                ranking: positionOffset + i + 1,
                url: url
              };
            }
          }

          const next = document.querySelector(".Pager-Item_type_next")?.getAttribute("href") || null;
          return { found: false, next };
        };

        let pageCount = 0;
        while (pageCount < 50) {
          const data = await page.evaluate(run_script, { positionOffset, domain: "#{@domain}" });
          if (data.found) {
            foundResult = { ranking: data.ranking, url: data.url };
            break;
          }

          if (!data.next) break;

          positionOffset += 10;
          pageCount += 1;
          await page.goto("https://www.yandex.com" + data.next);
        }

        if (!foundResult) {
          console.log(JSON.stringify({ errors: [{ message: "No results found" }] }));
          await browser.close();
          return;
        }

        console.log(JSON.stringify({found_result: foundResult, errors: []}));
        await browser.close();
      })();
    JS
  end
end