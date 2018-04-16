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

import ApplicationSerializer from 'tahi/pods/application/serializer';

export default ApplicationSerializer.extend({

  // TODO: Card Thumbnail is an ember model that doesn't exist on the server
  // side. Due to the implementation of flow manager, in order to display
  // comment-looks, we need to associate our comment look to the card
  // thumbnail. Ideally, card thumbnail could go away, and instead we
  // could just provide a sparse view of the task itself. At that point,
  // this code would be unnecessary.
  //
  normalize(typeClass, hash, prop) {
    hash.card_thumbnail_id = hash.task.id;
    return this._super(typeClass, hash, prop);
  }

});
