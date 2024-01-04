module TokenGenerator
  extend ActiveSupport::Concern

  def set_token(column, size = 12)
    loop do
      self[column] = get_token(size)
      break unless self.class.exists?(column => self[column])
    end
  end

  def get_token(size = 12)
    SecureRandom.urlsafe_base64(size)
  end
end
