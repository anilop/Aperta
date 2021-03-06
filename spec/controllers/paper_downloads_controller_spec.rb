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

require 'rails_helper'

describe PaperDownloadsController, type: :controller do
  include Rails.application.routes.url_helpers

  let!(:paper) { create(:paper, :version_with_file_type, :with_creator) }
  let!(:versioned_text) do
    paper.reload # weirdly, this is needed for paper.file to not be nil
    create(
      :versioned_text,
      paper: paper,
      file_type: 'docx',
      manuscript_s3_path: 'sample/path',
      manuscript_filename: 'name.docx'
    )
  end
  let!(:manuscript_attachment) do
     create(:manuscript_attachment,
     owner: paper,
     file:'name.docx',
     s3_dir: 'sample/path',
     )
   end
  let!(:user) { create(:user) }

  describe 'GET show' do
    subject(:do_request) do
      get(
        :show,
        id: paper.to_param,
        versioned_text_id: versioned_text.to_param,
        export_format: 'docx',
        format: :json
      )
    end

    it_behaves_like 'an unauthenticated json request'

    context 'as a user with access to a paper' do
      before do
        stub_sign_in(user)
        allow(user).to receive(:can?)
          .with(:view, paper)
          .and_return true
      end

      it 'redirects to the correct s3 file' do
        quoted = Regexp.quote(versioned_text.s3_full_path)
        expect(do_request).to redirect_to(/#{quoted}.+Amz-SignedHeaders/)
      end

      context 'a synchronous conversion is requested' do
        let!(:versioned_text) do
          paper.reload # weirdly, this is needed for paper.file to not be nil
          paper.file.update(file_type: 'pdf')
          create(
            :versioned_text,
            paper: paper,
          )
        end

        subject(:do_request) do
          get(
            :show,
            id: paper.to_param,
            versioned_text_id: versioned_text.to_param,
            export_format: 'pdf_with_attachments',
            format: :json
          )
        end

        it 'sends data to the browser', vcr: { cassette_name: 'pdf_file', match_requests_on: [:method] } do
          do_request
          expect(response).to be_success
          expect(response.headers['Content-Disposition']).to match /attachment/
          expect(response.headers['Content-Type']).to eq 'application/pdf'
        end
      end

      context 'the VersionedText is not specified' do
        subject(:do_request) do
          get(
            :show,
            id: paper.to_param,
            export_format: 'docx',
            format: :json
          )
        end
        let(:expected_versioned_text) { paper.latest_version }

        it 'redirects to the file corresponding to latest versioned text' do
          quoted = Regexp.quote(expected_versioned_text.s3_full_path)
          expect(do_request).to redirect_to(/#{quoted}.+Amz-SignedHeaders/)
        end
      end

      context 'the specified VersionedText does not belong to the paper' do
        let!(:versioned_text) do
          create(
            :versioned_text,
            file_type: 'docx',
            manuscript_s3_path: 'sample/path',
            manuscript_filename: 'name.docx'
          )
        end
        let!(:manuscript_attachment) do
          create(:manuscript_attachment, owner: versioned_text.paper)
        end

        it 'returns a 404' do
          do_request
          expect(response.status).to eq(404)
        end
      end
    end

    context "when the user does not have access" do
      before do
        stub_sign_in(user)
        allow(user).to receive(:can?)
          .with(:view, paper)
          .and_return false
        do_request
      end

      it { is_expected.to responds_with(403) }
    end
  end
end
