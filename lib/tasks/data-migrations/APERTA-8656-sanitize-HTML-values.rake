# Migration for handling snapshot HTML sanitization for APERTA-8656
namespace :data do
  namespace :migrate do
    namespace :html_sanitization do
      desc 'It goes through every snapshot that has HTML values in it sanitizes it'
      task :sanitize_snapshot_html => :environment do
        set = []
        set.push([['adhoc-attachment',
                   'decision-attachment',
                   'invitation-attachment',
                   'manuscript-attachment',
                   'question-attachment',
                   'sourcefile-attachment',
                   'figure'], ['caption', 'title']])
        set.push([['decision'], ['letter']])
        set.push([['discussion-reply'], ['letter']])
        set.push([['invitation'], ['body', 'decline_reason', 'reviewer_suggestions']])
        set.push([['paper'], ['title', 'abstract']])
        set.push([['related-article'], ['linked_title']])

        set.each do |m|
          SnapshotMigratorIterator.run!(m, true)
        end
      end
      desc 'It goes through every answer that has HTML values in and sanitize it'
      task :sanitize_answer_html => :environment do
        idents = ['cover_letter--text',
                  'data_availability--data_location',
                  'front_matter_reviewer_report--suitable--comment',
                  'production_metadata--production_notes',
                  'publishing_related_questions--short_title',
                  'reviewer_report--comments_for_author']

        CardContent.where(ident: idents).includes(:answers).each do |cc|
          puts "migrating card content answers #with #{cc.ident}"
          cc.answers.each do |answer|
            old_value = answer.value
            new_value = HtmlScrubber.standalone_scrub!(old_value)
            if old_value != new_value && old_value.present?
              puts "Html sanitized for Answer #{answer.id} : #{Diffy::Diff.new(old_value, new_value, context: 1).to_s(:html)}"
            end
            # answer.update!(value: new_value) unless args[:dry_run]
          end
        end
      end
    end
  end
end

# Helper class for APERTA-8656 snapshot migration
class SnapshotMigratorIterator
  def self.run!(arr, dry_run)
    arr[0].each do |model_name|
      sm = SnapshotMigrator.new(model_name, arr[1], HtmlSanitizationSnapshotConverter.new, dry_run)
      sm.call!
    end
  end
end