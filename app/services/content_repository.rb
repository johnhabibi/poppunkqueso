class ContentRepository
  class << self
    def updates
      @updates ||= load_updates
    end

    def find_update(slug)
      updates.find { |entry| entry.slug == slug }
    end

    def articles
      @articles ||= load_articles
    end

    def find_article(slug)
      articles.find { |entry| entry.slug == slug }
    end

    def homepage
      @homepage ||= load_yaml("home")
    end

    private

    def load_updates
      load_yaml("updates").map { |attrs| Content::UpdateEntry.new(attrs) }
                         .sort_by(&:date)
                         .reverse
    end

    def load_articles
      load_yaml("articles").map { |attrs| Content::ArticleEntry.new(attrs) }
                           .sort_by(&:date)
                           .reverse
    end

    def load_yaml(name)
      raw = YAML.load_file(Rails.root.join("config/content/#{name}.yml"))
      deep_symbolize(raw)
    end

    def deep_symbolize(object)
      case object
      when Array
        object.map { |item| deep_symbolize(item) }
      when Hash
        object.to_h { |key, value| [ key.to_sym, deep_symbolize(value) ] }
      else
        object
      end
    end
  end
end
