class ContractTemplatesController < ApplicationController
  def create
    ct = ContractTemplate.new contract_template_params
    if ct.save
      redirect_to :back, notice: "成功上传合同文件"
    else
      redirect_to :back, notice: "上传失败：#{ct.errors.full_messages.join(', ')}"
    end
  end

  def destroy
    contract_template.delete
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

   def contract_template_params
     params.require(:contract_template).permit!
   end

   def contract_template
     ContractTemplate.find(params.require(:id))
   end
end
