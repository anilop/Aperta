class PaperScenario < TemplateContext
  def manuscript
    @manuscript ||= PaperContext.new(manuscript_object)
  end

  def journal
    @journal ||= JournalContext.new(manuscript_object.journal)
  end

  def self.scenario_name
    name.gsub(/Scenario$/, '')
  end

  private

  def manuscript_object
    @object
  end
end
