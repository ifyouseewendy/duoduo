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
      project = EngineeringProject.find params[:engineering_project_id]
      sub_company = SubCompany.find params[:sub_company_id]

      project.generate_contract_file(
        role: params[:role],
        sub_company: sub_company,
        content: params.select{|k,_| %i(corp_name name start_date end_date range need_count salary admin_rate).include?(k.to_sym) }
      )

      redirect_to :back, notice: "成功生成合同文件"
    rescue => e
      redirect_to :back, alert: e.message
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
