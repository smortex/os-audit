module OpenSearch
  module Audit
    module Checks
      class Conflicts < Base
        def check
          @index_list.each do |group_name, group_indices|
            merged_mapping = {}
            group_indices.each do |index|
              merged_mapping.deep_merge!(index.mapping)
            end

            group_indices.each do |index|
              new_merge = merged_mapping.deep_merge(index.mapping)
              if new_merge != merged_mapping
                logger.warn "Conflicts detected for #{group_name}"
                break
              end
            end
          end
        end
      end
    end
  end
end
