# This class creates an in memory ZIP file for FTP to Apex
class ApexPackager
  def self.create(paper)
    packager = ApexPackager.new(paper)
    packager.zip
  end

  def initialize(paper)
    @paper = paper
  end

  def zip
    buffer = Zip::OutputStream.write_buffer do |package|
      @package = package
      add_manuscript
      add_striking_image
      add_figures
      add_supporting_information
      add_metadata
    end

    buffer.string
  end

  private

  def add_manuscript
  end

  def add_striking_image
    return unless @paper.striking_image

    @package.put_next_entry(@paper.striking_image.apex_filename)
    @package.write(@paper.striking_image.attachment.read)
  end

  def add_figures
    return unless figures_comply?
    @paper.figures.select { |f| f.striking_image == false }.each do |figure|
      @package.put_next_entry(figure.apex_filename)
      @package.write(figure.attachment.read)
    end
  end

  def add_supporting_information
    @paper.supporting_information_files.each do |file|
      next unless file.publishable?
      @package.put_next_entry(file.filename)
      @package.write(file.attachment.read)
    end
  end

  def add_metadata
  end

  def figures_comply?
    find_answer('TahiStandardTasks::FigureTask', 'figure_complies')
  end

  def find_answer(task_type, ident)
    t = @paper.tasks.find_by_type(task_type)
    return unless t
    return unless t.answer_for(ident)

    t.answer_for(ident).value
  end
end
