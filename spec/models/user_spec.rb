# coding: utf-8
require 'rails_helper'

describe User do
  it "will be valid with default factory data" do
    expect(build(:user)).to be_valid
  end

  describe "scopes" do
    let(:user1) { FactoryGirl.create(:user) }
    let(:user2) { FactoryGirl.create(:user) }

    describe ".admins" do
      it "includes admin users only" do
        user1.update! site_admin: true
        admins = User.site_admins
        expect(admins).to include user1
        expect(admins).not_to include user2
      end
    end
  end

  describe '#created_papers_for_journal' do
    subject(:user) { FactoryGirl.create(:user) }
    let(:journal) { FactoryGirl.create(:journal, :with_roles_and_permissions) }
    let!(:other_user) { FactoryGirl.create(:user) }

    let!(:created_paper_1) do
      FactoryGirl.create(:paper, journal: journal, creator: user)
    end
    let!(:created_paper_2) do
      FactoryGirl.create(:paper, journal: journal, creator: user)
    end
    let!(:not_my_paper) do
      FactoryGirl.create(:paper, journal: journal, creator: other_user)
    end

    it 'returns papers where this user is its creator' do
      created_papers = user.created_papers_for_journal(journal)
      expect(created_papers).to contain_exactly(
        created_paper_1,
        created_paper_2
      )
    end

    it 'does not return other papers' do
      created_papers = user.created_papers_for_journal(journal)
      expect(created_papers).to_not include(not_my_paper)
    end
  end

  describe "#full_name" do
    it "returns the user's first and last name" do
      user = User.new first_name: 'Mihaly', last_name: 'Csikszentmihalyi'
      expect(user.full_name).to eq 'Mihaly Csikszentmihalyi'
    end
  end

  describe '#username' do
    it 'validates username' do
      user = FactoryGirl.build(:user, username: 'mihaly')
      expect(user.save!).to eq true
    end

    it 'validates a username with dashes' do
      user = FactoryGirl.build(:user, username: 'blah-blah')
      expect(user).to be_valid
    end

    it 'validates against blank username' do
      user = FactoryGirl.build(:user, username: '')
      expect(user).to_not be_valid
      expect(user.errors.to_a).to contain_exactly("Username can't be blank")
    end

    it 'allows a username with periods' do
      user = FactoryGirl.build(:user, username: 'blah.blah')
      expect(user).to be_valid
    end

    it 'allows a username with with utf-8' do
      user = FactoryGirl.build(:user, username: 'bláh blàh')
      expect(user).to be_valid

      user = FactoryGirl.build(:user, username: '😻')
      expect(user).to be_valid

      user = FactoryGirl.build(:user, username: 'Лев Никола́евич Толсто́й')
      expect(user).to be_valid

      user = FactoryGirl.build(:user, username: '李尧棠')
      expect(user).to be_valid
    end
  end

  describe '#tasks' do
    subject(:user) { FactoryGirl.create(:user) }
    let(:paper) { FactoryGirl.create(:paper, :with_integration_journal)}
    let!(:participating_task) { FactoryGirl.create(:task, paper: paper) }
    let!(:not_participating_task) { FactoryGirl.create(:task, paper: paper) }
    let!(:other_role) { FactoryGirl.create(:role) }

    before do
      participating_task.add_participant user
      not_participating_task.assignments.create!(user: user, role: other_role)
    end

    it 'returns tasks the user is assigned to as a participant' do
      expect(user.tasks).to contain_exactly(participating_task)
    end

    it 'does not return tasks the user is assigned with another role' do
      expect(user.tasks).to_not include(not_participating_task)
    end
  end

  describe '#invitations_from_latest_revision' do
    let(:user) { FactoryGirl.create(:user) }
    before do
      paper = FactoryGirl.create :paper
      paper.decisions.create!
    end

    it 'returns invitations from the latest revision cycle' do
      paper = FactoryGirl.create :paper
      decision = paper.decisions.create!
      task = FactoryGirl.create :invitable_task, paper: paper
      inv1 = FactoryGirl.create :invitation, task: task, invitee: user, decision: decision
      inv2 = FactoryGirl.create :invitation, task: task, invitee: user, decision: decision
      inv1.invite!
      inv2.invite!
      expect(user.invitations_from_latest_revision).to match_array [inv1, inv2]
      decision = paper.decisions.create!
      inv3 = FactoryGirl.create :invitation, task: task, invitee: user, decision: decision
      inv3.invite!
      expect(user.reload.invitations_from_latest_revision).to match_array [inv3]
    end

    context 'invitation without a decision' do
      before do
        task = FactoryGirl.create :invitable_task
        invitation = FactoryGirl.create :invitation, task: task, invitee: user
        # force-delete the decision
        invitation.decision.destroy!
      end

      it 'returns invitations with decisions from the latest revision cycle' do
        expect(user.invitations_from_latest_revision).to be_empty
      end
    end
  end

  describe ".new_with_session" do
    let(:personal_details) { {"personal_details" => {"given_names" => "Joe", "family_name" => "Smith"}} }
    let(:orcid_session) do
      {"devise.provider" => {"orcid" => {"uid" => "myuid",
                                         "info" => {"orcid_bio" => personal_details}}}}
    end

    it "will prefill new user form with orcid info" do
      user = User.new_with_session(nil, orcid_session)
      expect(user.first_name).to eq('Joe')
      expect(user.last_name).to eq('Smith')
    end

    it "will auto generate a password" do
      user = User.new_with_session(nil, orcid_session)
      expect(user.password).not_to be_empty
    end
  end

  context "password authentication" do
    let(:user) { User.new }
    before { expect(Rails.configuration).to receive(:password_auth_enabled).and_return(enabled) }

    context "is enabled" do
      let(:enabled) { true }

      specify { expect(user.password_required?).to eq(enabled) }
      specify { expect(user.auto_generate_password).to be_present }
    end

    context "is disabled" do
      let(:enabled) { false }

      specify { expect(user.password_required?).to eq(enabled) }
      specify { expect(user.auto_generate_password).to be_blank }
    end
  end


  describe ".fuzzy_search" do
    it "searches by user's first_name and last_name" do
      user = create :user, first_name: 'David', last_name: 'Wang'

      expect(User.fuzzy_search(user.first_name).size).to eq 1
      expect(User.fuzzy_search(user.first_name.downcase).first.id).to eq user.id
      expect(User.fuzzy_search(user.last_name.downcase).first.id).to eq user.id
      expect(User.fuzzy_search("#{user.first_name} #{user.last_name.downcase}").first.id).to eq user.id
    end

    it "searches by user's email" do
      user = create :user, email: 'dwang@gmail.com'
      expect(User.fuzzy_search(user.email).first.id).to eq user.id
    end

    it "searches by user's username" do
      user = create :user, username: 'dwangpwn'
      expect(User.fuzzy_search(user.username).first.id).to eq user.id
    end

    it "searches by multiple attributes at once" do
      user = create :user, username: 'blah', first_name: 'David', last_name: 'Wang', email: 'dwang@gmail.com'
      expect(User.fuzzy_search("#{user.first_name} #{user.username}").first.id).to eq user.id
    end

    it "searches attributes with accent marks" do
      user = create :user, first_name: 'David', last_name: 'Wang'
      expect(User.fuzzy_search("davïd").first.id).to eq user.id
    end
  end

  describe "#journal_admin?" do
    let(:paper) { FactoryGirl.create(:paper, :with_integration_journal) }
    let(:journal) { paper.journal }
    let(:journal_admin) { FactoryGirl.create(:user) }
    let!(:old_role) { assign_journal_role(journal, journal_admin, :admin) }
    let(:regular_user) { FactoryGirl.create(:user) }

    it "returns true if user is an admin for a given journal" do
      expect(journal_admin.can?(:administer, journal)).to be true
    end

    it "returns false if user is not an admin for a given journal" do
      expect(regular_user.can?(:administer, journal)).to be false
    end
  end

  describe "#create" do
    describe "roles" do
      let(:user) { User.create! attributes_for(:user) }
      let!(:user_role) { Role.where(name: 'User').first_or_create! }

      it "should create a user record with the User role assigned" do
        expect(user_role).to be_present
        expect(user).to have_role_name 'User'
      end
    end

    describe "invitations" do
      let!(:orphan_invite) { FactoryGirl.create(:invitation, invitee: nil, email: "steve@example.com") }
      let!(:other_invite) { FactoryGirl.create(:invitation, invitee: nil) }

      it "assigns invitations to the user" do
        user_attrs = attributes_for(:user)
        user_attrs[:email] = 'steve@example.com'
        user = User.create!(user_attrs)
        expect(orphan_invite.reload.invitee_id).to be(user.id)
        expect(other_invite.reload.invitee).to be_nil
      end
    end
  end
end
