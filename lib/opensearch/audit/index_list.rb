module OpenSearch
  module Audit
    class IndexList
      attr_reader :longest_index_name

      def initialize
        @hash = Hash.new { |hash, key| hash[key] = IndexGroup.new }
        @longest_index_name = 0
      end

      def add(index)
        @hash[index.group_name].add(index)
        @longest_index_name = [@longest_index_name, index.name.length].max
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
