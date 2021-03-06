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

describe PlosBilling::SalesforceManuscriptUpdateWorker do
  describe 'sidekiq_retries_exhausted' do
    it 'queues up an email to tell site admins there was a problem' do
      msg = {
        'class' => 'FooBar',
        'args' => [99],
        'error_message' => 'something bad happened'
      }
      expect(PlosBilling::BillingSalesforceMailer).to \
        receive_message_chain('delay.notify_site_admins_of_syncing_error').
        with(99, 'Failed FooBar with [99]: something bad happened')
      described_class.sidekiq_retries_exhausted_block.call(msg)
    end
  end

  describe '.email_admin_on_sidekiq_error' do
    let(:dbl) { double }
    let(:msg) do
      {
        'class' => 'SomeClass',
        'args' => [4],
        'error_message' => 'some message'
      }
    end
    let(:error_message) do
      "Failed #{msg['class']} with #{msg['args']}: #{msg['error_message']}"
    end

    it 'queues up an email to tell site admins there was a problem' do
      expect(PlosBilling::BillingSalesforceMailer).to \
        receive_message_chain('delay.notify_site_admins_of_syncing_error').
        with(4, 'Failed SomeClass with [4]: some message')
      described_class.email_admin_on_sidekiq_error(msg)
    end
  end

  describe '#perform' do
    subject(:perform) { worker.perform(paper.id) }
    let(:worker) { described_class.new }
    let!(:paper) { FactoryGirl.create(:paper, id: 88) }
    let(:logger) { Logger.new(log_io) }
    let(:log_io) { StringIO.new }

    before do
      @original_sidekiq_logger = Sidekiq.logger
      Sidekiq.logger = logger
    end

    after do
      Sidekiq.logger = @original_sidekiq_logger
    end

    it 'syncs the paper with Salesforce' do
      expect(SalesforceServices).to receive(:sync_paper!).with(paper)
      perform
    end

    context 'and the paper does not exist' do
      before { paper.destroy }

      it 'does not sync the paper to Salesforce' do
        expect(SalesforceServices).to_not receive(:sync_paper!)
        perform
      end

      it 'logs the error' do
        perform
        expect(log_io.tap(&:rewind).read).to \
          match(/Couldn't find Paper.*#{paper.id}/)
      end
    end

    context 'and syncing to Salesforce raises a SyncInvalid error' do
      before do
        expect(SalesforceServices).to receive(:sync_paper!)
          .and_raise(SalesforceServices::SyncInvalid, "Couldn't do it")
      end

      it 'logs the error' do
        perform
        expect(log_io.tap(&:rewind).read).to \
          match(/Couldn't do it/)
      end

      it 'queues up an email to tell site admins there was a problem' do
        expect(PlosBilling::BillingSalesforceMailer).to \
          receive_message_chain('delay.notify_site_admins_of_syncing_error') do |paper_id, message|
            expect(paper_id).to eq(paper.id)
            expect(message).to match(/PlosBilling::SalesforceManuscriptUpdateWorker#perform failed due to an SalesforceServices::SyncInvalid/)
          end
        perform
      end
    end
  end
end
