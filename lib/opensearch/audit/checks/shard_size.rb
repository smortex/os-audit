module OpenSearch
  module Audit
    module Checks
      class ShardSize < Base
        def check
          @index_list.each do |group_name, indices|
            if indices.median < options[:min_index_size]
              warn format("Indices %<index>s are too small (%<size>s < %<ref>s).  Consider reducing the number of shards by index or merging indices.",
                index: group_name,
                size: ActiveSupport::NumberHelper.number_to_human_size(indices.median),
                ref: ActiveSupport::NumberHelper.number_to_human_size(options[:min_index_size]))
            elsif indices.median > options[:max_index_size]
              warn format("Indices %<index>s are too big (%<size>s > %<ref>s).  Consider adding more shards by index.",
                index: group_name,
                size: ActiveSupport::NumberHelper.number_to_human_size(indices.median),
                ref: ActiveSupport::NumberHelper.number_to_human_size(options[:max_index_size]))
            end
          end
        end
      end
    end
  end
end
