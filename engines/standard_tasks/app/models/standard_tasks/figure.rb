module StandardTasks
  class Figure < ActiveRecord::Base
    self.table_name = "figures"

    # include PaperDecorator

    belongs_to :figure_task, class_name: "StandardTasks::FigureTask", inverse_of: :figures, foreign_key: :task_id

    # paper.figures are being returned in reverse-id order
    # Why the hell is that happening?
    default_scope { order(:id) }

    before_create :insert_title

    def paper
      figure_task.paper
    end

    def insert_title
      self.title = "Title: #{attachment.filename}" if attachment.present?
    end

    mount_uploader :attachment, AttachmentUploader

    def self.acceptable_content_type?(content_type)
      !!(content_type =~ /(^image\/(gif|jpe?g|png|tif?f)|application\/postscript)$/i)
    end

    def filename
      self[:attachment]
    end

    def alt
      filename.split('.').first.gsub(/#{File.extname(filename)}$/, '').humanize
    end

    def src
      attachment.url
    end

    def preview_src
      attachment.url(:preview)
    end

    def access_details
      { filename: filename, alt: alt, id: id, src: src }
    end

  end
end
