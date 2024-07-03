# Copyright 2023 Ian Lewis
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#      http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

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
      self.data['layout'] = 'tag'
      self.data['tag'] = tag
      self.data['category'] = category
      self.data['title'] = "Tag: #{tag}"
      self.data['blog'] = category
      self.data['pagination'] = {
        'enabled' => true,
        'category' => category,
        'tag' => tag,
      }
    end
  end
end
