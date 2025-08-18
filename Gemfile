source "https://rubygems.org"

# Happy Jekylling!
gem "jekyll", "= 4.4.1"

gem "logger", "= 1.7.0"
gem "bigdecimal", "= 3.2.2"

# Windows and JRuby does not include zoneinfo files, so bundle the tzinfo-data
# gem and associated library.
platforms :mingw, :x64_mingw, :mswin, :jruby do
  gem "tzinfo", "= 2.0.6"
  gem "tzinfo-data", "= 1.2025.2"
end

# Performance-booster for watching directories on Windows
gem "wdm", "= 0.2.0", :platforms => [:mingw, :x64_mingw, :mswin]

# Lock `http_parser.rb` gem to `v0.6.x` on JRuby builds since newer versions of
# the gem do not have a Java counterpart.
gem "http_parser.rb", "= 0.6.0", :platforms => [:jruby]

# Lock `ffi` gem to `< v1.17.0` on because it requires a higher version of
# rubygems than is available on Ubuntu 22.04.
# TODO(#207): Remove pinned version of ffi.
gem "ffi", "= 1.17.0"

group :jekyll_plugins do
  gem "jekyll-seo-tag", "= 2.8.0"
  gem "jekyll-paginate-v2", "= 3.0.0"
end
