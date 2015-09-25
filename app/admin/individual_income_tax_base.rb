ActiveAdmin.register IndividualIncomeTaxBase do
  menu false
  breadcrumb do
    []
  end

  member_action :update, method: :post do
    iitb_params = params.require(:individual_income_tax_base).permit(:base)
    IndividualIncomeTaxBase.find(params[:id]).tap do |iitb|
      iitb.update!(iitb_params)
    end

    redirect_to individual_income_taxes_path, notice: "成功更新个税基数"
  end

end
