class Identity < ApplicationRecord
  belongs_to :user, optional: true

  validates :provider, inclusion: %w[linkedin google facebook twitter developer]
  validates :uid, presence: true

  def self.find_or_create_from_auth_hash(auth_hash)
    provider = auth_hash['provider']
    uid = auth_hash['uid']
    return nil if provider.blank? || uid.blank?

    id = find_or_create_by!(provider: provider, uid: uid)
    id.merge!(auth_hash)
    id
  end

  def link!(user)
    if user_id.blank?
      update!(user: user)
    elsif user_id != user.id
      raise 'authentication mismatch'
    end
  end

  def register!
    return user if user.present?

    transaction do
      self.user = User.create!(info.slice('email', 'name'))
      save!
    end
  end

  def register
    register!
  rescue Error
    self.user = nil
  end

  def merge!(auth_hash)
    self.token = auth_hash.dig('credentials', 'token')
    self.info = (info || {}).deep_merge auth_hash['info'].to_h
    self.extra = (extra || {}).deep_merge auth_hash['extra'].to_h
    save!
  end
end
