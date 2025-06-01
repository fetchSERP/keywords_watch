module DomainsHelper
  def keywords_performance_chart(domain)
    data = domain.keywords
                 .where(is_tracked: true)
                 .includes(:rankings)
                 .map do |keyword|
      {
        name: keyword.name,
        data: keyword.rankings
                     .group_by { |r| r.created_at.to_date.to_s }
                     .transform_values { |rs| rs.first.rank }
      }
    end

    line_chart(
      data,
      height: "100%",
      id: "performance-chart",
      colors: yellow_to_red_gradient(data.size),
      library: {
        plugins: {
          legend: {
            position: "bottom"
          }
        }
      }
    )
  end

  def yellow_to_red_gradient(count)
    (0...count).map do |i|
      ratio = i.to_f / (count - 1)
      r = 255
      g = (255 * (1 - ratio)).round
      b = 0
      format("#%02X%02X%02X", r, g, b)
    end
  end
end
