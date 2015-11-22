ActiveAdmin.register AuditionItem do
  menu \
    parent: I18n.t("activerecord.models.engineering_business"),
    priority: 6,
    if: -> {current_admin_user.finance_admin?}

  actions :all, except: [:show, :new, :create, :edit, :update, :destroy]

  config.batch_actions = false
  config.clear_action_items!
  config.filters = false

  index do
    selectable_column
    column :id
    column :auditable_type do |obj|
      obj.auditable.model_name.human
    end
    column :name do |obj|
      ref = obj.auditable
      name = ref.try(:name) || '#'
      link_to name, send("#{ref.class.name.underscore}_path", ref)
    end
    column :status do |obj|
      obj.status_i18n
    end
    column :created_at
    column :updated_at

    actions defaults: false
  end

  collection_action :apply do
    begin
      ai = AuditionItem.find_or_create_by!(
        auditable_id: params[:auditable_id],
        auditable_type: fix_engineering_salary_table(type: params[:auditable_type])
      )

      ai.update_attribute(:status, :apply_audit)
      redirect_to :back, notice: "已申请复核"
    rescue => e
      redirect_to :back, alert: "操作失败，请把这段信息存入问题反馈：#{Time.now} - #{e.message}"
    end
  end

  collection_action :ensure do
    begin
      ai = AuditionItem.find_or_create_by!(
        auditable_id: params[:auditable_id],
        auditable_type: fix_engineering_salary_table(type: params[:auditable_type])
      )

      ai.update_attribute(:status, :already_audit)
      redirect_to :back, notice: "已复核"
    rescue => e
      redirect_to :back, alert: "操作失败，请把这段信息存入问题反馈：#{Time.now} - #{e.message}"
    end
  end

  collection_action :release do
    begin
      ai = AuditionItem.find_or_create_by!(
        auditable_id: params[:auditable_id],
        auditable_type: fix_engineering_salary_table(type: params[:auditable_type])
      )

      ai.update_attribute(:status, :init)
      redirect_to :back, notice: "已复核"
    rescue => e
      redirect_to :back, alert: "操作失败，请把这段信息存入问题反馈：#{Time.now} - #{e.message}"
    end
  end

  controller do
    private

      def fix_engineering_salary_table(type:)
        EngineeringSalaryTable.types.map(&:to_s).include?(type.strip) ? 'EngineeringSalaryTable' : type
      end
  end
end
