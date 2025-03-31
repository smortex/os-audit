module OpenSearch
  module Audit
    class IndexList
      def initialize
        @hash = Hash.new { |hash, key| hash[key] = IndexGroup.new }
      end

      def add(index)
        @hash[index.group_name].add(index)
      end

      def each(&block)
        @hash.each(&block)
      end

      def enrich(index_name, type, user_data)
        @hash[Index.group_name(index_name)].enrich(index_name, type, user_data)
      end
    end
  end
end
