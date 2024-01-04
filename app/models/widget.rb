class Widget < ApplicationRecord
  include AASM
  include HasUid

  belongs_to :user

  validates :name, presence: true, uniqueness: true
  validates :multiplier, presence: true, numericality: true

  aasm do
    state :in_service, initial: true
    state :broken
    state :retired

    event :break do
      transitions from: %i[in_service broken], to: :broken
    end

    event :repair do
      transitions from: :broken, to: :in_service
    end

    event :retire do
      transitions from: %i[in_service broken retired], to: :retire
    end
  end
end
