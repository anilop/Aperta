require "rails_helper"

describe TahiStandardTasks::RelatedArticlesTaskSerializer,
         serializer_test: true do
  let(:object_for_serializer) { FactoryGirl.create :related_articles_task }

  it "serializes successfully" do
    expect(deserialized_content).to be_kind_of Hash
  end

  describe "serialized content" do
    it 'includes the data we expect' do
      expect(deserialized_content)
        .to match(hash_including({}))
    end
  end
end