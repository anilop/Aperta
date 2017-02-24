module PaperConverters
  class UnknownConversionError < StandardError; end

  # Base class of paper converters. Use ::make to get a particular instance of
  # a paper converter
  class PaperConverter
    def self.make(versioned_text, export_format)
      current_type = versioned_text.file_type
      if export_format == current_type
        return IdentityPaperConverter.new(versioned_text, export_format)
      else
        raise(
          UnknownConversionError,
          "I don't know how to convert #{current_type} to #{export_format}"
        )
      end
    end

    def initialize(versioned_text, export_format)
      @versioned_text = versioned_text
      @export_format  = export_format
    end

    def self.connection
      return @connection if @connection
      @connection = Faraday.new(url: ENV.fetch('IHAT_URL')) do |config|
        config.request :multipart
        config.response :json
        config.request :url_encoded
        config.adapter :net_http
      end
    end

    # Post a job to the ihat server.
    #
    # @return [IhatJobResponse]
    def self.post_ihat_job(req)
      input = Faraday::UploadIO.new(req.file, req.content_type)
      response = connection.post('/jobs', job: {
                                   input: input,
                                   options: req.make_options
                                 })
      IhatJobResponse.new(response.body.with_indifferent_access[:job])
    end
  end
end
