require "spec_helper"

RSpec.describe OpenSearch::Audit::IndexGroup do
  let(:index_group) do
    described_class.new([
      OpenSearch::Audit::Index.new({"index" => "logs-2025.01.01", "pri.store.size" => "1000000", "pri" => "1"}),
      OpenSearch::Audit::Index.new({"index" => "logs-2025.01.02", "pri.store.size" => "2000000", "pri" => "1"}),
      OpenSearch::Audit::Index.new({"index" => "logs-2025.01.03", "pri.store.size" => "3000000", "pri" => "1"}),
      OpenSearch::Audit::Index.new({"index" => "logs-2025.01.04", "pri.store.size" => "4000000", "pri" => "1"}),
      OpenSearch::Audit::Index.new({"index" => "logs-2025.01.05", "pri.store.size" => "5000000", "pri" => "1"})
    ])
  end

  describe "#count" do
    subject { index_group.count }

    it { is_expected.to eq(5) }
  end

  describe "#min" do
    subject { index_group.min_shard_size }

    it { is_expected.to eq(1_000_000) }
  end

  describe "#max" do
    subject { index_group.max_shard_size }

    it { is_expected.to eq(5_000_000) }
  end

  describe "#median" do
    subject { index_group.median_shard_size }

    it { is_expected.to eq(3_000_000) }

    context "with an even number of indices" do
      let(:index_group) do
        described_class.new([
          OpenSearch::Audit::Index.new({"index" => "logs-2025.01.01", "pri.store.size" => "1000000", "pri" => "1"}),
          OpenSearch::Audit::Index.new({"index" => "logs-2025.01.02", "pri.store.size" => "2000000", "pri" => "1"}),
          OpenSearch::Audit::Index.new({"index" => "logs-2025.01.03", "pri.store.size" => "3000000", "pri" => "1"}),
          OpenSearch::Audit::Index.new({"index" => "logs-2025.01.04", "pri.store.size" => "4000000", "pri" => "1"})
        ])
      end

      it { is_expected.to eq(2_500_000) }
    end
  end

  describe "#median_trend" do
    subject { index_group.median_shard_size_trend(3) }

    it { is_expected.to eq(4_000_000) }
  end
end
