require "spec_helper"

RSpec.describe OpenSearch::Audit::IndexGroup do
  subject(:index_group) do
    res = described_class.new
    res.add({"index" => "logs-2025.01.01", "pri.store.size" => "1000000", "pri" => "1"})
    res.add({"index" => "logs-2025.01.02", "pri.store.size" => "2000000", "pri" => "1"})
    res.add({"index" => "logs-2025.01.03", "pri.store.size" => "3000000", "pri" => "1"})
    res.add({"index" => "logs-2025.01.04", "pri.store.size" => "4000000", "pri" => "1"})
    res.add({"index" => "logs-2025.01.05", "pri.store.size" => "5000000", "pri" => "1"})
    res
  end

  describe "#count" do
    subject { index_group.count }

    it { is_expected.to eq(5) }
  end

  describe "#min" do
    subject { index_group.min }

    it { is_expected.to eq(1_000_000) }
  end

  describe "#max" do
    subject { index_group.max }

    it { is_expected.to eq(5_000_000) }
  end

  describe "#median" do
    subject { index_group.median }

    it { is_expected.to eq(3_000_000) }
  end

  describe "#median_trend" do
    subject { index_group.median_trend(3) }

    it { is_expected.to eq(4_000_000) }
  end
end
