class Role < ApplicationRecord
  belongs_to :user
  belongs_to :roleable, polymorphic: true, optional: true
  validates :user_id, presence: true

  ADMIN = 1

  TYPES = {
    ADMIN => 'Admin'
  }.freeze

  #----

  # Public: get the role type name.
  #
  def type
    TYPES[role_type_id]
  end

  def self.safe_types_list
    TYPES.reject { |x| Role::TYPES[x] == 'Admin' }.to_a.map { |k, v| [v, k] }
  end
end
