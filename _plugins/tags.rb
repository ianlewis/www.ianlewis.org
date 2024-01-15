module Jekyll
  class TagPageGenerator < Generator
    safe true

    def generate(site)
      tags = site.posts.docs.flat_map { |post| post.data['tags'] || [] }.to_set
      tags.each do |tag|
        site.pages << TagPage.new(site, site.source, "en", tag)
        site.pages << TagPage.new(site, site.source, "jp", tag)
      end
    end
  end

  class TagPage < Page
    def initialize(site, base, category, tag)
      @site = site
      @base = base
      @dir  = File.join(category, 'tag', tag)
      @name = 'index.html'

      self.process(@name)
      self.read_yaml(File.join(base, '_layouts'), 'tag.html')
      self.data['tag'] = tag
      self.data['category'] = category
      self.data['title'] = "Tag: #{tag}"
    end
  end
end
