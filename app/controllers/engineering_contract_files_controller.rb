class EngineeringContractFilesController < ApplicationController
  def create
    redirect_to :back, alert: "上传失败：未找到文件" and return  if contract_file_params[:contract].nil?

    cf = EngineeringContractFile.new contract_file_params
    if cf.save
      redirect_to :back, notice: "成功上传合同文件"
    else
      redirect_to :back, notice: "上传失败：#{cf.errors.full_messages.join(', ')}"
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

      contract = sub_company.generate_docx \
        gsub: {company_name: 'wendi'},
        file_path: template.current_path

      send_file contract
    rescue => e
      logger.error e.message
    end
  end

  private

   def contract_file_params
     params.require(:engineering_contract_file).permit!
   end

   def contract_file
     EngineeringContractFile.find(params.require(:id))
   end
end
