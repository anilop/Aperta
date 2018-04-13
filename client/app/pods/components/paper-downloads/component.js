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

import Ember from 'ember';
import { task } from 'ember-concurrency';
import { PropTypes } from 'ember-prop-types';

export default Ember.Component.extend({
  classNames: [
    'paper-downloads-component',
    'sheet',
    'sheet--visible'
  ],

  propTypes: {
    // actions:
    toggle: PropTypes.func.isRequired
  },

  init() {
    this._super(...arguments);
  },

  pdfDownloadLink: Ember.computed('paperid', function() {
    return '/papers/' + this.get('paper.id') + '/download.pdf';
  }),

  versions: [],

  fetchVersions: task(function * () {
    const versions = yield this.get('paper.versionedTexts');
    this.set('versions', versions);
  }),

  actions: {
    toggle() {
      this.get('toggle')();
    }
  }
});
