require 'i18n/backend/active_record'

begin
  if ActiveRecord::Base.connection.table_exists? 'translations'
    I18n.backend = I18n::Backend::ActiveRecord.new

    I18n::Backend::ActiveRecord.include I18n::Backend::Memoize
    I18n::Backend::Simple.include I18n::Backend::Memoize
    I18n::Backend::Simple.include I18n::Backend::Pluralization

    I18n.backend = I18n::Backend::Chain.new(I18n::Backend::Simple.new, I18n.backend)
  end
rescue ActiveRecord::NoDatabaseError
  # Edge-case when first initializing the app
  Rails.logger.warn 'Not using AR backend for i18n because DB does not yet exist!'
end
