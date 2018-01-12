require 'rails_helper'
require 'data_transformation/base'
require 'data_transformation/fix_permission_states'
describe DataTransformation::FixPermissionStates do
  subject(:transform) { DataTransformation::FixPermissionStates.new.call }
  context "a role with incorrect permission states" do
    let(:journal) { FactoryGirl.create(:journal) }
    let(:card) { FactoryGirl.create(:card, journal: journal) }
    let(:role) { FactoryGirl.create(:role, journal: journal) }

    context "an edit permission with the wrong states and a view permission" do
      let!(:other_permission) do
        Permission.ensure_exists(:view, applies_to: 'Task', role: role, states: ["submitted"], filter_by_card_id: card.id)
      end
      let!(:permission) do
        Permission.ensure_exists(:edit, applies_to: 'Task', role: role, states: ["submitted"], filter_by_card_id: card.id)
      end

      it "swaps the old permission for new one with the wildcard state by default" do
        subject
        new_permission = role.permissions.find_by(action: "edit")
        expect(new_permission.states.map(&:name)).to eq(["*"])
        expect(new_permission).to_not eq(permission)
      end

      context "an existing permission exists with the correct attributes and states" do
        let!(:existing_valid_permission) { Permission.ensure_exists(:edit, applies_to: 'Task', role: role, states: ["*"], filter_by_card_id: card.id) }
        it "will use an existing permission if it already has the correct parameters" do
          subject
          expect(role.permissions.find_by(action: "edit")).to eq(existing_valid_permission)
        end

        it "does not create a new permission" do
          expect { subject }.to_not(change { Permission.count })
        end
      end

      it "does not change the states for the view permission" do
        expect { subject }.to_not(change { other_permission.states.reload.map(&:id) })
      end

      it "does not delete the old permission from the system" do
        expect(permission.reload).to be_present
      end

      it "keeps the same number of permissions for the role" do
        expect { subject }.to_not(change { role.permissions.reload.count })
      end
    end

    context "an edit permission with the correct states" do
      let!(:permission) do
        Permission.ensure_exists(:edit, applies_to: 'Task', role: role, states: ["*"], filter_by_card_id: card.id)
      end
      it "doesn't touch the edit permission" do
        subject
        new_permission = role.permissions.find_by(action: "edit")
        expect(new_permission.states.map(&:name)).to eq(["*"])
        expect(new_permission).to eq(permission)
      end
    end

    context "a creator role" do
      let(:role) { FactoryGirl.create(:role, name: Role::CREATOR_ROLE, journal: journal) }
      let!(:permission) do
        Permission.ensure_exists(:edit, applies_to: 'Task', role: role, states: ["submitted"], filter_by_card_id: card.id)
      end

      it "makes a new permission with the paper's editable states " do
        subject
        new_permission = role.permissions.find_by(action: "edit")
        expect(new_permission.states.map(&:name)).to match_array(Paper::EDITABLE_STATES.map(&:to_s))
      end
    end

    context "a reviewer role" do
      let(:role) { FactoryGirl.create(:role, name: Role::REVIEWER_ROLE, journal: journal) }
      let!(:permission) do
        Permission.ensure_exists(:edit, applies_to: 'Task', role: role, states: ["submitted"], filter_by_card_id: card.id)
      end

      it "makes the new permissions match the paper's reviewable states" do
        subject
        new_permission = role.permissions.find_by(action: "edit")
        expect(new_permission.states.map(&:name)).to match_array(Paper::REVIEWABLE_STATES.map(&:to_s))
      end
    end
  end
end
