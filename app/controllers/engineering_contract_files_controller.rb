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

      valid_keys = \
        case params[:role].to_sym
        when :normal
          %i(corp_name corp_address name start_date end_date range need_count admin_rate)
        when :proxy
          %i(corp_name amount bank account address persons)
        end

      project.generate_contract_file(
        role: params[:role],
        outcome_item_id: params[:outcome_item_id],
        content: params.select{|k,_| valid_keys.include?(k.to_sym) },
      )

      redirect_to :back, notice: "成功生成文件"
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
