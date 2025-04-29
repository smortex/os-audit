OpenSearch::Audit.add_check(:conflicts) do
  def check
    @index_list.base_names.each do |base_name|
      group_indices = @index_list.where(base_name: base_name)

      common_mapping = {}
      group_indices.each do |index|
        common_mapping.deep_merge!(index.mapping)
      end

      group_indices.each do |index|
        index_mapping = common_mapping.deep_merge(index.mapping)
        offenses = diff(common_mapping, index_mapping)
        if offenses.any?
          logger.warn "#{offenses.count} conflicts detected in group #{base_name} for index #{index.name}"
          offenses.each { |conflict| logger.info "\t#{conflict}" }
        end
      end
    end
  end

  def diff(left, right, path: [])
    result = []

    if left != right
      if left.is_a?(Hash) && right.is_a?(Hash)
        keys = (left.keys + right.keys).uniq
        keys.each do |key|
          result += diff(left[key], right[key], path: path + [key])
        end
      else
        result << "#{path.join(".")}: #{left.inspect} (last) != #{right.inspect} (current)"
      end
    end

    result
  end
end
