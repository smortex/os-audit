require "spec_helper"

RSpec.describe OpenSearch::Audit::Index do
  describe ".group_name" do
    subject { described_class.group_name(index_name) }

    {
      ".samplerr-2024" => ".samplerr-YYYY",
      ".samplerr-2025.02" => ".samplerr-YYYY.MM",
      "dej418" => "dej418",
      "logs-2025-03-21" => "logs-YYYY-MM-dd",
      "logs-2025.03.21" => "logs-YYYY.MM.dd",
      "top_queries-2025.04.01-51422" => "top_queries-YYYY.MM.dd-NNNNN"
    }.each do |index_name, expected_group_name|
      describe "with index #{index_name}" do
        let(:index_name) { index_name }

        it { is_expected.to eq(expected_group_name) }
      end
    end
  end
end
