ActiveAdmin.register AdminUser do
  config.filters = false
  actions :all, except: [:show, :destroy]

  menu \
    parent: I18n.t("activerecord.models.settings"),
    label: proc{ I18n.t("active_admin.admin_user.title") },
    priority: 1

  permit_params :name, :email, :password, :password_confirmation

  index do
    selectable_column
    id_column
    column :name
    column :current_sign_in_at
    column :created_at
    actions defaults: false do |obj|
      item "重置密码", reset_password_admin_user_path(obj)
    end
  end

  form do |f|
    f.inputs "个人设置" do
      f.input :name, as: :string
      f.input :password
      f.input :password_confirmation
    end
    f.actions
  end

  member_action :reset_password do
    authorize! :reset_password, current_admin_user

    begin
      new_password = SecureRandom.hex(5)
      resource.reset_password(new_password, new_password)

      # sign_in(current_admin_user, bypass: true)

      redirect_to admin_users_path, notice: "已重置用户<#{resource.name}>密码为：#{new_password}"
    rescue => e
      redirect_to admin_users_path, alert: "重置失败，请联系网络管理员（#{e.message}）"
    end

  end

end
