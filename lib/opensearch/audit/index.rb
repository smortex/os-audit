module OpenSearch
  module Audit
    class Index
      attr_reader :name, :size

      def initialize(index)
        @name = index["index"]

        # We assume size is spread evenly across all primary shards
        @size = index["pri.store.size"].to_i / index["pri"].to_i

        @user_data = {}
      end

      def enrich(type, user_data)
        @user_data[type] = user_data
      end

      def respond_to_missing?(name, include_private = false)
        @user_data.has_key?(name)
      end

      def self.group_name(name)
        name.gsub(/\d{4}\.\d{2}\.\d{2}$/, "YYYY.MM.dd")
          .gsub(/\d{4}\.\d{2}$/, "YYYY.MM")
          .gsub(/\d{4}$/, "YYYY")
      end

      def group_name
        self.class.group_name(name)
      end

      def periodic?
        group_name != name
      end

      private def method_missing(name, *args)
        if @user_data.has_key?(name)
          return @user_data[name]
        end
        super
      end
    end
  end
end
