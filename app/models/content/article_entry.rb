module Content
  class ArticleEntry
    attr_reader :title, :slug, :description, :date, :body, :related_paths

    def initialize(attributes)
      @title = attributes.fetch(:title)
      @slug = attributes.fetch(:slug)
      @description = attributes.fetch(:description)
      @date = parse_date(attributes.fetch(:date))
      @body = attributes[:body].to_s
      @related_paths = Array(attributes[:related_paths])
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
