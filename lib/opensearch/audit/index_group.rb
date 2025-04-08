require "opensearch/audit/index"

module OpenSearch
  module Audit
    class IndexGroup
      def initialize(indices)
        @indices = indices
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

      def primary_sizes
        @indices.map(&:primary_size)
      end

      def primary_shards
        @indices.map(&:pri)
      end

      def min_shard_size
        shard_sizes.min
      end

      def max_shard_size
        shard_sizes.max
      end

      def median_shard_size
        median(shard_sizes)
      end

      def median_primary_size
        median(primary_sizes)
      end

      def median_primary_shard_count
        median(primary_shards)
      end

      def median(values)
        if values.count.even?
          pos = values.count / 2
          values.sort[(pos - 1)..pos].sum / 2
        else
          values.sort.at(values.count / 2)
        end
      end

      def median_shard_size_trend(n)
        sample = shard_sizes.last(n)
        sample.sort.at(sample.count / 2)
      end

      def yearly?
        @indices.first.yearly?
      end

      def monthly?
        @indices.first.monthly?
      end

      def daily?
        @indices.first.daily?
      end

      def hourly?
        @indices.first.hourly?
      end
    end
  end
end
