module OpenaiMcp
  # Returns a singleton OpenAI::Client from the official openai gem
  def self.client
    @client ||= OpenAI::Client.new(api_key: Rails.application.credentials.openai_api_key)
  end

  # Build the MCP tool definition for a given user's FetchSERP API key
  # @param api_key [String] the FetchSERP API key for the current user
  def self.mcp_tool(api_key)
    {
      type: "mcp",
      server_label: "fetchserp",
      server_url:   ENV.fetch("MCP_SERVER_URL", "https://www.fetchserp.com/mcp"),
      headers: {
        Authorization: "Bearer #{api_key}"
      }
    }
  end
end 