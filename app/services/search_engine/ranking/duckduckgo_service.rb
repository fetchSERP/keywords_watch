class SearchEngine::Ranking::DuckduckgoService < SearchEngine::Ranking::BaseService
  def initialize(country: "us", domain:, options: "{}")
    @country = country
    @domain = domain
    @options = options.gsub("\\", "")
  end

  def call(query)
    url = "https://duckduckgo.com/?t=h_&q=#{query}&kl=#{@country}-#{get_lang(@country)}"
    result = Scraper::PageEvaluatorService.new(url, @options).call(js_code(@domain))
    match = result["search_results"].find { |r| r["url"].include?(@domain) } rescue nil

    return { results: [], errors: [{ message: "No results found" }] } unless match

    {
      results: [{
        url: match["url"],
        ranking: match["ranking"]
      }],
      errors: []
    }
  end

  private

  def js_code(domain)
    <<-JS
      async function autoScrollAndClickMore() {
        const delay = ms => new Promise(resolve => setTimeout(resolve, ms));
        let results = [];
        let page = 0;
        let found = false;

        while (!found && page < 50) {
          const articles = [...document.querySelectorAll("ol > li > article")];
          for (let i = results.length; i < articles.length; i++) {
            const article = articles[i];
            const url = article.querySelector("article > div:nth-child(3) a")?.getAttribute("href") || "N/A";
            results.push({
              site_name: article.querySelector("article > div:nth-child(2) p")?.textContent?.trim() || "N/A",
              url: url,
              title: article.querySelector("article > div:nth-child(3) h2")?.textContent?.trim() || "N/A",
              description: article.querySelector("article > div:nth-child(4) div")?.textContent?.trim() || "N/A",
              ranking: results.length + 1
            });
            if (url.includes("#{domain}")) {
              found = true;
              break;
            }
          }

          if (found) break;

          const moreResultsButton = document.querySelector("#more-results");
          if (!moreResultsButton) break;

          moreResultsButton.click();
          await delay(1000);
          document.documentElement.scroll({ top: document.documentElement.scrollHeight });
          await delay(1000);
          page += 1;
        }

        return {
          serp_url: document.location.href,
          search_results: results
        };
      }

      return autoScrollAndClickMore();
    JS
  end
end