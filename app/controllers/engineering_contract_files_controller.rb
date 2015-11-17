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
      project = EngineeringProject.find contract_file_params[:engineering_project_id]
      template = EngineeringContractFile.template.first

      content = {
        amount: project.total_amount.to_s,
        money: RMB.new(project.total_amount.to_i).convert,
        refund_person: project.outcome_referee.to_s,
        refund_bank: project.outcome_bank.to_s,
        refund_account: project.outcome_amount.to_s,
      }
      contract =  DocGenerator.generate_docx \
        gsub: content.merge(contract_file_params),
        file_path: template.contract.path

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