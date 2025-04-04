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
      "logs-2025.03.21.12" => "logs-YYYY.MM.dd.HH",
      "top_queries-2025.04.01-51422" => "top_queries-YYYY.MM.dd-NNNNN"
    }.each do |index_name, expected_group_name|
      describe "with index #{index_name}" do
        let(:index_name) { index_name }

        it { is_expected.to eq(expected_group_name) }
      end
    end
  end

  describe "#yearly?" do
    subject { described_class.new(index).yearly? }

    let(:index) do
      {"index" => index_name, "pri.store.size" => "0", "pri" => "1"}
    end

    {
      ".samplerr-2024" => true,
      ".samplerr-2025.02" => false,
      "dej418" => false,
      "logs-2025-03-21" => false,
      "logs-2025.03.21" => false,
      "logs-2025.03.21.12" => false,
      "top_queries-2025.04.01-51422" => false
    }.each do |index_name, expected_result|
      context "with index #{index_name}" do
        let(:index_name) { index_name }

        if expected_result
          it { is_expected.to be_truthy }
        else
          it { is_expected.to be_falsey }
        end
      end
    end
  end

  describe "#monthly?" do
    subject { described_class.new(index).monthly? }

    let(:index) do
      {"index" => index_name, "pri.store.size" => "0", "pri" => "1"}
    end

    {
      ".samplerr-2024" => false,
      ".samplerr-2025.02" => true,
      "dej418" => false,
      "logs-2025-03-21" => false,
      "logs-2025.03.21" => false,
      "logs-2025.03.21.12" => false,
      "top_queries-2025.04.01-51422" => false
    }.each do |index_name, expected_result|
      context "with index #{index_name}" do
        let(:index_name) { index_name }

        if expected_result
          it { is_expected.to be_truthy }
        else
          it { is_expected.to be_falsey }
        end
      end
    end
  end

  describe "#daily?" do
    subject { described_class.new(index).daily? }

    let(:index) do
      {"index" => index_name, "pri.store.size" => "0", "pri" => "1"}
    end

    {
      ".samplerr-2024" => false,
      ".samplerr-2025.02" => false,
      "dej418" => false,
      "logs-2025-03-21" => true,
      "logs-2025.03.21" => true,
      "logs-2025.03.21.12" => false,
      "top_queries-2025.04.01-51422" => true
    }.each do |index_name, expected_result|
      context "with index #{index_name}" do
        let(:index_name) { index_name }

        if expected_result
          it { is_expected.to be_truthy }
        else
          it { is_expected.to be_falsey }
        end
      end
    end
  end

  describe "#hourly?" do
    subject { described_class.new(index).hourly? }

    let(:index) do
      {"index" => index_name, "pri.store.size" => "0", "pri" => "1"}
    end

    {
      ".samplerr-2024" => false,
      ".samplerr-2025.02" => false,
      "dej418" => false,
      "logs-2025-03-21" => false,
      "logs-2025.03.21" => false,
      "logs-2025.03.21.12" => true,
      "top_queries-2025.04.01-51422" => false
    }.each do |index_name, expected_result|
      context "with index #{index_name}" do
        let(:index_name) { index_name }

        if expected_result
          it { is_expected.to be_truthy }
        else
          it { is_expected.to be_falsey }
        end
      end
    end
  end
end
