FactoryGirl.define do
  factory :reviewer_recommendations_task, class: 'TahiStandardTasks::ReviewerRecommendationsTask' do
    phase
    title "Reviewer Candidates"
    role "author"
  end
end