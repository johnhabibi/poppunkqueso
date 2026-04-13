module ApplicationHelper
  def meta_title
    @meta_title
  end

  def meta_description
    @meta_description
  end

  def meta_image
    @meta_image
  end

  def meta_type
    @meta_type
  end

  def site_url
    Rails.application.config.x.site_url
  end

  def canonical_url
    return request.original_url if request

    site_url
  end

  def nav_link_to(label, path, data: nil)
    active = current_page?(path)
    classes = [
      "rounded-full px-4 py-2 text-sm font-semibold uppercase tracking-wide transition",
      (active ? "bg-ppq-red text-white" : "text-ppq-ink hover:bg-ppq-cream")
    ]

    link_to label, path, class: classes.join(" "), data: data
  end

  def platform_link_classes(primary: false)
    base = "inline-flex items-center justify-center rounded-full border px-5 py-3 text-sm font-semibold uppercase tracking-wide transition"
    if primary
      "#{base} border-ppq-red bg-gradient-to-r from-ppq-yellow to-ppq-red text-white hover:brightness-95"
    else
      "#{base} border-ppq-ink text-ppq-ink hover:bg-ppq-cream"
    end
  end

  def section_heading(eyebrow:, title:, body: nil)
    render "shared/section_heading", eyebrow: eyebrow, title: title, body: body
  end

  def json_ld_tag(payload)
    tag.script(payload.to_json.html_safe, type: "application/ld+json")
  end

  def render_content_blocks(text)
    safe_join(parse_blocks(text.to_s))
  end

  private

  def parse_blocks(text)
    blocks = []
    lines = text.split("\n")
    list_items = []

    flush_list = lambda do
      next if list_items.empty?

      blocks << content_tag(:ul, class: "list-disc space-y-2 pl-5 text-base leading-7 text-ppq-ink") do
        safe_join(list_items.map { |item| content_tag(:li, item) })
      end
      list_items = []
    end

    lines.each do |line|
      stripped = line.strip
      if stripped.start_with?("- ")
        list_items << stripped.delete_prefix("- ")
        next
      end

      flush_list.call
      next if stripped.blank?

      if stripped.start_with?("## ")
        blocks << content_tag(:h2, stripped.delete_prefix("## "), class: "mt-6 font-display text-2xl uppercase")
      else
        blocks << content_tag(:p, stripped, class: "text-base leading-7 text-ppq-ink")
      end
    end

    flush_list.call
    blocks
  end
end
