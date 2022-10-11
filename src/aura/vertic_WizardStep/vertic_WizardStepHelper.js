({
    validate: function (cmp, formId, isValidationEnabled) {

        var helper = this;

        return new Promise($A.getCallback(function (resolve, reject) {

            helper.clearErrors(cmp);

            if(isValidationEnabled !== true){
                return resolve();
            }

            var formContainer = cmp.find(formId);
            if(formContainer === undefined){
                reject('No Form with aura:id: ' + formId);
                throw 'No Form with aura:id: ' + formId;
            }

            var validationResult = cmp.utils.validate(formContainer, cmp.get('v.validateOptions') || {});

            if(validationResult.allValid !== true){
                helper.showErrors(cmp, validationResult.getErrorMessages());
                return reject(validationResult);
            }

            var hooks = cmp.get('v.hooks');
            if(hooks && hooks.validate){
                return hooks.validate(cmp).then(resolve, function (errors) {
                    if(errors){
                        helper.showErrors(cmp, errors);
                    }
                    return reject(errors);
                });
            } else {
                return resolve();
            }

        }));


    },

    clearErrors: function(cmp){
        var errorMessagesCmp = cmp.get('v.errorMessagesCmp')[0];
        errorMessagesCmp.clearErrors();
    },

    showErrors: function(cmp, errors){
        var showErrorsSummary = cmp.get('v.showErrorsSummary');
        var errorMessagesCmp = cmp.get('v.errorMessagesCmp')[0];

        if(cmp.get('v.errorsTitle')){
            errorMessagesCmp.set('v.title', cmp.get('v.errorsTitle'));
        }
        errorMessagesCmp.showErrors(errors, showErrorsSummary != false);

    },

    onNext: function(cmp){
        return new Promise($A.getCallback(function (resolve, reject) {
            var hooks = cmp.get('v.hooks');
            if (hooks && hooks.onNext) {
                return hooks.onNext(cmp).then(resolve, reject);
            } else {
                return resolve();
            }
        }));
    },

    onPrevious: function(cmp){
        return new Promise($A.getCallback(function (resolve, reject) {
            var hooks = cmp.get('v.hooks');
            if (hooks && hooks.onPrevious) {
                return hooks.onPrevious(cmp).then(resolve, reject);
            } else {
                return resolve();
            }
        }));
    },

    onSave: function(cmp){
        return new Promise($A.getCallback(function (resolve, reject) {
            var hooks = cmp.get('v.hooks');
            if (hooks && hooks.onSave) {
                return hooks.onSave(cmp).then(resolve, reject);
            } else {
                return resolve();
            }
        }));
    },

    onSubmit: function(cmp){
        return new Promise($A.getCallback(function (resolve, reject) {
            var hooks = cmp.get('v.hooks');
            if (hooks && hooks.onSubmit) {
                return hooks.onSubmit(cmp).then(resolve, reject);
            } else {
                return resolve();
            }
        }));
    },

    onCancel: function(cmp){
        return new Promise($A.getCallback(function (resolve, reject) {
            var hooks = cmp.get('v.hooks');
            if (hooks && hooks.onCancel) {
                return hooks.onCancel(cmp).then(resolve, reject);
            } else {
                return resolve();
            }
        }));
    },

    triggerStepChange: function (cmp, relativeStep) {
        var event = cmp.getEvent('onStepChange');
        event.setParams({
            payload: {
                wizardName: cmp.get('v.wizardName'),
                relativeStep: relativeStep
            }
        });
        event.fire();
    }
})