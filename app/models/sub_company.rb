class SubCompany < ActiveRecord::Base
  has_and_belongs_to_many :normal_corporations
  has_and_belongs_to_many :engineering_corporations

  mount_uploaders :contracts, ContractUploader
  mount_uploaders :contract_templates, ContractTemplateUploader

  def add_file(filename, override: false, template: false)
    field = template ? :contract_templates : :contracts
    if override
      self.send "#{field}=", [File.open(filename)]
    else
      self.send "#{field}=", self.contracts + [File.open(filename)]
    end

    self.save!
  end

  def generate_docx(gsub:, file_path:)
    # Check existance
    raise "File not exist" unless File.exist?(file_path)

    # Make temp dir
    temp_path = TempPath.generate
    puts "--> Generate temp path: #{temp_path}"

    # Make a copy
    FileUtils.cp file_path, temp_path
    file = Pathname.new(temp_path).join( Pathname.new(file_path).basename )

    # Extract word/documents
    Dir.chdir(temp_path)
    `unzip #{file.basename}`

    # Read content
    data = File.read("word/document.xml")

    # Substitution
    gsub.each {|k, v| data.gsub!(k.to_s, v) }

    # Write content
    File.open("word/document.xml", 'w'){|wf| wf.write data}

    # Zip the docx
    `zip #{file.basename} word/document.xml`

    # Move to tmp/docx
    FileUtils.cp file, TempPath.base

    # Return file
    Pathname.new(TempPath.base.join(file.basename))
  ensure
    Dir.chdir(Rails.root)
    temp_path.rmtree
  end

  class TempPath
    class << self
      def generate
        dir ||= base.join(SecureRandom.hex(10))
        dir.mkdir unless dir.exist?
        dir
      end

      def base
        @_base ||= Rails.root.join("tmp").join("docx")
      end
    end
  end
end
