# rubocop:disable all
namespace :data do
  namespace :migrate do
    namespace :users do
      desc 'Migrates users to use new R&P'
      task make_into_new_roles: :environment do
        User.all.each do |user|
          puts "Assigning #{user.full_name} <#{user.email}> to User role in the system"
          Assignment.where(
            role: Role.user,
            user: user,
            assigned_to: user
          ).first_or_create!
        end
      end
    end
  end
end