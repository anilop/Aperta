# Copyright (c) 2018 Public Library of Science

# Permission is hereby granted, free of charge, to any person obtaining a
# copy of this software and associated documentation files (the "Software"),
# to deal in the Software without restriction, including without limitation
# the rights to use, copy, modify, merge, publish, distribute, sublicense,
# and/or sell copies of the Software, and to permit persons to whom the
# Software is furnished to do so, subject to the following conditions:

# The above copyright notice and this permission notice shall be included in
# all copies or substantial portions of the Software.

# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL
# THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
# FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER
# DEALINGS IN THE SOFTWARE.

require "jing"
require 'tempfile'

# This class is responsible for validating, loading, and parsing a
# Card XML string.
class XmlCardDocument
  attr_reader :raw, :doc

  SCHEMA_FILE = Rails.root.join('config', 'card.rng').freeze
  CARD_XPATH = "/card".freeze
  CONTENT_XPATH = "/card/*".freeze

  # custom exception class wraps list of errors, each with positional info
  class XmlValidationError < StandardError
    attr_reader :errors
    def initialize(errors)
      @errors = []
      if errors.respond_to?(:full_messages)
        errors.full_messages.each do |message|
          @errors << {
            message: message
          }
        end
      else
        errors.each do |error|
          @errors << {
            message: error[:message],
            line: error[:line],
            col: error[:column]
          }
        end
      end
    end

    def message
      errors
    end
  end

  def initialize(xml_string)
    @raw = xml_string
    validate!
    @doc = parse(@raw)
  end

  def validate!
    # create a temp file for xml content (required by Jing validator API)
    temproot = Rails.root.join('tmp').to_s
    tempfile = Tempfile.new('card_xml', temproot)
    tempfile.write(@raw)
    tempfile.close

    errors = schema.validate(tempfile.path)
    raise(XmlValidationError, errors) unless errors.empty?
  ensure
    tempfile.unlink
  end

  def card
    @card ||= begin
      el = doc.xpath(CARD_XPATH).first
      XmlElementDataExtractor.new(el)
    end
  end

  def contents
    @content ||= begin
      els = doc.xpath(CONTENT_XPATH)
      els.map { |el| XmlElementDataExtractor.new(el) }
    end
  end

  private

  def parse(xml_string)
    Nokogiri::XML.parse(xml_string)
  end

  def schema
    @schema ||= Jing.new(SCHEMA_FILE.to_s)
  end
end
