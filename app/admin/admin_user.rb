ActiveAdmin.register AdminUser do
  config.filters = false
  actions :all, except: [:show]

  menu \
    parent: I18n.t("activerecord.models.settings"),
    label: I18n.t("active_admin.admin_user.title"),
    if: ->{ current_active_admin_user.admin? },
    priority: 1

  permit_params :name, :email, :password, :password_confirmation, :role

  index do
    selectable_column
    id_column
    column :name
    column :status do |obj|
      status_tag obj.status_i18n, (obj.active? ? :yes : :no)
    end
    column :role do |obj|
      obj.role_i18n
    end
    column :current_sign_in_at
    column :created_at
    actions defaults: false do |obj|
      if obj.id != current_admin_user.id
        item "更改角色", edit_admin_user_path(obj)
        text_node "&nbsp;|&nbsp;&nbsp;".html_safe
      end
      item "重置密码", reset_password_admin_user_path(obj)
      text_node "&nbsp;|&nbsp;&nbsp;".html_safe
      item "锁定", lock_admin_user_path(obj)
      text_node "&nbsp;&nbsp;".html_safe
      item "解锁", unlock_admin_user_path(obj)
      text_node "&nbsp;|&nbsp;&nbsp;".html_safe
      item "删除", '#', class: 'admin_user_delete'
    end
  end

  sidebar '说明', only: [:index] do
    span "该页面只有超级管理员有权限访问并操作"
  end

  sidebar '锁定与删除', only: [:index] do
    ul do
      li "锁定员工 - 员工不可再访问系统，但是会保留操作痕迹。建议有员工离职时使用。"
      li "删除员工 - 擦除该员工在系统内所有痕迹，请谨慎操作。建议对还未使用系统的员工使用。"
    end
  end

  form do |f|
    f.inputs do
      f.input :name, as: :string

      if current_admin_user.admin? && current_admin_user.id != f.object.id
        # Update others
        # unless f.object.new_record?
        f.input :role, as: :radio, collection: ->{ AdminUser.roles_option(user: current_admin_user) }.call
      else
        # Update self
        f.input :password
        f.input :password_confirmation
      end
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

  # Ajax delete
  collection_action :destroy, method: :delete do
    begin
      AdminUser.find(params[:id]).destroy

      render json: {status: 'succeed', url: admin_users_path}
    rescue => e
      render json: {status: 'failed', message: e.message}
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
