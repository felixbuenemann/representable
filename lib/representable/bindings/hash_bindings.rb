require 'representable/binding'

module Representable
  module Hash
    class PropertyBinding < Representable::Binding
      def self.build_for(definition, *args)  # TODO: remove default arg.
        return CollectionBinding.new(definition, *args)  if definition.array?
        return HashBinding.new(definition, *args)        if definition.hash?
        new(definition, *args)
      end

      def read(hash)
        return FragmentNotFound unless hash.has_key?(as) # DISCUSS: put it all in #read for performance. not really sure if i like returning that special thing.

        hash[as] # fragment
      end

      def write(hash, value)
        hash[as] = serialize(value)
      end

      def serialize_method
        :to_hash
      end

      def deserialize_method
        :from_hash
      end
    end

    class CollectionBinding < PropertyBinding
      include Binding::Collection

      def serialize(value)
        value.collect { |item| super(item) } # TODO: i don't want Array but Forms here - what now?
      end
    end


    class HashBinding < PropertyBinding
      include Binding::Hash

      def serialize(value)
        # requires value to respond to #each with two block parameters.
        {}.tap do |hsh|
          value.each { |key, obj| hsh[key] = super(obj) }
        end
      end
    end
  end
end
