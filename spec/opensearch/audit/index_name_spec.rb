require "opensearch/audit/index_name"

RSpec.describe OpenSearch::Audit::IndexName do
  describe '#base_name' do
    subject { described_class.new(index).base_name }

    let(:index) { { "index" => index_name } }

    {
      "dej418" => "dej418",
      "logs-2025.03.21" => "logs-YYYY.MM.dd",
      ".samplerr-2025.02" => ".samplerr-YYYY.MM",
      ".samplerr-2024" => ".samplerr-YYYY",
    }.each do |index_name, expected_base_name|
      describe "with index #{index_name}" do
        let(:index_name) { index_name }

        it { is_expected.to eq(expected_base_name) }
      end
    end
  end

  describe "#periodic?" do
    subject { described_class.new(index).periodic? }

    let(:index) { { "index" => index_name } }

    {
      "dej418" => false,
      "logs-2025.03.21" => true,
      ".samplerr-2025.02" => true,
      ".samplerr-2024" => true,
    }.each do |index_name, expected_base_name|
      describe "with index #{index_name}" do
        let(:index_name) { index_name }

        it { is_expected.to eq(expected_base_name) }
      end
    end
  end
end
