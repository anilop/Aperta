require "rails_helper"

describe Snapshot::PublishingRelatedQuestionsTaskSerializer do
  subject(:serializer) { described_class.new(task) }
  let(:task) { FactoryGirl.create(:publishing_related_questions_task) }

  describe "#as_json" do
    it "serializes to JSON" do
      expect(serializer.as_json).to include(
        name: "publishing-related-questions-task",
        type: "properties"
      )
    end

    context "serializing related nested questions" do
      it_behaves_like "snapshot serializes related answers as nested questions", resource: :task
    end
  end
end
