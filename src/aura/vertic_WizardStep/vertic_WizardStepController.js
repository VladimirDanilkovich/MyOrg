({
    handleNextClick: function (cmp, event, helper) {
        var isValidationEnabled = cmp.get('v.isValidationEnabled');
        helper.validate(cmp, 'form', isValidationEnabled).then(function () {
            helper.onNext(cmp).then(function () {
                helper.triggerStepChange(cmp, 'next');
            });
        });
    },

    handlePreviousClick: function (cmp, event, helper) {
        helper.onPrevious(cmp).then(function () {
            helper.triggerStepChange(cmp, 'previous');
        });
    },

    handleSaveClick: function (cmp, event, helper) {
        helper.clearErrors(cmp);
        var isValidateOnSaveEnabled = cmp.get('v.isValidateOnSaveEnabled');
        helper.validate(cmp, 'form', isValidateOnSaveEnabled).then(function () {
            helper.onSave(cmp).then(function (response) {
                var event = cmp.getEvent('onStepSave');
                event.setParams({
                    payload: {
                        wizardName: cmp.get('v.wizardName'),
                        errorMessagesCmp: cmp.get('v.errorMessagesCmp')[0],
                        step: cmp,
                        response: response
                    }
                });
                event.fire();
            });
        });
    },

    handleSubmitClick: function (cmp, event, helper) {
        var isValidationEnabled = cmp.get('v.isValidationEnabled');

        helper.validate(cmp, 'form', isValidationEnabled).then(function () {
            helper.onSubmit(cmp).then(function (response) {
                var event = cmp.getEvent('onStepSubmit');
                event.setParams({
                    payload: {
                        wizardName: cmp.get('v.wizardName'),
                        errorMessagesCmp: cmp.get('v.errorMessagesCmp')[0],
                        response: response
                    }
                });
                event.fire();
            });
        });
    },

    handleCancelClick: function (cmp, event, helper) {
        helper.onCancel(cmp).then(function () {
            var event = cmp.getEvent('onStepCancel');
            event.setParams({
                payload: {
                    wizardName: cmp.get('v.wizardName'),
                    errorMessagesCmp: cmp.get('v.errorMessagesCmp')[0]
                }
            });
            event.fire();
        });
    },

    handleVisibleChange: function (cmp, event, helper) {
        var hooks = cmp.get('v.hooks');
        if (hooks && hooks.onVisibleChange) {
            hooks.onVisibleChange(cmp);
        }
    }
})