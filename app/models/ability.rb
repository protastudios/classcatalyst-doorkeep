class Ability
  include CanCan::Ability

  def initialize(user)
    user ||= User.new # guest user (not logged in)

    # User registration and profile management
    can :create, User
    can :read, Translation
    can :read, GlobalSetting

    authenticated(user)
  end

  def authenticated(user)
    return unless user.persisted?

    can :manage, User, id: user.id if user.persisted?
    can :manage, Widget, user_id: user.id
    admin(user)
  end

  def admin(user)
    return unless user.admin?

    can :manage, :all
  end
end
