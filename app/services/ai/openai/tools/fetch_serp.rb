module Ai
  module Openai
    module Tools
      module FetchSerp

        def self.tools
          [
            SearchEngineResults,
            SearchEngineResultsHtml,
            SearchEngineResultsText,
            DomainRanking,
            ScrapeWebPage,
            ScrapeDomain,
            ScrapeWebPageWithJs,
            KeywordsSearchVolume,
            KeywordsSuggestions,
            Backlinks,
            DomainEmails,
            WebPageAiAnalysis,
            WebPageSeoAnalysis,
            CheckIndexation,
            GenerateLongTailKeywords
          ]
        end
  
        def self.schema_list
          tools.map(&:schema)
        end

        class SearchEngineResults < BaseService
          def self.schema
            {
              type: "function",
              function: {
                name: "fetch_serp",
                description: "Fetches search engine results for a given keyword using the FetchSerp API. Allows to find the top ranking domains for a given keyword. Use this tool to find the top ranking domains for a given keyword. Allows to find which domains are ranking in which position for a given keyword. use this tool to find the top ranking domains for a given keyword or to find what domain ranks in x th position for a given keyword",
                parameters: {
                  type: "object",
                  properties: {
                    query: {
                      type: "string",
                      description: "The search query/keyword to look up"
                    },
                    search_engine: {
                      type: "string",
                      description: "The search engine to use (google, bing, duckduckgo, yahoo)",
                      enum: ["google", "bing", "duckduckgo", "yahoo"],
                      default: "google"
                    },
                    country: {
                      type: "string",
                      description: "The country code for localized results",
                      default: "us"
                    },
                    pages_number: {
                      type: "integer",
                      description: "Number of pages of results to fetch",
                      default: 1,
                      minimum: 1,
                      maximum: 10
                    }
                  },
                  required: ["query"]
                }
              }
            }
          end

          def self.call(params)
            client = ::FetchSerp::ClientService.new(user: User.find(params["user_id"]))
            results = client.search_engine_results(
              params["query"],
              params["search_engine"] || "google",
              params["country"] || "us",
              params["pages_number"] || 1
            )

            {
              results: results["data"]["results"],
              total_results: results["data"]["total_results"],
              search_engine: params["search_engine"] || "google",
              country: params["country"] || "us"
            }
          rescue => e
            {
              error: e.message
            }
          end
        end

        class SearchEngineResultsHtml < BaseService
          def self.schema
            {
              type: "function",
              function: {
                name: "search_engine_results_html",
                description: "Get HTML content of search engine results",
                parameters: {
                  type: "object",
                  properties: {
                    query: {
                      type: "string",
                      description: "The search query"
                    },
                    search_engine: {
                      type: "string",
                      description: "Search engine (google, bing, yahoo, duckduckgo)",
                      default: "google"
                    },
                    country: {
                      type: "string",
                      description: "Country code",
                      default: "us"
                    },
                    pages_number: {
                      type: "integer",
                      description: "Number of pages (1-30)",
                      default: 1
                    }
                  },
                  required: ["query"]
                }
              }
            }
          end

          def self.call(params)
            client = ::FetchSerp::ClientService.new(user: User.find(params["user_id"]))
            results = client.search_engine_results_html(
              params["query"],
              params["search_engine"] || "google",
              params["country"] || "us",
              params["pages_number"] || 1
            )

            {
              web_pages_html: results["data"]["results"],
              search_engine: params["search_engine"] || "google",
              country: params["country"] || "us"
            }
          rescue => e
            {
              error: e.message
            }
          end
        end

        class SearchEngineResultsText < BaseService
          def self.schema
            {
              type: "function",
              function: {
                name: "serp_text",
                description: "Get text content of search engine results pages",
                parameters: {
                  type: "object",
                  properties: {
                    query: {
                      type: "string",
                      description: "The search query"
                    },
                    search_engine: {
                      type: "string",
                      description: "Search engine (google, bing, yahoo, duckduckgo)",
                      default: "google"
                    },
                    country: {
                      type: "string",
                      description: "Country code",
                      default: "us"
                    },
                    pages_number: {
                      type: "integer",
                      description: "Number of pages to search (1-30)",
                      default: 1
                    }
                  },
                  required: ["query"]
                }
              }
            }
          end

          def self.call(params)
            client = ::FetchSerp::ClientService.new(user: User.find(params["user_id"]))
            results = client.search_engine_results_text(
              params["query"],
              params["search_engine"] || "google",
              params["country"] || "us",
              params["pages_number"] || 1
            )
            truncated_results = results["data"]["results"].map do |result|
              result.merge("text" => result["text"]&.slice(0, 2000))
            end

            {
              results: truncated_results,
              search_engine: params["search_engine"] || "google",
              country: params["country"] || "us"
            }
          rescue => e
            {
              error: e.message
            }
          end
        end

        class DomainRanking < BaseService
          def self.schema
            {
              type: "function",
              function: {
                name: "domain_ranking",
                description: "Get domain ranking for a keyword. use this tool to find the domain ranking for a given keyword. Do not use this tool if you were not provided with a domain.",
                parameters: {
                  type: "object",
                  properties: {
                    keyword: {
                      type: "string",
                      description: "The keyword to search"
                    },
                    domain: {
                      type: "string",
                      description: "The domain to check"
                    },
                    search_engine: {
                      type: "string",
                      description: "Search engine (google, bing, yahoo, duckduckgo)",
                      default: "google"
                    },
                    country: {
                      type: "string",
                      description: "Country code",
                      default: "us"
                    },
                    pages_number: {
                      type: "integer",
                      description: "Number of pages (1-30)",
                      default: 10
                    }
                  },
                  required: ["keyword", "domain"]
                }
              }
            }
          end

          def self.call(params)
            client = ::FetchSerp::ClientService.new(user: User.find(params["user_id"]))
            results = client.domain_ranking(
              params["keyword"],
              params["domain"],
              params["search_engine"] || "google",
              params["country"] || "us",
              params["pages_number"] || 10
            )

            {
              ranking: results["data"]["results"].first,
              search_engine: params["search_engine"] || "google",
              country: params["country"] || "us"
            }
          rescue => e
            {
              error: e.message
            }
          end
        end

        class ScrapeWebPage < BaseService
          def self.schema
            {
              type: "function",
              function: {
                name: "scrape_web_page",
                description: "Scrape a web page without JavaScript",
                parameters: {
                  type: "object",
                  properties: {
                    url: {
                      type: "string",
                      description: "The URL to scrape"
                    }
                  },
                  required: ["url"]
                }
              }
            }
          end

          def self.call(params)
            client = ::FetchSerp::ClientService.new(user: User.find(params["user_id"]))
            results = client.scrape_web_page(params["url"])

            {
              content: results["data"]["content"],
              title: results["data"]["title"],
              meta_description: results["data"]["meta_description"]
            }
          rescue => e
            {
              error: e.message
            }
          end
        end

        class ScrapeDomain < BaseService
          def self.schema
            {
              type: "function",
              function: {
                name: "scrape_domain",
                description: "Scrape multiple pages from a domain",
                parameters: {
                  type: "object",
                  properties: {
                    domain: {
                      type: "string",
                      description: "The domain to scrape"
                    },
                    max_pages: {
                      type: "integer",
                      description: "Maximum pages to scrape (up to 200)",
                      default: 10
                    }
                  },
                  required: ["domain"]
                }
              }
            }
          end

          def self.call(params)
            client = ::FetchSerp::ClientService.new(user: User.find(params["user_id"]))
            results = client.scrape_domain(
              params["domain"],
              params["max_pages"] || 10
            )

            {
              pages: results["data"]["pages"],
              total_pages: results["data"]["total_pages"]
            }
          rescue => e
            {
              error: e.message
            }
          end
        end

        class ScrapeWebPageWithJs < BaseService
          def self.schema
            {
              type: "function",
              function: {
                name: "scrape_web_page_with_js",
                description: "Scrape a web page with custom JavaScript to extract data",
                parameters: {
                  type: "object",
                  properties: {
                    url: {
                      type: "string",
                      description: "The URL to scrape"
                    },
                    js_script: {
                      type: "string",
                      description: "JavaScript code to execute. must start with 'return {' and end with '}'"
                    }
                  },
                  required: ["url"]
                }
              }
            }
          end

          def self.call(params)
            client = ::FetchSerp::ClientService.new(user: User.find(params["user_id"]))
            results = client.scrape_web_page_with_js(
              params["url"],
              params["js_script"]
            )

            {
              result: results["data"]["web_page"]
            }
          rescue => e
            {
              error: e.message
            }
          end
        end

        class KeywordsSearchVolume < BaseService
          def self.schema
            {
              type: "function",
              function: {
                name: "keywords_search_volume",
                description: "Get search volume for keywords",
                parameters: {
                  type: "object",
                  properties: {
                    keywords: {
                      type: "array",
                      items: { type: "string" },
                      description: "List of keywords"
                    },
                    country: {
                      type: "string",
                      description: "Country code",
                      default: "us"
                    }
                  },
                  required: ["keywords"]
                }
              }
            }
          end

          def self.call(params)
            client = ::FetchSerp::ClientService.new(user: User.find(params["user_id"]))
            results = client.keywords_search_volume(
              params["keywords"],
              params["country"] || "us"
            )

            {
              keywords: results["data"]["search_volume"]
            }
          rescue => e
            {
              error: e.message
            }
          end
        end

        class KeywordsSuggestions < BaseService
          def self.schema
            {
              type: "function",
              function: {
                name: "keywords_suggestions",
                description: "Get keyword suggestions based on URL or keywords",
                parameters: {
                  type: "object",
                  properties: {
                    url: {
                      type: "string",
                      description: "URL to base suggestions on"
                    },
                    keywords: {
                      type: "array",
                      items: { type: "string" },
                      description: "Keywords to base suggestions on"
                    },
                    country: {
                      type: "string",
                      description: "Country code",
                      default: "us"
                    }
                  },
                  required: []
                }
              }
            }
          end

          def self.call(params)
            client = ::FetchSerp::ClientService.new(user: User.find(params["user_id"]))
            results = client.keywords_suggestions(
              url: params["url"],
              keywords: params["keywords"],
              country: params["country"] || "us"
            )

            {
              suggestions: results["data"]["keywords_suggestions"]
            }
          rescue => e
            {
              error: e.message
            }
          end
        end

        class Backlinks < BaseService
          def self.schema
            {
              type: "function",
              function: {
                name: "backlinks",
                description: "Get backlinks for a domain",
                parameters: {
                  type: "object",
                  properties: {
                    domain: {
                      type: "string",
                      description: "The domain to check"
                    },
                    search_engine: {
                      type: "string",
                      description: "Search engine (google, bing, yahoo, duckduckgo)",
                      default: "google"
                    },
                    country: {
                      type: "string",
                      description: "Country code",
                      default: "us"
                    },
                    pages_number: {
                      type: "integer",
                      description: "Number of pages (1-30)",
                      default: 15
                    }
                  },
                  required: ["domain"]
                }
              }
            }
          end

          def self.call(params)
            client = ::FetchSerp::ClientService.new(user: User.find(params["user_id"]))
            results = client.backlinks(
              params["domain"],
              params["search_engine"] || "google",
              params["country"] || "us",
              params["pages_number"] || 15
            )

            {
              backlinks: results["data"]["backlinks"],
              total_backlinks: results["data"]["total_backlinks"]
            }
          rescue => e
            {
              error: e.message
            }
          end
        end

        class DomainEmails < BaseService
          def self.schema
            {
              type: "function",
              function: {
                name: "domain_emails",
                description: "Retrieves email addresses associated with a given domain",
                parameters: {
                  type: "object",
                  properties: {
                    domain: {
                      type: "string",
                      description: "The domain to search for emails"
                    },
                    search_engine: {
                      type: "string",
                      description: "Search engine (google, bing, yahoo, duckduckgo)",
                      default: "google"
                    },
                    country: {
                      type: "string",
                      description: "Country code",
                      default: "us"
                    },
                    pages_number: {
                      type: "integer",
                      description: "Number of pages to search (1-30)",
                      default: 1
                    }
                  },
                  required: ["domain"]
                }
              }
            }
          end

          def self.call(params)
            client = ::FetchSerp::ClientService.new(user: User.find(params["user_id"]))
            results = client.domain_emails(
              params["domain"],
              params["search_engine"] || "google",
              params["country"] || "us",
              params["pages_number"] || 1
            )

            {
              emails: results["data"]["emails"],
              total_emails: results["data"]["total_emails"]
            }
          rescue => e
            {
              error: e.message
            }
          end
        end

        class WebPageAiAnalysis < BaseService
          def self.schema
            {
              type: "function",
              function: {
                name: "web_page_ai_analysis",
                description: "Analyzes a web page using AI based on a provided prompt",
                parameters: {
                  type: "object",
                  properties: {
                    url: {
                      type: "string",
                      description: "The URL to analyze"
                    },
                    prompt: {
                      type: "string",
                      description: "The prompt to guide the AI analysis"
                    }
                  },
                  required: ["url", "prompt"]
                }
              }
            }
          end

          def self.call(params)
            client = ::FetchSerp::ClientService.new(user: User.find(params["user_id"]))
            results = client.web_page_ai_analysis(
              params["url"],
              params["prompt"]
            )

            {
              analysis: results["data"]["analysis"]
            }
          rescue => e
            {
              error: e.message
            }
          end
        end

        class WebPageSeoAnalysis < BaseService
          def self.schema
            {
              type: "function",
              function: {
                name: "web_page_seo_analysis",
                description: "Performs SEO analysis for a given web page",
                parameters: {
                  type: "object",
                  properties: {
                    url: {
                      type: "string",
                      description: "The URL to analyze"
                    }
                  },
                  required: ["url"]
                }
              }
            }
          end

          def self.call(params)
            client = ::FetchSerp::ClientService.new(user: User.find(params["user_id"]))
            params["url"] = "https://#{params["url"]}" unless params["url"].start_with?("http")
            results = client.web_page_seo_analysis(params["url"])

            {
              seo_analysis: results["data"]["analysis"]
            }
          rescue => e
            {
              error: e.message
            }
          end
        end

        class CheckIndexation < BaseService
          def self.schema
            {
              type: "function",
              function: {
                name: "check_indexation",
                description: "Checks if a domain is indexed for a specific keyword in search engines. Web pages can be indexed for a given keyword without ranking for this keyword. Use this tool to check if a domain is indexed for a specific keyword.",
                parameters: {
                  type: "object",
                  properties: {
                    domain: {
                      type: "string",
                      description: "The domain to check for indexation"
                    },
                    keyword: {
                      type: "string",
                      description: "The keyword to check indexation for"
                    }
                  },
                  required: ["domain", "keyword"]
                }
              }
            }
          end

          def self.call(params)
            response = ::FetchSerp::ClientService.new(user: User.find(params["user_id"])).check_indexation(
              domain: params["domain"],
              keyword: params["keyword"]
            )

            if response["error"]
              { error: response["error"] }
            else
              {
                domain: params["domain"],
                keyword: params["keyword"],
                indexed: response["data"]["indexation"]["indexed"],
                urls: response["data"]["indexation"]["urls"]
              }
            end
          rescue StandardError => e
            { error: e.message }
          end
        end

        class GenerateLongTailKeywords < BaseService
          def self.schema
            {
              type: "function",
              function: {
                name: "generate_long_tail_keywords",
                description: "Generates long-tail keywords from a seed keyword, optionally specifying the search intent and number of keywords to generate. Use this tool to get variations and related keywords for a given seed keyword.",
                parameters: {
                  type: "object",
                  properties: {
                    keyword: {
                      type: "string",
                      description: "The seed keyword to generate long-tail keywords from"
                    },
                    search_intent: {
                      type: "string",
                      description: "The search intent to generate long-tail keywords for. Supported values: informational, commercial, transactional, navigational. Defaults to informational.",
                      enum: %w[informational commercial transactional navigational]
                    },
                    count: {
                      type: "integer",
                      description: "The number of long-tail keywords to generate (1-500). Defaults to 10.",
                      minimum: 1,
                      maximum: 500
                    }
                  },
                  required: ["keyword"]
                }
              }
            }
          end

          def self.call(params)
            response = ::FetchSerp::ClientService.new(user: User.find(params["user_id"])).generate_long_tail_keywords(
              keyword: params["keyword"],
              search_intent: params["search_intent"] || "informational",
              count: params["count"]&.to_i || 10
            )

            if response["error"]
              { error: response["error"] }
            else
              {
                keyword: params["keyword"],
                search_intent: params["search_intent"] || "informational",
                keywords: response["data"]["long_tail_keywords"]
              }
            end
          rescue StandardError => e
            { error: e.message }
          end
        end

      end
    end
  end
end
