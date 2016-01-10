require 'test_helper'

class SubCompanyTest < ActiveSupport::TestCase
  def setup
    @one = sub_companies(:one)
  end

  def test_ref_with_projects
    assert_equal 2, @one.projects.count
  end

  def test_ref_with_corporations
    assert_equal [engineering_corps(:one).id], @one.corporations.pluck(:id)
  end

  def test_ref_with_customers
    assert_equal [engineering_customers(:one).id], @one.customers.pluck(:id)
  end

  def test_ref_with_big_contracts
    assert_equal 2, @one.big_contracts.count
  end

  def test_generate_docx
    file_path = Rails.root.join('test').join('resources').join('origin.docx')

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
