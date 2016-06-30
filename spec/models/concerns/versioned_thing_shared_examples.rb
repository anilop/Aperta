require 'rails_helper'

RSpec.shared_examples 'a thing with major and minor versions' do |name|
  let(:paper) { FactoryGirl.create(:paper) }

  before do
    @things = name.to_s.pluralize.to_sym
  end

  let!(:version_0_0) do
    FactoryGirl.create(
      name.to_sym,
      paper: paper,
      major_version: 0,
      minor_version: 0)
  end

  let!(:version_0_1) do
    FactoryGirl.create(
      name.to_sym,
      paper: paper,
      major_version: 0,
      minor_version: 1)
  end

  describe '#version_desc' do
    it 'should return the versioned things in descending version order' do
      things = paper.send(@things).versioned
      expect(things.version_desc.to_a).to match([version_0_1, version_0_0])
    end

    it 'should return an unversioned thing first' do
      things = paper.send(@things)
      expect(things.version_desc.first.major_version).to be(nil)
      expect(things.version_desc.first.minor_version).to be(nil)
    end
  end

  describe '#version_asc' do
    it 'should return the versioned things in ascending version order' do
      things = paper.send(@things).versioned
      expect(things.version_asc.to_a).to match([version_0_0, version_0_1])
    end

    it 'should return an unversioned thing last' do
      things = paper.send(@things)
      expect(things.version_asc.last.major_version).to be(nil)
      expect(things.version_asc.last.minor_version).to be(nil)
    end
  end
end
