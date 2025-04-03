require "opensearch/audit/index"

module OpenSearch
  module Audit
    class IndexGroup
      def initialize
        @indices = []
      end

      def add(index)
        @indices << index
      end

      def count
        @indices.count
      end

      def each(&block)
        @indices.each(&block)
      end

      def enrich(name, type, user_data)
        @indices.each do |index|
          if index.name == name
            index.enrich(type, user_data)
          end
        end
      end

      def sizes
        @indices.map(&:size)
      end

      def min
        sizes.min
      end

      def max
        sizes.max
      end

      def median
        if count.even?
          pos = count / 2
          sizes.sort[(pos - 1)..pos].sum / 2
        else
          sizes.sort.at(count / 2)
        end
      end

      def median_trend(n)
        sample = sizes.last(n)
        sample.sort.at(sample.count / 2)
      end
    end
  end
end
