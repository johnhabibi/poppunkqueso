module Content
  class UpdateEntry
    attr_reader :title, :slug, :date, :intro, :theme, :featured_tracks, :bands_added, :closing_cta, :body

    def initialize(attributes)
      @title = attributes.fetch(:title)
      @slug = attributes.fetch(:slug)
      @date = parse_date(attributes.fetch(:date))
      @intro = attributes.fetch(:intro)
      @theme = attributes[:theme]
      @featured_tracks = Array(attributes[:featured_tracks])
      @bands_added = Array(attributes[:bands_added])
      @closing_cta = attributes[:closing_cta]
      @body = attributes[:body].to_s
    end

    def to_param
      slug
    end

    private

    def parse_date(value)
      return value if value.is_a?(Date)

      Date.iso8601(value.to_s)
    end
  end
end
