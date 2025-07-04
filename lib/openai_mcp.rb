module OpenaiMcp
  def self.client
    @client ||= OpenAI::Client.new(access_token: Rails.application.credentials.openai_api_key)
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