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

describe CardContentValidation do
  context 'validate' do
    describe '#letter_template_exists' do
      let(:content) { FactoryGirl.build(:card_content, :template) }

      it 'is valid with an existing template' do
        FactoryGirl.create(:letter_template, ident: 'ident')
        expect(content).to be_valid
      end

      it 'is invalid with a non existing template' do
        FactoryGirl.create(:letter_template, ident: 'not matching')
        expect(content).not_to be_valid
      end
    end

    context '#validate_by_string_match' do
      subject(:card_content_validation) do
        FactoryGirl.create(:card_content_validation, :with_string_match_validation, validator: 'org')
      end
      let(:answer) { FactoryGirl.create(:answer, :with_task_owner, value: 'corgi') }
      let!(:card_content) { FactoryGirl.create(:card_content, answers: [answer], card_content_validations: [card_content_validation]) }

      it 'is valid if the string matches a simple regex' do
        expect(card_content_validation.validate_answer(answer)).to eq true
      end

      it 'is valid with a more complex regex' do
        subject.update!(validator: '^\w{4}\.\d{7}$')
        answer.update(value: 'pbio.1000000')
        expect(card_content_validation.validate_answer(answer)).to eq true
      end

      it 'is invalid if the string doesnt match' do
        answer.update!(value: 'eskie')
        expect(card_content_validation.validate_answer(answer)).to eq false
      end
    end

    context '#validate_by_string_length_minimum' do
      subject(:card_content_validation) do
        FactoryGirl.create(:card_content_validation, :with_string_length_minimum_validation)
      end
      let(:answer) { FactoryGirl.create(:answer, :with_task_owner, value: 'corgi') }
      let!(:card_content) { FactoryGirl.create(:card_content, answers: [answer], card_content_validations: [card_content_validation]) }

      it 'is invalid if validator string format is incorrect' do
        card_content_validation.validator = 'a string'
        expect(card_content_validation.validate_answer(answer)).to eq false
      end

      it 'is invalid if validator string is a negative number' do
        card_content_validation.validator = '-1'
        expect(card_content_validation.validate_answer(answer)).to eq false
      end

      it 'is invalid if answer length is less than minimum required' do
        card_content_validation.validator = '5'
        answer.value = 'abc'
        expect(card_content_validation.validate_answer(answer)).to eq false
      end

      it 'is valid if answer length is greater than minimum required' do
        card_content_validation.validator = '5'
        answer.value = 'abcde'
        expect(card_content_validation.validate_answer(answer)).to eq true
      end
    end

    context '#validate_html_by_length_minimum' do
      subject(:card_content_validation) do
        FactoryGirl.create(:card_content_validation, :with_string_length_minimum_validation)
      end
      let(:answer) { FactoryGirl.create(:answer, :with_task_owner, value: '<p>Test</p>') }
      let!(:card_content) { FactoryGirl.create(:card_content, answers: [answer], card_content_validations: [card_content_validation], value_type: 'html') }

      it 'is invalid if content doesn\'t meet minimum length when stripped of HTML tags' do
        card_content_validation.validator = '5'
        expect(card_content_validation.validate_answer(answer)).to eq false
      end

      it 'is valid if text content after HTML tags are stripped meets length requirement' do
        card_content_validation.validator = '4'
        expect(card_content_validation.validate_answer(answer)).to eq true
      end
    end

    context '#validate_by_string_length_maximum' do
      subject(:card_content_validation) do
        FactoryGirl.create(:card_content_validation, :with_string_length_maximum_validation)
      end
      let(:answer) { FactoryGirl.create(:answer, :with_task_owner, value: 'corgi') }
      let!(:card_content) { FactoryGirl.create(:card_content, answers: [answer], card_content_validations: [card_content_validation]) }

      it 'is invalid if validator string format is incorrect' do
        card_content_validation.validator = 'a string'
        expect(card_content_validation.validate_answer(answer)).to eq false
      end

      it 'is invalid if validator string is a negative number' do
        card_content_validation.validator = '-1'
        expect(card_content_validation.validate_answer(answer)).to eq false
      end

      it 'is invalid if answer length is greater than maximum required' do
        card_content_validation.validator = '5'
        answer.value = 'abcdefgh'
        expect(card_content_validation.validate_answer(answer)).to eq false
      end

      it 'is valid if answer length is less than maximum required' do
        card_content_validation.validator = '5'
        answer.value = 'abcd'
        expect(card_content_validation.validate_answer(answer)).to eq true
      end
    end

    context '#validate_html_by_length_maximum' do
      subject(:card_content_validation) do
        FactoryGirl.create(:card_content_validation, :with_string_length_maximum_validation)
      end
      let(:answer) { FactoryGirl.create(:answer, :with_task_owner, value: '<p>Test</p>') }
      let!(:card_content) { FactoryGirl.create(:card_content, answers: [answer], card_content_validations: [card_content_validation], value_type: 'html') }

      it 'is invalid if content exceeds maximum length when stripped of HTML tags' do
        card_content_validation.validator = '3'
        expect(card_content_validation.validate_answer(answer)).to eq false
      end

      it 'is valid if text content after HTML tags doesn\'t exceed length maximum' do
        card_content_validation.validator = '4'
        expect(card_content_validation.validate_answer(answer)).to eq true
      end
    end
  end
end
