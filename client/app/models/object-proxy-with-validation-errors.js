import Ember from 'ember';
import ValidationErrorsMixin from 'tahi/mixins/validation-errors';

export default Ember.Object.extend(ValidationErrorsMixin, {
  errorsPresent: false,

  validations: null,

  init() {
    this._super(...arguments);

    Ember.assert(
      'an `object` must be set for ObjectProxyWithValidationErrors',
      !Ember.isEmpty(this.get('object'))
    );

    Ember.assert(
      'validations must be defined for ObjectProxyWithValidationErrors',
      !Ember.isEmpty(this.get('validations'))
    );
  },

  validateAllKeys() {
    this.set('validationErrors.save', '');

    _.keys(this.get('validations')).forEach((key) => {
      this.validateKey(key);
    });

    const errorsPresent = this.validationErrorsPresent();

    this.set('errorsPresent', errorsPresent);

    if(errorsPresent) {
      this.set('validationErrors.save', 'Please fix the errors above');
    }
  },

  validateKey(key) {
    this.validate(
      key,
      this.get(`object.${key}`),
      this.get(`validations.${key}`)
    );

    if(this.validationErrorsPresentForKey(key)) {
      this.set('errorsPresent', true);
    }
  }
});