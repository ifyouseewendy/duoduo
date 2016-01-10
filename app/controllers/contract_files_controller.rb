class ContractFilesController < ApplicationController
  def create
    cf = ContractFile.new contract_file_params
    if cf.save
      redirect_to :back, notice: "成功上传合同文件"
    else
      if cf.errors.keys.include?(:contract)
        msg = "请选择上传文件"
      else
        msg = "#{cf.errors.full_messages.join(', ')}"
      end
      redirect_to :back, alert: "上传失败：#{msg}"
    end
  end

  def destroy
    contract_file.delete
    redirect_to :back, notice: "成功删除合同文件"
  end

  def generate_and_download
    begin
      sub_company = SubCompany.find params.require(:sub_company_id)
      template = sub_company.contract_templates[params.require(:template).to_i]

      contract = DocGenerator.generate_docx \
        gsub: {company_name: 'wendi'},
        file_path: template.current_path

      send_file contract
    rescue => e
      logger.error e.message
    end
  end

  private

   def contract_file_params
     params.require(:contract_file).permit!
   end

   def contract_file
     ContractFile.find(params.require(:id))
   end
end
