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

import {
  moduleForComponent,
  test
} from 'ember-qunit';

import hbs from 'htmlbars-inline-precompile';

moduleForComponent('auto-suggest-list', 'Integration | Component | auto suggest list', {
  integration: true,

  beforeEach() {
    this.set('userQuery', null);
    this.set('selectedUserName', null);

    this.set('items', [
      { name: 'Bob Joe' },
      { name: 'Joe Bob' }
    ]);

    this.actions = {
      selectItem(user) {
        this.set('selectedUserName', user.name);
      }
    };
  }
});

test('it renders', function(assert) {
  assert.expect(2);

  let name = this.get('items.firstObject').name;

  this.render(hbs`
    <div id="auto-suggest-test">
      {{#auto-suggest-list items=items
                           positionNearSelector="#auto-suggest-test" as |user|}}
        {{user.name}}
      {{/auto-suggest-list}}
    </div>
  `);

  assert.equal(this.$('.auto-suggest').length, 1);
  assert.equal(
    this.$('.auto-suggest-item:first').text().trim(),
    name,
    'Block template is rendered'
  );
});
