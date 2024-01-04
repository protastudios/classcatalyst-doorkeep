class User < ApplicationRecord
  include HasUid
  include VerifiedEmail
  include PasswordReset

  has_one_attached :avatar

  with_options dependent: :destroy do
    has_many :identities
    has_many :roles
    has_many :widgets # DEMO
  end

  before_validation :secure_password_digest

  has_secure_password
  HUMANIZED_ATTRIBUTES = { password_digest: 'Password' }.freeze

  validate :avatar_must_be_image

  validates :password_digest, presence: true, unless: proc { |u| u.new_record? }
  validates :password, length: { minimum: 6 }, allow_nil: true, unless: proc { |u| u.new_record? }

  validates :first_name, presence: true
  validates :last_name, presence: true

  def name
    "#{first_name} #{last_name}"
  end

  def name=(new_name)
    components = new_name.split(' ')
    self.first_name = components.shift
    self.last_name = components.join(' ').presence || last_name || '(unknown)'
  end

  def admin?
    if id.present?
      if roles.exists?(role_type_id: Role::ADMIN)
        true
      else
        false
      end
    else
      false
    end
  end

  def avatar_url
    if avatar.attached?
      Rails.application.routes.url_helpers.rails_blob_path(user.avatar.variant(resize: '100x100'), only_path: true)
    else
      ActionController::Base.helpers.asset_path('profile-image-default.png')
    end
  end

  private

  def secure_password_digest
    return if password_digest.present?

    self.password = SecureRandom.urlsafe_base64(16)
  end

  def avatar_must_be_image
    errors.add(:avatar, 'Must be an image file') if avatar.attached? && !avatar.attachment.blob.content_type.in?(%w[image/png image/jpeg image/gif])
  end
end
