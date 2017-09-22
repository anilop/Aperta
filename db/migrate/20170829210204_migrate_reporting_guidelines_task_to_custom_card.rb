class MigrateReportingGuidelinesTaskToCustomCard < ActiveRecord::Migration
  def up
    # load custom card into the system
    CustomCard::Loader.all

    # migrate legacy task to custom card
    migrator = CustomCard::Migrator.new(legacy_task_klass_name: "TahiStandardTasks::ReportingGuidelinesTask", card_name: "Reporting Guidelines")
    migrator.migrate
  end
end