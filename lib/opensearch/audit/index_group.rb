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

      def shard_sizes
        @indices.map(&:shard_size)
      end

      def min_shard_size
        shard_sizes.min
      end

      def max_shard_size
        shard_sizes.max
      end

      def median_shard_size
        if count.even?
          pos = count / 2
          shard_sizes.sort[(pos - 1)..pos].sum / 2
        else
          shard_sizes.sort.at(count / 2)
        end
      end

      def median_shard_size_trend(n)
        sample = shard_sizes.last(n)
        sample.sort.at(sample.count / 2)
      end
    end
  end
end
