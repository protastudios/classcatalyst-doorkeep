# Constraint class to restrict access to sidekiq dashboard
class CanAccessSidekiq
  def matches?(request)
    user = User.find_by(id: request.session[:user_id]) if request.session[:user_id].present?
    return false if user.blank?

    Ability.new(user).can? :manage, Sidekiq
  end
end
