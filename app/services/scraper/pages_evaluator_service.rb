# Use double quotes only in the JS code
class Scraper::PagesEvaluatorService < BaseService
  def initialize(urls, options = "{}")
    @urls = urls
    @options = options
  end

  def call(script)
    puts js_code(script)
    RuntimeExecutor::NodeService.new.call(js_code(script))
  end

  private
  def js_code(script)
    <<-JS
      const { firefox } = require("playwright");
      const { Mutex } = require("async-mutex");
      (async () => {
        const browser = await firefox.launch(#{@options});
        const results = [];
        const mutex = new Mutex();
        await Promise.all(
          #{@urls}.map(async(url) => {
            try {
              const page = await browser.newPage();
              await page.goto(url);
              const data = await page.evaluate(() => {
                #{script}
              });
              const release = await mutex.acquire();
              try {
                results.push(data);
              } finally {
                release();
              }
              await page.close();
            } catch (error) {}
          })
        );
        console.log(JSON.stringify(results));
        await browser.close();
      })();
    JS
  end
end
