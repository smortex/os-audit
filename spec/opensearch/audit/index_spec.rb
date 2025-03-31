require "spec_helper"

RSpec.describe OpenSearch::Audit::Index do
  describe ".group_name" do
    subject { described_class.group_name(index_name) }

    {
      "dej418" => "dej418",
      "logs-2025.03.21" => "logs-YYYY.MM.dd",
      ".samplerr-2025.02" => ".samplerr-YYYY.MM",
      ".samplerr-2024" => ".samplerr-YYYY"
    }.each do |index_name, expected_group_name|
      describe "with index #{index_name}" do
        let(:index_name) { index_name }

        it { is_expected.to eq(expected_group_name) }
      end
    end
  end
end
