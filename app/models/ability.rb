class Ability
  include CanCan::Ability

  def initialize(user)
    can :manage, Project
    can :read, Project
    can :read, ActiveAdmin::Page, name: "Dashboard", namespace_name: :admin
  end
end
