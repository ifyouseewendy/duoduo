require 'test_helper'

class SubCompanyTest < ActiveSupport::TestCase
  def setup
    @one = sub_companies(:one)
  end

  def test_ref_with_projects
    assert_equal 2, @one.projects.count
  end

  def test_add_file
    assert_empty @one.contract_files
    assert_empty @one.contract_templates

    @one.add_file(Rails.root.join('Gemfile'))
    assert 1, @one.contract_files.count

    @one.add_file(Rails.root.join('Rakefile'))
    assert 2, @one.contract_files.count

    @one.add_file(Rails.root.join('Gemfile'), template: true)
    assert 2, @one.contract_files.count
    assert 1, @one.contract_templates.count

    @one.add_file(Rails.root.join('Rakefile'), template: true)
    assert 2, @one.contract_files.count
    assert 2, @one.contract_templates.count
  end

  def test_generate_docx
    file_path = Rails.root.join('test').join('resources').join('origin.docx')
    @one.add_file(file_path, template: true)

    docx = DocGenerator.generate_docx(
      gsub: { user_name: "wendi", user_email: "wd@example.com" },
      file_path: file_path
    )

    DocGenerator::TempPath.execute do |temp_path|
      FileUtils.mv docx, temp_path

      `unzip #{docx.basename}`
      data = File.read('word/document.xml')

      assert data.index('wendi')
      assert data.index('wd@example.com')
    end
  end
end
