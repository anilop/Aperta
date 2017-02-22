require 'rails_helper'

describe PaperDownloadsController, type: :controller do
  include Rails.application.routes.url_helpers

  let!(:paper) { create(:paper, :version_with_file_type) }
  let!(:versioned_text) do
    paper.reload # weirdly, this is needed for paper.file to not be nil
    create(
      :versioned_text,
      paper: paper,
      file_type: 'pdf',
      s3_dir: 'sample/path',
      file: 'name.pdf'
    )
  end
  let!(:manuscript_attachment) { create(:manuscript_attachment, owner: paper) }
  let!(:user) { create(:user) }

  describe 'GET show' do
    subject(:do_request) do
      get(
        :show,
        id: paper.to_param,
        versioned_text_id: versioned_text.to_param,
        export_format: 'pdf',
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

      it 'returns the download url' do
        do_request
        expect(response.status).to eq(200)
        quoted = Regexp.quote(versioned_text.s3_full_path)
        expect(res_body['url']).to match(/#{quoted}.+Amz-SignedHeaders/)
      end

      context 'the VersionedText is not specified' do
        subject(:do_request) do
          get(
            :show,
            id: paper.to_param,
            export_format: 'pdf',
            format: :json
          )
        end
        let(:expected_versioned_text) { paper.latest_version }

        it 'returns the file corresponding to latest versioned text' do
          do_request
          expect(response).to be_success
          quoted = Regexp.quote(expected_versioned_text.s3_full_path)
          expect(res_body['url']).to match(/#{quoted}.+Amz-SignedHeaders/)
        end
      end

      context 'the specified VersionedText does not belong to the paper' do
        let!(:versioned_text) do
          create(
            :versioned_text,
            file_type: 'pdf',
            s3_dir: 'sample/path',
            file: 'name.pdf'
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
