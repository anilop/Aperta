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
import ActiveModelAdapter from 'active-model-adapter';

const { getOwner } = Ember;

export default ActiveModelAdapter.extend({
  namespace: 'api',
  pusher: Ember.inject.service(),
  headers: Ember.computed('pusher.socketId', function() {
    let pusher = this.get('pusher');
    Ember.assert(`Can't find the pusher service.  Most likely you're seeing this error in a test environment, and
                 Ember is making an ajax request for a resource you haven't stubbed, like a permissions check for a task.
                 ----
                 If you were NOT planning on making an ajax request (to mockjax or whatever):
                   If you go up the stack trace to the restAdapter (rest.js) you can see the url for the request.  If you're trying
                   to fetch a permission, you can either stub the request itself, or ideally you can use the FakeCanService to prevent
                   the request from ever going out in the first place.  See \`test/helpers/fake-can-service.js\`
                 ----
                 If you WERE planning on making a request to mockjax:
                   You're probably in a component integration test and you've forgotten
                   to use register a stub for the pusher service.  You can do that like this in the beforeEach hook:
                   this.registry.register('service:pusher', Ember.Object.extend({socketId: 'foo'}));
                 `, pusher);
    if (pusher.get('socketId')) {
      return {
        namespace: 'api',
        // Weird capitalization and hyphens are intentional since this is is an
        // HTTP header name. Whatever you do, DO NOT add underscores to the header
        // name because nginx will start to ignore it.
        'Pusher-Socket-ID': pusher.get('socketId')
      };
    } else {
      return {namespace: 'api'};
    }
  }),

  handleResponse(status) {
    if ( status === 401 ) {  return document.location.href = '/users/sign_in';  }
    return this._super(...arguments);
  },

  ajaxError: function(event, jqXHR, ajaxSettings, thrownError) {
    const status = jqXHR.status;

    // don't blow up in case of a 403 from rails
    if (status === 403 || event.status === 403) { return; }

    return this._super(...arguments);
  },

  // buildURLForModel is a custom hook added by Aperta. It's so the URL
  // for a given model/instance can be generated and overriden. See
  // adapters/paper.js for an example.
  buildURLForModel(model){
    let id = model ? Ember.get(model, 'id') : null;
    let type = model.constructor.modelName
    return this.buildURL(type, id);
  },

  // These hooks are described in the ember data 1.13 release post
  // http://emberjs.com/blog/2015/06/18/ember-data-1-13-released.html#toc_new-adapter-hooks-for-better-caching

  shouldReloadRecord () {
    return false;
  },

  // defaults to true in ember-data 2.0,
  // TODO: investigate returning `true` as part of #2466
  shouldBackgroundReloadRecord() {
    return false;
  },

  // pre-2.0 behavior is to reload records on a `findAll` call
  shouldReloadAll () {
    return true;
  },

  // defaults to true in ember-data 2.0,
  // TODO: investigate returning `true` as part of #2466
  shouldBackgroundReloadAll() {
    return false;
  }
});
