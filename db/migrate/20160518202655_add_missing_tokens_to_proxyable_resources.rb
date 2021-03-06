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

class AddMissingTokensToProxyableResources < ActiveRecord::Migration
  class Figure < ActiveRecord::Base
    def regenerate_token
      update_columns token: SecureRandom.hex(24)
    end
  end
  class SupportingInformationFile < ActiveRecord::Base
    def regenerate_token
      update_columns token: SecureRandom.hex(24)
    end
  end
  class QuestionAttachment < ActiveRecord::Base
    def regenerate_token
      update_columns token: SecureRandom.hex(24)
    end
  end

  def add_missing_tokens(klass)
    query = klass.where(token: nil)
    return if query.count == 0

    puts "Adding missing #{query.count} tokens to #{klass.name.demodulize} records..."
    query.each(&:regenerate_token)
    puts 'Done.'
  end

  def change
    Figure.reset_column_information
    SupportingInformationFile.reset_column_information
    QuestionAttachment.reset_column_information

    reversible do |dir|
      dir.up do
        [Figure, SupportingInformationFile, QuestionAttachment].each do |klass|
          add_missing_tokens(klass)
        end
      end
    end
  end
end
