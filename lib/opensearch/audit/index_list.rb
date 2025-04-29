require "opensearch/audit/index_list/array"
require "opensearch/audit/index_list/math"
require "opensearch/audit/index_list/periodicity"

module OpenSearch
  module Audit
    class IndexList
      include OpenSearch::Audit::IndexList::Array
      include OpenSearch::Audit::IndexList::Math
      include OpenSearch::Audit::IndexList::Periodicity

      attr_reader :client, :longest_index_name, :index_pattern, :options

      def initialize(client:, options:, indices: [], index_pattern: nil)
        if index_pattern.nil? && indices.empty?
          raise "Must provide indices or match"
        end

        @client = client
        @options = options
        @indices = indices
        @index_pattern = index_pattern
        @longest_index_name = 0

        if index_pattern
          client.cat.indices(index: index_pattern, format: "json", bytes: "b", s: "index").map do |index_data|
            index = OpenSearch::Audit::Index.new(index_data)
            next if options[:periodic] && !index.periodic?

            add_index(index)
          end
        end
      end

      def add_index(index)
        @indices << index
        @longest_index_name = [@longest_index_name, index.name.length].max
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

      def median_shard_size_trend(n)
        median_trend(shard_sizes, n)
      end
    end
  end
end
