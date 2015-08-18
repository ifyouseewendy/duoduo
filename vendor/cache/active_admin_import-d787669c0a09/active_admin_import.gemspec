# -*- encoding: utf-8 -*-
# stub: active_admin_import 3.0.0.pre ruby lib

Gem::Specification.new do |s|
  s.name = "active_admin_import"
  s.version = "3.0.0.pre"

  s.required_rubygems_version = Gem::Requirement.new("> 1.3.1") if s.respond_to? :required_rubygems_version=
  s.require_paths = ["lib"]
  s.authors = ["Igor Fedoronchuk"]
  s.date = "2015-08-18"
  s.description = "The most efficient way to import for Active Admin"
  s.email = ["fedoronchuk@gmail.com"]
  s.files = [".gitignore", ".hound.yml", ".travis.yml", "Gemfile", "LICENSE", "README.md", "Rakefile", "active_admin_import.gemspec", "app/views/admin/import.html.erb", "config/locales/en.yml", "config/locales/es.yml", "config/locales/it.yml", "config/locales/zh-CN.yml", "lib/active_admin_import.rb", "lib/active_admin_import/authorization.rb", "lib/active_admin_import/dsl.rb", "lib/active_admin_import/engine.rb", "lib/active_admin_import/import_result.rb", "lib/active_admin_import/importer.rb", "lib/active_admin_import/model.rb", "lib/active_admin_import/options.rb", "lib/active_admin_import/version.rb", "spec/fixtures/files/author.csv", "spec/fixtures/files/author_broken_header.csv", "spec/fixtures/files/author_invalid.csv", "spec/fixtures/files/authors.csv", "spec/fixtures/files/authors_bom.csv", "spec/fixtures/files/authors_invalid_db.csv", "spec/fixtures/files/authors_no_headers.csv", "spec/fixtures/files/authors_win1251_win_endline.csv", "spec/fixtures/files/authors_with_ids.csv", "spec/fixtures/files/authors_with_semicolons.csv", "spec/fixtures/files/empty.csv", "spec/fixtures/files/only_headers.csv", "spec/fixtures/files/posts.csv", "spec/fixtures/files/posts_for_author.csv", "spec/fixtures/files/posts_for_author_no_headers.csv", "spec/import_spec.rb", "spec/model_spec.rb", "spec/spec_helper.rb", "spec/support/active_model_lint.rb", "spec/support/admin.rb", "spec/support/rails_template.rb", "tasks/test.rake"]
  s.homepage = "http://github.com/Fivell/active_admin_import"
  s.licenses = ["MIT"]
  s.rubygems_version = "2.4.7"
  s.summary = "ActiveAdmin import based on activerecord-import gem."
  s.test_files = ["spec/fixtures/files/author.csv", "spec/fixtures/files/author_broken_header.csv", "spec/fixtures/files/author_invalid.csv", "spec/fixtures/files/authors.csv", "spec/fixtures/files/authors_bom.csv", "spec/fixtures/files/authors_invalid_db.csv", "spec/fixtures/files/authors_no_headers.csv", "spec/fixtures/files/authors_win1251_win_endline.csv", "spec/fixtures/files/authors_with_ids.csv", "spec/fixtures/files/authors_with_semicolons.csv", "spec/fixtures/files/empty.csv", "spec/fixtures/files/only_headers.csv", "spec/fixtures/files/posts.csv", "spec/fixtures/files/posts_for_author.csv", "spec/fixtures/files/posts_for_author_no_headers.csv", "spec/import_spec.rb", "spec/model_spec.rb", "spec/spec_helper.rb", "spec/support/active_model_lint.rb", "spec/support/admin.rb", "spec/support/rails_template.rb"]

  if s.respond_to? :specification_version then
    s.specification_version = 4

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
      s.add_runtime_dependency(%q<activerecord-import>, ["~> 0.8.0"])
      s.add_runtime_dependency(%q<rchardet>, ["~> 1.5"])
      s.add_runtime_dependency(%q<rubyzip>, [">= 1.0.0", "~> 1.0"])
      s.add_runtime_dependency(%q<rails>, [">= 4.0"])
    else
      s.add_dependency(%q<activerecord-import>, ["~> 0.8.0"])
      s.add_dependency(%q<rchardet>, ["~> 1.5"])
      s.add_dependency(%q<rubyzip>, [">= 1.0.0", "~> 1.0"])
      s.add_dependency(%q<rails>, [">= 4.0"])
    end
  else
    s.add_dependency(%q<activerecord-import>, ["~> 0.8.0"])
    s.add_dependency(%q<rchardet>, ["~> 1.5"])
    s.add_dependency(%q<rubyzip>, [">= 1.0.0", "~> 1.0"])
    s.add_dependency(%q<rails>, [">= 4.0"])
  end
end
