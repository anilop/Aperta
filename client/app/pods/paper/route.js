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

import AuthorizedRoute from 'tahi/pods/authorized/route';
import PopoutParentRouteMixin from 'ember-popout/mixins/popout-parent-route';
import Ember from 'ember';

export default AuthorizedRoute.extend(PopoutParentRouteMixin,{
  channelName: null,
  popoutParams: { top: 10, left: 10, height: window.screen.height, width: 900 },
  pusher: Ember.inject.service(),
  feedbackService: Ember.inject.service('feedback'),

  model(params) {
    return this.store.query('paper', { shortDoi: params.paper_shortDoi })
    .then((results) => {
      return results.get('firstObject');
    });
  },

  afterModel(model) {
    this.get('feedbackService').setContext(model);
  },


/* eslint-disable camelcase */
  serialize(model) {
    return { paper_shortDoi: model.get('shortDoi') };
  },
/* eslint-emable camelcase */

  setupController(controller, model) {
    this._super(...arguments);
    this.setupPusher(model);
    model.get('commentLooks');

    let popout = this.get('popoutParent');
    $(window).on('beforeunload.popout', function(){
      if (Ember.isPresent(popout.get('popoutNames'))) {
        popout.closeAll();
      }
    });
  },

  redirect(model, transition) {
    if (!transition.intent.url) {
      return;
    }
    var url = transition.intent.url.replace(`/papers/${model.get('id')}`, `/papers/${model.get('shortDoi')}`);
    if (url !== transition.intent.url) {
      this.transitionTo(url);
    }
  },

  setupPusher(model) {
    let pusher = this.get('pusher');
    this.set('channelName', 'private-paper@' + model.get('id'));

    // This will bubble up to created and updated actions in the root
    // application route
    pusher.wire(this, this.channelName, ['created', 'updated', 'destroyed']);
  },

  deactivate() {
    this.get('pusher').unwire(this, this.get('channelName'));

    let popout = this.get('popoutParent');
    popout.closeAll();

    this.get('feedbackService').clearContext();
  },

  _pusherEventsId() {
    // needed for the `wire` and `unwire` method
    // to think we have `ember-pusher/bindings` mixed in
    return this.toString();
  },

  actions: {
    openDiscussionsPopout(options) {
      let paper = this.get('controller').model;
      let popout = this.get('popoutParent');
      if (options.discussionId === null) {
        popout.open(paper.id, options.path, paper.id, this.get('popoutParams'));
      } else {
        popout.open(paper.id, options.path, paper.id,
                    options.discussionId, this.get('popoutParams'));
      }
    },

    popInDiscussions(options) {
      let currentRoute = this.router.currentRouteName;
      let path = currentRoute.replace(/index$/, 'discussions.' + options.route);
      if (!options.discussionId) {
        this.transitionTo(path);
      } else {
        this.transitionTo(path, options.discussionId);
      }
    },

    showOrRaiseDiscussions(path){
      let paper = this.get('controller').model;
      let popout = this.get('popoutParent');

      if (Ember.isEmpty(popout.popoutNames)){
        this.transitionTo(path);
      } else {
        popout.popouts[paper.id].focus();
      }
    }
  }
});
