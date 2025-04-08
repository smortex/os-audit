module OpenSearch
  module Audit
    class IndexList
      attr_reader :longest_index_name

      def initialize
        @indices = []
        @longest_index_name = 0
      end

      def add(index)
        @indices << index
        @longest_index_name = [@longest_index_name, index.name.length].max
      end

      def each(&block)
        @indices.each(&block)
      end

      def enrich(index_name, type, user_data)
        find_by(name: index_name).enrich(type, user_data)
      end

      def base_names
        @indices.select { |index| index.periodic? }.map(&:base_name).uniq
      end

      def group_names
        @indices.select { |index| index.periodic? }.map(&:group_name).uniq
      end

      def where(filters)
        @indices.select do |index|
          filters.all? do |k, v|
            index.send(k) == v
          end
        end
      end

      def find_by(filters)
        where(filters).first
      end
    end
  end
end
