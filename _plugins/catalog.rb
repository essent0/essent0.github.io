# frozen_string_literal: true

# Builds the topic and subcategory pages from folder layout.
#
# A subcategory is a directory directly inside a topic collection:
#   _mathematics/<subcategory>/*.md
#   _computer_science/<subcategory>/*.md
# index.md in that directory is the subcategory introduction, not a note.
module NotesCatalog
  class GeneratedPage < Jekyll::Page
    def initialize(site, dir, data, content)
      @site = site
      @base = site.source
      @dir = dir
      @name = "index.md"
      process(@name)
      self.data = data
      self.content = content
    end
  end

  class Generator < Jekyll::Generator
    safe true
    priority :low

    def generate(site)
      site.pages.reject! { |page| page.data["catalog_generated"] }

      catalog = []
      (site.config["topics"] || []).each do |topic|
        entry = build_topic(site, topic)
        catalog << entry
        site.pages << topic_page(site, entry)
      end
      site.data["catalog"] = catalog
    end

    private

    def build_topic(site, topic)
      docs = site.collections[topic["collection"]]&.docs || []
      intros = {}
      notes = Hash.new { |hash, key| hash[key] = [] }

      docs.each do |doc|
        next if doc.data["published"] == false

        slug = subcategory_slug(doc)
        next if slug.nil? || slug.empty?

        if index_doc?(doc)
          intros[slug] = doc
          doc.data["published"] = false
        else
          notes[slug] << doc
        end
      end

      subcategories = (notes.keys | intros.keys).map do |slug|
        build_subcategory(site, topic, slug, intros[slug], notes[slug])
      end
      subcategories.sort_by! { |sub| [sub["order"], sub["title"].downcase] }

      {
        "name" => topic["name"],
        "slug" => topic["slug"],
        "collection" => topic["collection"],
        "description" => topic["description"].to_s,
        "url" => "/#{topic["slug"]}/",
        "subcategories" => subcategories
      }
    end

    def build_subcategory(site, topic, slug, intro, docs)
      title = subcategory_title(intro, slug)
      description = intro&.data&.[]("description").to_s
      url = "/#{topic["slug"]}/#{slug}/"
      sorted = docs.sort_by { |doc| sort_key(doc) }
      sorted.each { |doc| ensure_title(doc) }
      entries = sorted.map { |doc| note_entry(doc) }

      sorted.each_with_index do |doc, index|
        doc.data["topic_slug"] = topic["slug"]
        doc.data["topic_title"] = topic["name"]
        doc.data["topic_url"] = "/#{topic["slug"]}/"
        doc.data["subcategory_slug"] = slug
        doc.data["subcategory_title"] = title
        doc.data["subcategory_url"] = url
        doc.data["prev_note"] = index.positive? ? entries[index - 1] : nil
        doc.data["next_note"] = entries[index + 1]
      end

      site.pages << GeneratedPage.new(
        site,
        File.join(topic["slug"], slug),
        {
          "layout" => "subcategory",
          "title" => title,
          "description" => description,
          "topic_slug" => topic["slug"],
          "topic_title" => topic["name"],
          "topic_url" => "/#{topic["slug"]}/",
          "subcategory_slug" => slug,
          "subcategory_title" => title,
          "notes" => entries,
          "catalog_generated" => true
        },
        intro ? intro.content : ""
      )

      {
        "title" => title,
        "slug" => slug,
        "url" => url,
        "description" => description,
        "order" => numeric_order(intro&.data&.[]("order")),
        "notes" => entries
      }
    end

    def topic_page(site, entry)
      GeneratedPage.new(
        site,
        entry["slug"],
        {
          "layout" => "topic",
          "title" => entry["name"],
          "description" => entry["description"],
          "topic_slug" => entry["slug"],
          "topic_title" => entry["name"],
          "topic_url" => entry["url"],
          "subcategories" => entry["subcategories"],
          "collection" => entry["collection"],
          "catalog_generated" => true
        },
        ""
      )
    end

    def note_entry(doc)
      {
        "title" => doc.data["title"],
        "url" => doc.url
      }
    end

    def subcategory_slug(doc)
      parts = doc.relative_path.split("/")
      # _mathematics/<subcategory>/<file>.md
      return nil unless parts.length >= 3

      parts[1]
    end

    def index_doc?(doc)
      File.basename(doc.relative_path) == "index.md"
    end

    def subcategory_title(intro, slug)
      title = intro&.data&.[]("title")
      return titleize(slug) if title.nil? || title.to_s.strip.empty?

      title
    end

    def ensure_title(doc)
      return unless doc.data["title"].to_s.strip.empty?

      doc.data["title"] = fallback_title(doc.relative_path)
    end

    def sort_key(doc)
      [
        numeric_order(doc.data["order"]),
        File.basename(doc.relative_path).downcase,
        doc.data["title"].to_s.downcase
      ]
    end

    def numeric_order(value)
      value.nil? || value.to_s.strip.empty? ? 1_000_000 : value.to_i
    end

    def fallback_title(path)
      base = File.basename(path, ".*").sub(/^\d+[-_]/, "")
      titleize(base)
    end

    def titleize(slug)
      slug.split("-").reject(&:empty?).map(&:capitalize).join(" ")
    end
  end
end
