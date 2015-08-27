class SubCompany < ActiveRecord::Base
  has_and_belongs_to_many :normal_corporations
  has_and_belongs_to_many :engineering_corporations

  has_many :contract_files

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

    TempPath.execute do |temp_path|
      # Copy to temp path
      FileUtils.cp file_path, temp_path
      file = temp_path.join( Pathname.new(file_path).basename )

      # Extract word/documents
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
    end
  end

  class TempPath
    class << self
      def execute
        temp_path = generate_temp_path

        Dir.chdir(temp_path)
        puts "--> Change dir to temp path: #{temp_path}"

        yield temp_path
      ensure
        Dir.chdir(Rails.root)
        puts "--> Change back to: #{Rails.root}"

        temp_path.rmtree
      end

      def generate_temp_path
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
