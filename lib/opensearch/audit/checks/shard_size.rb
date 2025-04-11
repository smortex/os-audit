OpenSearch::Audit.add_check(:shard_size) do
  def check
    @index_list.group_names.each do |group_name|
      indices = OpenSearch::Audit::IndexList.new(@index_list.where(group_name: group_name))

      if indices.count < 2
        logger.info "Not enough indices in group #{group_name} to check shard size"
        next
      end

      unique_primary_shards = indices.primary_shards.uniq

      if unique_primary_shards.count > 1
        logger.warn "Not all indices in group #{group_name} have the same number of primary shards: found #{unique_primary_shards.inspect}"
      end

      if indices.median_shard_size < options[:min_shard_size]
        logger.warn format("Shards in group %<group_name>s are too small (%<size>s < %<ref>s).  Consider reducing the number of shards per index or merging indices.",
          group_name: group_name,
          size: ActiveSupport::NumberHelper.number_to_human_size(indices.median_shard_size),
          ref: ActiveSupport::NumberHelper.number_to_human_size(options[:min_shard_size]))

        suggest_larger_indices(indices)
      elsif indices.median_shard_size > options[:max_shard_size]
        logger.warn format("Shards in group %<group_name>s are too big (%<size>s > %<ref>s).  Consider adding more shards per index.",
          group_name: group_name,
          size: ActiveSupport::NumberHelper.number_to_human_size(indices.median_shard_size),
          ref: ActiveSupport::NumberHelper.number_to_human_size(options[:max_shard_size]))

        suggest_optimal_shards_for(indices.median_primary_size)
      end
    end
  end

  def suggest_larger_indices(indices)
    size = indices.median_shard_size
    from_periodicity = nil

    if indices.hourly? && size < options[:min_shard_size]
      from_periodicity ||= "hourly"
      to_periodicity = "daily"
      size *= 24

      suggest_different_periodicity(from_periodicity, to_periodicity, size)
    end

    if from_periodicity || indices.daily? && size < options[:min_shard_size]
      from_periodicity ||= "daily"
      if (weekly_size = 7 * size) > options[:min_shard_size]
        to_periodicity = "weekly"

        suggest_different_periodicity(from_periodicity, to_periodicity, weekly_size)
      end

      if 30 * size > options[:min_shard_size]
        to_periodicity = "monthly"
        size *= 30

        suggest_different_periodicity(from_periodicity, to_periodicity, size)
      end
    end

    if from_periodicity || indices.monthly? && size < options[:min_shard_size]
      from_periodicity ||= "monthly"
      to_periodicity = "yearly"
      size *= 12

      suggest_different_periodicity(from_periodicity, to_periodicity, size)
    end
  end

  def suggest_different_periodicity(from_periodicity, to_periodicity, new_size)
    logger.warn "\tMerge these #{from_periodicity} indices into #{to_periodicity} ones: expected index size: #{ActiveSupport::NumberHelper.number_to_human_size(new_size)}"
    suggest_optimal_shards_for(new_size)
  end

  def suggest_optimal_shards_for(size)
    min_shard = optimal_min_shard_count_for(size)
    max_shard = optimal_max_shard_count_for(size)

    return if max_shard.zero?

    logger.warn format("\tRecommended number of shards for %<median_shard_size>s indices: %<min>d (%<min_shard_shard_size>s per shard, < %<max_shard_size>s) to %<max>d (%<max_shard_shard_size>s per shard, > %<min_shard_size>s).",
      median_shard_size: ActiveSupport::NumberHelper.number_to_human_size(size),
      min: min_shard,
      min_shard_shard_size: ActiveSupport::NumberHelper.number_to_human_size(size / min_shard),
      max_shard_size: ActiveSupport::NumberHelper.number_to_human_size(options[:max_shard_size]),
      max: max_shard,
      max_shard_shard_size: ActiveSupport::NumberHelper.number_to_human_size(size / max_shard),
      min_shard_size: ActiveSupport::NumberHelper.number_to_human_size(options[:min_shard_size]))
  end

  def optimal_min_shard_count_for(size)
    (size.to_f / options[:max_shard_size]).ceil
  end

  def optimal_max_shard_count_for(size)
    (size.to_f / options[:min_shard_size]).floor
  end
end
