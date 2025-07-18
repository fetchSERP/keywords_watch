class UpdateContentPasswordJob < ApplicationJob
  queue_as :default

  def perform(email_address:, password:, password_confirmation:)
    uri = URI.parse("#{Rails.env.production? ? "https://content.fetchserp.com" : "http://localhost:3000"}/api/internal/users/update_password")
    request = Net::HTTP::Patch.new(uri)
    request.add_field("Authorization", "Bearer #{Rails.application.credentials.content_app_api_key}")
    request.set_form_data("email_address" => email_address, "password" => password, "password_confirmation" => password_confirmation)
    response = Net::HTTP.start(uri.hostname, uri.port, use_ssl: uri.scheme == "https") { |http| http.request(request) }
  end
end