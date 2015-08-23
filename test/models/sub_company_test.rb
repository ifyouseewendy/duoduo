require 'test_helper'

class SubCompanyTest < ActiveSupport::TestCase
  def setup
    @one = sub_companies(:one)
  end

  def test_add_file
    assert_empty @one.contracts

    @one.add_file(Rails.root.join('Gemfile'))
    assert 1, @one.contracts.count

    @one.add_file(Rails.root.join('Rakefile'))
    assert 2, @one.contracts.count

    @one.add_file(Rails.root.join('config.ru'), override: true)
    assert 1, @one.contracts.count
    assert 'config.ru', @one.contracts.first.file.identifier

    @one.add_file(Rails.root.join('Gemfile'), template: true)
    assert 1, @one.contracts.count
    assert 1, @one.contract_templates.count

    @one.add_file(Rails.root.join('Rakefile'), template: true)
    assert 1, @one.contracts.count
    assert 2, @one.contract_templates.count

    @one.add_file(Rails.root.join('config.ru'), template: true, override: true)
    assert 1, @one.contracts.count
    assert 1, @one.contract_templates.count
    assert 'config.ru', @one.contract_templates.first.file.identifier
  end

  def test_generate_docx
    file_path = Rails.root.join('test').join('resources').join('origin.docx')
    @one.add_file(file_path, template: true, override: true)

    docx = @one.generate_docx(gsub: {user_name: "wendi", user_email: "wd@example.com"}, file_path: file_path)

    SubCompany::TempPath.execute do |temp_path|
      FileUtils.mv docx, temp_path

      `unzip #{docx.basename}`
      data = File.read('word/document.xml')

      assert data.index('wendi')
      assert data.index('wd@example.com')
    end
  end
end
