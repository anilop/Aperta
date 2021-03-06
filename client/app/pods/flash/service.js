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
import prepareResponseErrors from 'tahi/lib/validations/prepare-response-errors';

/**
  ## How to Use

  Anywhere in your template:

  ```
  {{flash-messages}}
  ```

  If you need a custom class wrapped around your messages:

  ```
  {{flash-messages classNames="custom-classes-here"}}
  ```

  ### In your Route or Controller from an Ember Data save:

  ```
  actions: {
    save() {
      this.get('model').save().then(
        function() {},
        (response)=> {
          this.flash.displayErrorMessagesFromResponse(response);
        }
      );
    }
  }
  ```

  To set a message manually from Controller or Route:

  ```
  this.flash.displayRouteLevelMessage('success', 'You win');
  ```

  The messages will be cleared out on the next route transition or overlay close.
  If you need to clear them out manually:

  ```
  this.flash.clearAllRouteLevelMessages();
  ```

  ## How it Works

  A service is created and injected into all Routes and Controllers
  from an Ember Initializer as the property `flash`.
  When `displayRouteLevelMessage` or `displayErrorMessagesFromResponse` is called, all
  we're doing is pushing to an array of messages that are displayed in the templates.
  The `flash` object is also injected into the `flash-messages` component.
*/

export default Ember.Service.extend({
  /**
   * Message queue for route level messages
   *
    @property routeLevelMessages
    @type Array
    @default []
  */
  routeLevelMessages: Ember.A(),
  /**
   * Message queue for system wide level message (persist after route transitions)
   *
   @property messages
   @type Array
   @default []
   */

  systemLevelMessages: Ember.A(window.flashMessages),
  /**
    Create a single route level message.

    ```
    this.flash.displayRouteLevelMessage('error', 'Oh noes');
    ```

    @method displayRouteLevelMessage
    @param {String} type    Used to generate final class. Example: `flash-message--success`
    @param {String} message Message displayed to user
  */

  displayRouteLevelMessage(type, message) {
    this.get('routeLevelMessages').pushObject({
      text: message,
      type: type
    });
  },
  /**
   Create a single system wide message.

   ```
   this.flash.displaySystemLevelMessage('error', 'kaboom!');
   ```

   @method displaySystemLevelMessage
   @param {String} type    Used to generate final class. Example: `flash-message--success`
   @param {String} message Message displayed to user
   */

  displaySystemLevelMessage(type, message) {
    this.get('systemLevelMessages').pushObject({
      text: message,
      type: type
    });
  },

  /**
    The array of messages for each key under `errors` will be joined into a single string, separated by comma.
    ```
    {
      errors: {
        name: ['is too short', 'is invalid']
      }
    }
    ```

    "Name is too short, is invalid"

    @method displayErrorMessagesFromResponse
    @param {Object} response Hash from Ember Data `save` failure. Expected to be in format Rails sends.
  */

  displayErrorMessagesFromResponse(response) {
    this.clearAllRouteLevelMessages();
    let errors = prepareResponseErrors(response.errors, ({includeNames: 'humanize'}));

    Object.keys(errors).forEach((key) => {
      let msg = errors[key];
      if(Ember.isPresent(msg)) { this.displayRouteLevelMessage('error', msg); }
    });
  },

  /**
    Remove Route Level flash message.

    @method removeRouteLevelMessage
    @param {Object} message to be removed
  */

  removeRouteLevelMessage(message) {
    this.get('routeLevelMessages').removeObject(message);
  },

  /**
   Remove System Level flash message.

   @method removeRouteLevelMessage
   @param {Object} message to be removed
   */

  removeSystemLevelMessage(message) {
    this.get('systemLevelMessages').removeObject(message);
  },

  /**
    Remove all flash messages in the application.
    Automatically called during route transitions and overlay close.
    ```
    this.flash.clearAllRouteLevelMessages();
    ```

    @method clearAllRouteLevelMessages
  */

  clearAllRouteLevelMessages() {
    this.set('routeLevelMessages', []);
  },

  clearAllSystemLevelMessages() {
    this.set('systemLevelMessages', []);
  }
});
