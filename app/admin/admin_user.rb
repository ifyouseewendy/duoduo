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
    column :status do |obj|
      status_tag obj.status_i18n, (obj.active? ? :yes : :no)
    end
    column :current_sign_in_at
    column :created_at
    actions defaults: false do |obj|
      item "重置密码", reset_password_admin_user_path(obj)
      text_node "&nbsp;&nbsp;".html_safe
      item "锁定", lock_admin_user_path(obj)
      text_node "&nbsp;&nbsp;".html_safe
      item "解锁", unlock_admin_user_path(obj)
    end
  end

  form do |f|
    f.inputs do
      f.input :name, as: :string
    end
    f.actions
  end

  member_action :reset_password do
    authorize! :reset_password, current_admin_user

    begin
      new_password = SecureRandom.hex(5)
      resource.reset_password(new_password, new_password)

      # sign_in(current_admin_user, bypass: true)

      redirect_to admin_users_path, notice: "已重置用户<#{resource.name}>密码为：#{new_password}，用户登录后可自行修改密码"
    rescue => e
      redirect_to admin_users_path, alert: "重置失败，请联系网络管理员（#{e.message}）"
    end

  end

  collection_action :create, method: :post do
    name = params[:admin_user][:name].strip

    redirect_to :back, alert: "操作失败，用户名为空" and return if name.blank?
    redirect_to :back, alert: "操作失败，用户名已存在" and return if AdminUser.where(name: name).first.present?

    begin
      new_password = SecureRandom.hex(5)
      AdminUser.create!(
        name: name,
        email: "#{name}@jiyi.com",
        password: new_password,
        password_confirmation: new_password
      )

      redirect_to admin_users_path, notice: "已创建用户：#{name}，初始密码为：#{new_password}，用户登录后可自行修改密码"
    rescue => e
      redirect_to :back, alert: "操作失败，请联系网络管理员（#{e.message}）"
    end

  end

  member_action :lock do
    authorize! :reset_password, current_admin_user

    begin
      resource.locked!

      redirect_to admin_users_path, notice: "已锁定用户<#{resource.name}>"
    rescue => e
      redirect_to admin_users_path, alert: "操作失败，请联系网络管理员（#{e.message}）"
    end

  end

  member_action :unlock do
    authorize! :reset_password, current_admin_user

    begin
      resource.active!

      redirect_to admin_users_path, notice: "已解锁用户<#{resource.name}>"
    rescue => e
      redirect_to admin_users_path, alert: "操作失败，请联系网络管理员（#{e.message}）"
    end

  end
end
