module HasUid
  extend ActiveSupport::Concern
  include TokenGenerator

  included do
    before_create :set_uid
  end

  class_methods do
    def find(id)
      if id.is_a? String
        find_by(uid: id)
      else
        super(id)
      end
    end
  end

  def to_param
    uid
  end

  def set_uid
    set_token(:uid) if uid.blank?
  end
end
