OpenSearch::Audit.add_check(:index_name) do
  def check
    @index_list.each do |index|
      if /\d{4}-\d{2}-\d{2}/.match?(index.name)
        logger.warn("Prefer YYYY.MM.dd to YYYY-MM-dd for naming indices: #{index.name}")
      end
    end
  end
end
