class ContractFilesController < ApplicationController
  def create
    cf = ContractFile.new contract_file_params
    if cf.save
      redirect_to :back, notice: "成功上传合同文件"
    else
      redirect_to :back, notice: "上传失败：#{cf.errors.full_messages.join(', ')}"
    end
  end

  private

   def contract_file_params
     params.require(:contract_file).permit!
   end
end
