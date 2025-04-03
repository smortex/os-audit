module OpenSearch
  module Audit
    module Checks
      class ShardSize < Base
        def check
          @index_list.each do |group_name, indices|
            if indices.median_shard_size < options[:min_index_size]
              logger.warn format("Indices in group %<group_name>s are too small (%<size>s < %<ref>s).  Consider reducing the number of shards by index or merging indices.",
                group_name: group_name,
                size: ActiveSupport::NumberHelper.number_to_human_size(indices.median_shard_size),
                ref: ActiveSupport::NumberHelper.number_to_human_size(options[:min_index_size]))
            elsif indices.median_shard_size > options[:max_index_size]
              logger.warn format("Indices in group %<group_name>s are too big (%<size>s > %<ref>s).  Consider adding more shards by index.",
                group_name: group_name,
                size: ActiveSupport::NumberHelper.number_to_human_size(indices.median_shard_size),
                ref: ActiveSupport::NumberHelper.number_to_human_size(options[:max_index_size]))
            end
          end
        end
      end
    end
  end
end
