module DomainsHelper
  def keywords_performance_chart(domain)
    data = domain.keywords
                .where(is_tracked: true)
                .includes(:rankings)
                .map do |keyword|
      rankings_by_day = keyword.rankings
                              .group_by { |r| r.created_at.to_date.to_s }
                              .transform_values do |rs|
                                rs.reverse.find { |r| r.rank.present? }&.rank
                              end
  
      {
        name: keyword.name,
        data: rankings_by_day
      }
    end.reject { |series| series[:data].empty? || series[:data].values.all?(&:nil?) }
  
    max_rank = data.map { |series| series[:data].values.compact.max }.max

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
        },
        scales: {
          y: {
            min: 1,
            max: max_rank,
            title: {
              display: true,
              text: "Google Rank (lower is better)"
            }
          }
        }
      }
    )
  end

  def yellow_to_red_gradient(count)
    return ["#FFFF00"] if count <= 1 # Only one color (yellow) if no gradient needed
  
    (0...count).map do |i|
      ratio = i.to_f / (count - 1)
      r = 255
      g = (255 * (1 - ratio)).round
      b = 0
      format("#%02X%02X%02X", r, g, b)
    end
  end
  
end
