/**
 * Copyright (c) 2018 Public Library of Science
 *
 * Permission is hereby granted, free of charge, to any person obtaining a
 * copy of this software and associated documentation files (the "Software"),
 * to deal in the Software without restriction, including without limitation
 * the rights to use, copy, modify, merge, publish, distribute, sublicense,
 * and/or sell copies of the Software, and to permit persons to whom the
 * Software is furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL
 * THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
 * FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER
 * DEALINGS IN THE SOFTWARE.
*/

import { moduleForComponent, test } from 'ember-qunit';
import hbs from 'htmlbars-inline-precompile';
import { clickTrigger, nativeMouseUp } from 'tahi/tests/helpers/ember-power-select';
import Ember from 'ember';

moduleForComponent(
  'card-content/dropdown',
  'Integration | Component | card content | dropdown',
  {
    integration: true,
    beforeEach() {
      this.set('actionStub', function() {});
      this.set('repetition', null);
      this.set('owner', Ember.Object.create());
      this.set('answer', Ember.Object.create());
      this.defaultContent = Ember.Object.create({
        text: `Foo`,
        possibleValues: [{ label: 'Choice 1', value: 1 }, { label: 'Choice 2', value: 2}]
      });
    }
  }
);

let template = hbs`
{{card-content/dropdown
  answer=answer
  content=content
  owner=owner
  disabled=disabled
  repetition=repetition
  valueChanged=(action actionStub)}}`;

test(`it renders a dropdown option for each of the possibleValues`, function(assert) {
  this.set('content', this.defaultContent);
  this.render(template);
  clickTrigger();
  assert.textPresent('.ember-power-select-dropdown', 'Choice 1');
  assert.textPresent('.ember-power-select-dropdown', 'Choice 2');
});
test(`it disables the inputs if disabled=true`, function(assert) {
  this.set('disabled', true);
  this.set('content', this.defaultContent);
  this.render(template);
  assert.elementFound(this.$('.ember-power-select-trigger[aria-disabled]'));
});
test(`its initial selection corresponds to the answer's value`, function(assert) {
  this.set('answer', Ember.Object.create({ value: 2}));
  this.set('content', this.defaultContent);
  this.render(template);
  assert.textPresent('.ember-power-select-selected-item', 'Choice 2');
});
test(`it sends 'valueChanged' when a new option is picked`, function(assert) {
  assert.expect(1);
  this.set('answer', Ember.Object.create({ value: null}));
  this.set('content', this.defaultContent);
  this.set('actionStub', function(newVal) {
    assert.equal(newVal, 2, 'it calls the action with the new value');
  });
  this.render(template);
  clickTrigger();
  nativeMouseUp(`.ember-power-select-option[data-option-index="1"]`);
});
