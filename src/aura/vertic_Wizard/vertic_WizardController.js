({
    handleInit: function (cmp, event, helper) {

        var body = cmp.get('v.body');
        var wizardName = cmp.get('v.name');
        var steps = [];
        var navigationItemComponents = [];

        var firstStep;

        var options = {
            cmp: cmp,
            firstStep: firstStep,
            wizardName: wizardName,
            steps: steps,
            navigationItemComponents: navigationItemComponents
        };

        body.forEach(function (el, index) {
            if (el.toString().match(/aura:iteration/)) {
                var children = el.get('v.body');
                children.forEach(function (el) {
                    options.el = el;
                    helper.initStep(options);
                });
            } else {
                options.el = el;
                helper.initStep(options);
            }
        });

        cmp.set("v.navigationComponentsList", options.navigationItemComponents);

        cmp.set('v.steps', options.steps);

        var step = cmp.get('v.currentStep');
        if(step === undefined && options.firstStep !== undefined){
            step = options.firstStep.get('v.name');
            cmp.set('v.currentStep', step);
        }

        helper.setCurrentStep(cmp, step);
    },

    handleCurrentStepChange: function (cmp, event, helper) {

        var oldStep = event.getParam("oldValue");
        var newStep = event.getParam("value");

        helper.setCurrentStep(cmp, newStep, oldStep);
    },

    handleGetCurrentStep: function (cmp, event, helper) {
        return helper.getCurrentStep(cmp);
    },

    handleIsCurrentStepSaveRequired: function (cmp, event, helper) {
        return helper.isCurrentStepSaveRequired(cmp);
    },

    handleScrollTop: function (cmp, event, helper) {
        helper.scrollTop(cmp);
    },

    handleSetErrorsAndScrollTop: function (cmp, event, helper) {
        var errors = [];
        var params = event.getParam('arguments') || [];
        errors = params.errors || [];

        var currentStepCmp = helper.getCurrentStep(cmp);
        // currentStepCmp.set('v.errors', errors);

        var errorMessagesCmp = currentStepCmp.get('v.errorMessagesCmp')[0];
        errorMessagesCmp.showErrors(errors, true);
        errorMessagesCmp.set('v.title', params.title || cmp.get('v.errorsTitle') || 'Errors:');

        if (errors && errors.length) {
            helper.scrollTop(cmp);
        }
    },

    handleStepChange: function (cmp, event, helper) {
        helper.stepChange(cmp, event.getParams().payload);
    },

    handleStepSave: function (cmp, event, helper) {

        var isTheSameWizard = helper.isTheSameWizard(cmp, event.getParams().payload.wizardName);

        if(isTheSameWizard !== true){
            return;
        }

        var event = cmp.getEvent('onSave');
        event.setParams({
            payload: {
                eventPayload: event.getParams().payload,
                test: 1
            }
        });
        event.fire();
    },

    handleStepSubmit: function (cmp, event, helper) {

        var isTheSameWizard = helper.isTheSameWizard(cmp, event.getParams().payload.wizardName);

        if(isTheSameWizard !== true){
            return;
        }

        var event = cmp.getEvent('onSubmit');
        event.setParams({
            payload: event.getParams().payload
        });
        event.fire();
    },

    handleStepCancel: function (cmp, event, helper) {

        var isTheSameWizard = helper.isTheSameWizard(cmp, event.getParams().payload.wizardName);

        if(isTheSameWizard !== true){
            return;
        }

        var event = cmp.getEvent('onCancel');
        event.setParams({
            payload: event.getParams().payload
        });
        event.fire();
    },

    handleNext: function (cmp, event, helper) {
        helper.changeStepRelative(cmp, 'next');
    },

    handlePrevious: function (cmp, event, helper) {
        helper.changeStepRelative(cmp, 'previous');
    }
})