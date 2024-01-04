# Declare virtual attributes that are stored as keys of a backing attribute.
# This is most useful for attributes that need to be encrypted.
# All the secure attributes can be encrypted in the same database field, making
# management of the encrypted attributes easier.
# If different attributes have different access/audit requirements,
# they should be stored in different base attributes.
# A future implementation might accomplish this by accepting an options hash
# to `data_attribute` with a `store_in` attribute set to the destination field
# name, which will be assumed to be an (encrypted) JSON field).
# Future improvement might also allow you to optionally pass a serializer to
# serialize the field data with something other than `to_json`.
module DataAttributes
  extend ActiveSupport::Concern

  included do
    define_method(:decoded_data) do
      @decoded_data ||= begin
                          data.blank? ? {} : JSON.parse(data)
                        end
    end
    protected :decoded_data
    define_method(:serialize_decoded_data!) do
      if @decoded_data.present?
        self.data = @decoded_data.to_json
        @decoded_data = nil
      end
    end
    before_save :serialize_decoded_data!
  end

  module ClassMethods
    def data_attribute(*attr_names)
      @data_attributes ||= Set.new
      attr_names.each do |name|
        next if @data_attributes.member? name

        data_attribute_methods(name)
      end
      @data_attributes.merge(attr_names)
    end

    private

    def data_attribute_methods(name)
      define_method(name) do
        decoded_data[name.to_s]
      end
      setter = "#{name}=".to_sym
      define_method(setter) do |value|
        decoded_data[name.to_s] = value
      end
    end
  end
end
