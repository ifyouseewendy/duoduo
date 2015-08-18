# -*- encoding: utf-8 -*-
# stub: rails-i18n 4.0.4 ruby lib

Gem::Specification.new do |s|
  s.name = "rails-i18n"
  s.version = "4.0.4"

  s.required_rubygems_version = Gem::Requirement.new(">= 1.3.5") if s.respond_to? :required_rubygems_version=
  s.require_paths = ["lib"]
  s.authors = ["Rails I18n Group"]
  s.date = "2015-08-18"
  s.description = "A set of common locale data and translations to internationalize and/or localize your Rails applications."
  s.email = "rails-i18n@googlegroups.com"
  s.files = ["CHANGELOG.md", "MIT-LICENSE.txt", "README.md", "lib/rails-i18n.rb", "lib/rails_i18n", "lib/rails_i18n.rb", "lib/rails_i18n/common_pluralizations", "lib/rails_i18n/common_pluralizations/east_slavic.rb", "lib/rails_i18n/common_pluralizations/one_other.rb", "lib/rails_i18n/common_pluralizations/one_two_other.rb", "lib/rails_i18n/common_pluralizations/one_upto_two_other.rb", "lib/rails_i18n/common_pluralizations/one_with_zero_other.rb", "lib/rails_i18n/common_pluralizations/other.rb", "lib/rails_i18n/common_pluralizations/romanian.rb", "lib/rails_i18n/common_pluralizations/west_slavic.rb", "lib/rails_i18n/railtie.rb", "lib/rails_i18n/unicode.rb", "rails/locale/af.yml", "rails/locale/ar.yml", "rails/locale/az.yml", "rails/locale/be.yml", "rails/locale/bg.yml", "rails/locale/bn.yml", "rails/locale/bs.yml", "rails/locale/ca.yml", "rails/locale/cs.yml", "rails/locale/cy.yml", "rails/locale/da.yml", "rails/locale/de-AT.yml", "rails/locale/de-CH.yml", "rails/locale/de.yml", "rails/locale/el.yml", "rails/locale/en-AU.yml", "rails/locale/en-CA.yml", "rails/locale/en-GB.yml", "rails/locale/en-IE.yml", "rails/locale/en-IN.yml", "rails/locale/en-NZ.yml", "rails/locale/en-US.yml", "rails/locale/en-ZA.yml", "rails/locale/en.yml", "rails/locale/eo.yml", "rails/locale/es-419.yml", "rails/locale/es-AR.yml", "rails/locale/es-CL.yml", "rails/locale/es-CO.yml", "rails/locale/es-CR.yml", "rails/locale/es-EC.yml", "rails/locale/es-MX.yml", "rails/locale/es-PA.yml", "rails/locale/es-PE.yml", "rails/locale/es-US.yml", "rails/locale/es-VE.yml", "rails/locale/es.yml", "rails/locale/et.yml", "rails/locale/eu.yml", "rails/locale/fa.yml", "rails/locale/fi.yml", "rails/locale/fr-CA.yml", "rails/locale/fr-CH.yml", "rails/locale/fr.yml", "rails/locale/gl.yml", "rails/locale/he.yml", "rails/locale/hi-IN.yml", "rails/locale/hi.yml", "rails/locale/hr.yml", "rails/locale/hu.yml", "rails/locale/id.yml", "rails/locale/is.yml", "rails/locale/iso-639-2", "rails/locale/it-CH.yml", "rails/locale/it.yml", "rails/locale/ja.yml", "rails/locale/km.yml", "rails/locale/kn.yml", "rails/locale/ko.yml", "rails/locale/lb.yml", "rails/locale/lo.yml", "rails/locale/lt.yml", "rails/locale/lv.yml", "rails/locale/mk.yml", "rails/locale/mn.yml", "rails/locale/mr-IN.yml", "rails/locale/ms.yml", "rails/locale/nb.yml", "rails/locale/ne.yml", "rails/locale/nl.yml", "rails/locale/nn.yml", "rails/locale/or.yml", "rails/locale/pl.yml", "rails/locale/pt-BR.yml", "rails/locale/pt.yml", "rails/locale/rm.yml", "rails/locale/ro.yml", "rails/locale/ru.yml", "rails/locale/sk.yml", "rails/locale/sl.yml", "rails/locale/sr.yml", "rails/locale/sv.yml", "rails/locale/sw.yml", "rails/locale/ta.yml", "rails/locale/th.yml", "rails/locale/tl.yml", "rails/locale/tr.yml", "rails/locale/tt.yml", "rails/locale/ug.yml", "rails/locale/uk.yml", "rails/locale/ur.yml", "rails/locale/uz.yml", "rails/locale/vi.yml", "rails/locale/wo.yml", "rails/locale/zh-CN.yml", "rails/locale/zh-HK.yml", "rails/locale/zh-TW.yml", "rails/locale/zh-YUE.yml", "rails/pluralization/ak.rb", "rails/pluralization/am.rb", "rails/pluralization/ar.rb", "rails/pluralization/az.rb", "rails/pluralization/be.rb", "rails/pluralization/bg.rb", "rails/pluralization/bh.rb", "rails/pluralization/bm.rb", "rails/pluralization/bn.rb", "rails/pluralization/bo.rb", "rails/pluralization/br.rb", "rails/pluralization/bs.rb", "rails/pluralization/by.rb", "rails/pluralization/ca.rb", "rails/pluralization/cs.rb", "rails/pluralization/cy.rb", "rails/pluralization/da.rb", "rails/pluralization/de-AT.rb", "rails/pluralization/de-CH.rb", "rails/pluralization/de.rb", "rails/pluralization/dz.rb", "rails/pluralization/el.rb", "rails/pluralization/en-AU.rb", "rails/pluralization/en-CA.rb", "rails/pluralization/en-GB.rb", "rails/pluralization/en-IN.rb", "rails/pluralization/en-NZ.rb", "rails/pluralization/en.rb", "rails/pluralization/eo.rb", "rails/pluralization/es-419.rb", "rails/pluralization/es-AR.rb", "rails/pluralization/es-CL.rb", "rails/pluralization/es-CO.rb", "rails/pluralization/es-EC.rb", "rails/pluralization/es-MX.rb", "rails/pluralization/es-PE.rb", "rails/pluralization/es-VE.rb", "rails/pluralization/es.rb", "rails/pluralization/et.rb", "rails/pluralization/eu.rb", "rails/pluralization/fa.rb", "rails/pluralization/ff.rb", "rails/pluralization/fi.rb", "rails/pluralization/fil.rb", "rails/pluralization/fr-CA.rb", "rails/pluralization/fr-CH.rb", "rails/pluralization/fr.rb", "rails/pluralization/ga.rb", "rails/pluralization/gd.rb", "rails/pluralization/gl.rb", "rails/pluralization/guw.rb", "rails/pluralization/gv.rb", "rails/pluralization/he.rb", "rails/pluralization/hi-IN.rb", "rails/pluralization/hi.rb", "rails/pluralization/hr.rb", "rails/pluralization/hsb.rb", "rails/pluralization/hu.rb", "rails/pluralization/id.rb", "rails/pluralization/ig.rb", "rails/pluralization/ii.rb", "rails/pluralization/is.rb", "rails/pluralization/it-CH.rb", "rails/pluralization/it.rb", "rails/pluralization/iu.rb", "rails/pluralization/ja.rb", "rails/pluralization/jv.rb", "rails/pluralization/ka.rb", "rails/pluralization/kab.rb", "rails/pluralization/kde.rb", "rails/pluralization/kea.rb", "rails/pluralization/km.rb", "rails/pluralization/kn.rb", "rails/pluralization/ko.rb", "rails/pluralization/ksh.rb", "rails/pluralization/kw.rb", "rails/pluralization/lag.rb", "rails/pluralization/ln.rb", "rails/pluralization/lo.rb", "rails/pluralization/lt.rb", "rails/pluralization/lv.rb", "rails/pluralization/mg.rb", "rails/pluralization/mk.rb", "rails/pluralization/mn.rb", "rails/pluralization/mo.rb", "rails/pluralization/mr-IN.rb", "rails/pluralization/ms.rb", "rails/pluralization/mt.rb", "rails/pluralization/my.rb", "rails/pluralization/naq.rb", "rails/pluralization/nb.rb", "rails/pluralization/ne.rb", "rails/pluralization/nl.rb", "rails/pluralization/nn.rb", "rails/pluralization/nso.rb", "rails/pluralization/or.rb", "rails/pluralization/pl.rb", "rails/pluralization/ro.rb", "rails/pluralization/root.rb", "rails/pluralization/ru.rb", "rails/pluralization/sah.rb", "rails/pluralization/se.rb", "rails/pluralization/ses.rb", "rails/pluralization/sg.rb", "rails/pluralization/sh.rb", "rails/pluralization/shi.rb", "rails/pluralization/sk.rb", "rails/pluralization/sl.rb", "rails/pluralization/sma.rb", "rails/pluralization/smi.rb", "rails/pluralization/smj.rb", "rails/pluralization/smn.rb", "rails/pluralization/sms.rb", "rails/pluralization/sr.rb", "rails/pluralization/sv.rb", "rails/pluralization/sw.rb", "rails/pluralization/th.rb", "rails/pluralization/ti.rb", "rails/pluralization/tl.rb", "rails/pluralization/to.rb", "rails/pluralization/tr.rb", "rails/pluralization/tzm.rb", "rails/pluralization/uk.rb", "rails/pluralization/ur.rb", "rails/pluralization/vi.rb", "rails/pluralization/wa.rb", "rails/pluralization/wo.rb", "rails/pluralization/yo.rb", "rails/pluralization/zh-CN.rb", "rails/pluralization/zh-HK.rb", "rails/pluralization/zh-TW.rb", "rails/pluralization/zh-YUE.rb", "rails/pluralization/zh.rb", "rails/transliteration/bg.yml", "rails/transliteration/de.yml", "rails/transliteration/fr.yml", "rails/transliteration/hu.yml", "rails/transliteration/pl.yml", "rails/transliteration/ro.yml", "rails/transliteration/ru.rb", "rails/transliteration/uk.rb", "rails/transliteration/vi.yml"]
  s.homepage = "http://github.com/svenfuchs/rails-i18n"
  s.licenses = ["MIT"]
  s.rubyforge_project = "[none]"
  s.rubygems_version = "2.4.7"
  s.summary = "Common locale data and translations for Rails i18n."

  if s.respond_to? :specification_version then
    s.specification_version = 4

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
      s.add_runtime_dependency(%q<i18n>, ["~> 0.6"])
      s.add_runtime_dependency(%q<railties>, ["~> 4.0"])
      s.add_development_dependency(%q<rspec-rails>, ["= 2.14.2"])
      s.add_development_dependency(%q<i18n-spec>, ["= 0.4.0"])
      s.add_development_dependency(%q<spork>, ["= 1.0.0rc3"])
      s.add_development_dependency(%q<i18n-tasks>, ["~> 0.3.6"])
    else
      s.add_dependency(%q<i18n>, ["~> 0.6"])
      s.add_dependency(%q<railties>, ["~> 4.0"])
      s.add_dependency(%q<rspec-rails>, ["= 2.14.2"])
      s.add_dependency(%q<i18n-spec>, ["= 0.4.0"])
      s.add_dependency(%q<spork>, ["= 1.0.0rc3"])
      s.add_dependency(%q<i18n-tasks>, ["~> 0.3.6"])
    end
  else
    s.add_dependency(%q<i18n>, ["~> 0.6"])
    s.add_dependency(%q<railties>, ["~> 4.0"])
    s.add_dependency(%q<rspec-rails>, ["= 2.14.2"])
    s.add_dependency(%q<i18n-spec>, ["= 0.4.0"])
    s.add_dependency(%q<spork>, ["= 1.0.0rc3"])
    s.add_dependency(%q<i18n-tasks>, ["~> 0.3.6"])
  end
end
