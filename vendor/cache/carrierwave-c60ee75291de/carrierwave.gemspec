# -*- encoding: utf-8 -*-
# stub: carrierwave 0.10.0 ruby lib

Gem::Specification.new do |s|
  s.name = "carrierwave"
  s.version = "0.10.0"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.require_paths = ["lib"]
  s.authors = ["Jonas Nicklas"]
  s.date = "2015-08-19"
  s.description = "Upload files in your Ruby applications, map them to a range of ORMs, store them on different backends."
  s.email = ["jonas.nicklas@gmail.com"]
  s.extra_rdoc_files = ["README.md"]
  s.files = ["README.md", "lib/carrierwave", "lib/carrierwave.rb", "lib/carrierwave/compatibility", "lib/carrierwave/compatibility/paperclip.rb", "lib/carrierwave/error.rb", "lib/carrierwave/locale", "lib/carrierwave/locale/cs.yml", "lib/carrierwave/locale/de.yml", "lib/carrierwave/locale/el.yml", "lib/carrierwave/locale/en.yml", "lib/carrierwave/locale/es.yml", "lib/carrierwave/locale/fr-CA.yml", "lib/carrierwave/locale/fr.yml", "lib/carrierwave/locale/ja.yml", "lib/carrierwave/locale/nb.yml", "lib/carrierwave/locale/nl.yml", "lib/carrierwave/locale/pl.yml", "lib/carrierwave/locale/pt-BR.yml", "lib/carrierwave/locale/pt-PT.yml", "lib/carrierwave/locale/ru.yml", "lib/carrierwave/locale/sk.yml", "lib/carrierwave/locale/tr.yml", "lib/carrierwave/locale/zh-CN.yml", "lib/carrierwave/locale/zh-TW.yml", "lib/carrierwave/mount.rb", "lib/carrierwave/mounter.rb", "lib/carrierwave/orm", "lib/carrierwave/orm/activerecord.rb", "lib/carrierwave/processing", "lib/carrierwave/processing.rb", "lib/carrierwave/processing/magic_mime_types.rb", "lib/carrierwave/processing/mime_types.rb", "lib/carrierwave/processing/mini_magick.rb", "lib/carrierwave/processing/rmagick.rb", "lib/carrierwave/sanitized_file.rb", "lib/carrierwave/storage", "lib/carrierwave/storage.rb", "lib/carrierwave/storage/abstract.rb", "lib/carrierwave/storage/file.rb", "lib/carrierwave/storage/fog.rb", "lib/carrierwave/test", "lib/carrierwave/test/matchers.rb", "lib/carrierwave/uploader", "lib/carrierwave/uploader.rb", "lib/carrierwave/uploader/cache.rb", "lib/carrierwave/uploader/callbacks.rb", "lib/carrierwave/uploader/configuration.rb", "lib/carrierwave/uploader/default_url.rb", "lib/carrierwave/uploader/download.rb", "lib/carrierwave/uploader/extension_blacklist.rb", "lib/carrierwave/uploader/extension_whitelist.rb", "lib/carrierwave/uploader/file_size.rb", "lib/carrierwave/uploader/magic_mime_blacklist.rb", "lib/carrierwave/uploader/magic_mime_whitelist.rb", "lib/carrierwave/uploader/mountable.rb", "lib/carrierwave/uploader/processing.rb", "lib/carrierwave/uploader/proxy.rb", "lib/carrierwave/uploader/remove.rb", "lib/carrierwave/uploader/serialization.rb", "lib/carrierwave/uploader/store.rb", "lib/carrierwave/uploader/url.rb", "lib/carrierwave/uploader/versions.rb", "lib/carrierwave/utilities", "lib/carrierwave/utilities.rb", "lib/carrierwave/utilities/deprecation.rb", "lib/carrierwave/utilities/uri.rb", "lib/carrierwave/validations", "lib/carrierwave/validations/active_model.rb", "lib/carrierwave/version.rb", "lib/generators", "lib/generators/templates", "lib/generators/templates/uploader.rb", "lib/generators/uploader_generator.rb"]
  s.homepage = "https://github.com/carrierwaveuploader/carrierwave"
  s.licenses = ["MIT"]
  s.rdoc_options = ["--main"]
  s.rubyforge_project = "carrierwave"
  s.rubygems_version = "2.4.7"
  s.summary = "Ruby file upload library"

  if s.respond_to? :specification_version then
    s.specification_version = 3

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
      s.add_runtime_dependency(%q<activesupport>, [">= 3.2.0"])
      s.add_runtime_dependency(%q<activemodel>, [">= 3.2.0"])
      s.add_runtime_dependency(%q<json>, [">= 1.7"])
      s.add_runtime_dependency(%q<mime-types>, [">= 1.16"])
      s.add_development_dependency(%q<pg>, [">= 0"])
      s.add_development_dependency(%q<rails>, [">= 3.2.0"])
      s.add_development_dependency(%q<cucumber>, ["~> 2.0.0"])
      s.add_development_dependency(%q<rspec>, ["~> 3.2.0"])
      s.add_development_dependency(%q<sham_rack>, [">= 0"])
      s.add_development_dependency(%q<fog>, [">= 1.28.0"])
      s.add_development_dependency(%q<mini_magick>, [">= 3.6.0"])
      s.add_development_dependency(%q<rmagick>, [">= 0"])
      s.add_development_dependency(%q<ruby-filemagic>, [">= 0.6.3"])
      s.add_development_dependency(%q<nokogiri>, ["~> 1.6.3"])
      s.add_development_dependency(%q<timecop>, ["= 0.7.1"])
      s.add_development_dependency(%q<generator_spec>, [">= 0"])
      s.add_development_dependency(%q<pry>, [">= 0"])
    else
      s.add_dependency(%q<activesupport>, [">= 3.2.0"])
      s.add_dependency(%q<activemodel>, [">= 3.2.0"])
      s.add_dependency(%q<json>, [">= 1.7"])
      s.add_dependency(%q<mime-types>, [">= 1.16"])
      s.add_dependency(%q<pg>, [">= 0"])
      s.add_dependency(%q<rails>, [">= 3.2.0"])
      s.add_dependency(%q<cucumber>, ["~> 2.0.0"])
      s.add_dependency(%q<rspec>, ["~> 3.2.0"])
      s.add_dependency(%q<sham_rack>, [">= 0"])
      s.add_dependency(%q<fog>, [">= 1.28.0"])
      s.add_dependency(%q<mini_magick>, [">= 3.6.0"])
      s.add_dependency(%q<rmagick>, [">= 0"])
      s.add_dependency(%q<ruby-filemagic>, [">= 0.6.3"])
      s.add_dependency(%q<nokogiri>, ["~> 1.6.3"])
      s.add_dependency(%q<timecop>, ["= 0.7.1"])
      s.add_dependency(%q<generator_spec>, [">= 0"])
      s.add_dependency(%q<pry>, [">= 0"])
    end
  else
    s.add_dependency(%q<activesupport>, [">= 3.2.0"])
    s.add_dependency(%q<activemodel>, [">= 3.2.0"])
    s.add_dependency(%q<json>, [">= 1.7"])
    s.add_dependency(%q<mime-types>, [">= 1.16"])
    s.add_dependency(%q<pg>, [">= 0"])
    s.add_dependency(%q<rails>, [">= 3.2.0"])
    s.add_dependency(%q<cucumber>, ["~> 2.0.0"])
    s.add_dependency(%q<rspec>, ["~> 3.2.0"])
    s.add_dependency(%q<sham_rack>, [">= 0"])
    s.add_dependency(%q<fog>, [">= 1.28.0"])
    s.add_dependency(%q<mini_magick>, [">= 3.6.0"])
    s.add_dependency(%q<rmagick>, [">= 0"])
    s.add_dependency(%q<ruby-filemagic>, [">= 0.6.3"])
    s.add_dependency(%q<nokogiri>, ["~> 1.6.3"])
    s.add_dependency(%q<timecop>, ["= 0.7.1"])
    s.add_dependency(%q<generator_spec>, [">= 0"])
    s.add_dependency(%q<pry>, [">= 0"])
  end
end
