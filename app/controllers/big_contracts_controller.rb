class BigContractsController < ApplicationController

  def create
    redirect_to :back, alert: "上传失败：未找到文件" and return  if contract_file_params[:contract].nil?

    begin
      contract = contract_file_params[:contract]

      bc = BigContract.new contract_file_params

      path = Pathname(contract.path)
      ext = contract.original_filename.split('.')[-1]
      to = path.dirname.join("#{bc}.#{ext}")
      path.rename(to)

      bc.contract = File.open(to)
      bc.save!

      redirect_to :back, notice: "成功上传合同文件"
    rescue => e
      redirect_to :back, notice: "上传失败：#{e.message}"
    end
  end

  def destroy
    contract_file.delete
    redirect_to :back, notice: "成功删除合同文件"
  end

  def activate
    contract_file.activate!
    redirect_to :back, notice: "成功激活合同文件"
  end

  def deactivate
    contract_file.deactivate!
    redirect_to :back, notice: "成功激活合同文件"
  end

  private

   def contract_file_params
     params.permit(:engineering_corp_id, :sub_company_id, :start_date, :end_date, :contract)
   end

   def contract_file
     BigContract.find(params.require(:id))
   end
end
