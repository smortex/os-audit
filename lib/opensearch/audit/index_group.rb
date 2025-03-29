module OpenSearch
  module Audit
    class IndexGroup
      def initialize
        @sizes = []
      end

      def add(index)
        # We assume size is spread evenly across all primary shards
        @sizes << index["pri.store.size"].to_i / index["pri"].to_i
      end

      def count
        @sizes.count
      end

      def min
        @sizes.min
      end

      def max
        @sizes.max
      end

      def median
        @sizes.sort.at(count / 2)
      end

      def median_trend(n)
        sample = @sizes.last(n)
        sample.sort.at(sample.count / 2)
      end
    end
  end
end
