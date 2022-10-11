({
    initStep: function(options){
        if(!options.firstStep && options.el.get('v.isAccessible') === true){
            options.firstStep = options.el;
        }
        options.el.name = options.el.get('v.name');
        options.el.set('v.wizardName', options.wizardName);
        options.el.set('v.class', options.cmp.get('v.stepClass'));
        options.el.set('v.navItemClass', options.cmp.get('v.navItemClass'));
        options.el.set('v.navItemActiveClass', options.cmp.get('v.navItemActiveClass'));
        options.el.set('v.previousBtnClass', options.el.get('v.previousBtnClass') + ' ' + options.cmp.get('v.previousBtnClass'));
        options.el.set('v.nextBtnClass', options.el.get('v.nextBtnClass') + ' ' + options.cmp.get('v.nextBtnClass'));
        options.el.set('v.saveBtnClass', options.el.get('v.saveBtnClass') + ' ' + options.cmp.get('v.saveBtnClass'));
        options.el.set('v.submitBtnClass', options.el.get('v.submitBtnClass') + ' ' + options.cmp.get('v.submitBtnClass'));
        options.el.set('v.validateOptions', options.el.get('v.validateOptions') || options.cmp.get('v.validateOptions'));
        if(!options.el.get('v.errorsTitle')){
            options.el.set('v.errorsTitle', options.cmp.get('v.errorsTitle'));
        }

        options.steps.push(options.el);

        var navItemCmp = options.el.get('v.navigationItemCmp');
        if(navItemCmp){
            // if($A.util.isArray(navItemCmp)){
            //     navItemCmp.forEach(function (navItem) {
            //         navItem.set('v.class', cmp.get('v.navItemClass'));
            //     })
            // } else {
            //     navItemCmp.set('v.class', cmp.get('v.navItemClass'));
            // }
            options.navigationItemComponents.push(options.el.get('v.navigationItemCmp'));
        }
    },

    setCurrentStep: function (cmp, newStepName, oldStepName) {

        var steps = cmp.get('v.steps');
        steps.forEach(function (step) {
            var stepName = step.get('v.name');
            if (stepName == newStepName) {
                step.set('v.isVisible', true);
            } else {
                step.set('v.isVisible', false);
            }
        })

        this.scrollTop(cmp);


        // if(!oldStepName){
        // 	oldStepName = newStepName;
        // }
        //
        // var stepsMap = cmp.get('v.stepsMap');
        // var oldStepCmp = stepsMap[oldStepName];
        // var newStepCmp = stepsMap[newStepName];
        //
        // if(oldStepCmp){
        // 	oldStepCmp.set('v.isVisible', false);
        // }
        //
        // debugger
        //
        // newStepCmp.set('v.isVisible', true);

        // var currentStepCmp = cmp.get('v.currentStepCmp');
        // if(currentStepCmp){
        // 	debugger
        // 	stepsMap[oldStepName] = currentStepCmp;
        // }
        //
        // cmp.set('v.currentStepCmp', stepCmp);
        // cmp.set('v.stepsMap', stepsMap);

    },

    getCurrentStep: function (cmp) {
        var currentStepCmp;
        var currentStepName = cmp.get('v.currentStep');
        var steps = cmp.get('v.steps');

        steps.forEach(function (step) {
            var stepName = step.get('v.name');
            if (stepName == currentStepName) {
                currentStepCmp = step;
            }
        });

        return currentStepCmp;
    },

    isCurrentStepSaveRequired: function (cmp) {
        var currentStepCmp = this.getCurrentStep(cmp);
        return currentStepCmp.get('v.isSaveRequired');
    },

    scrollTop: function (cmp) {
        var scroller = cmp.find('wizard-container');
        if (scroller && scroller.getElement()) {
            scroller.getElement().scrollIntoView();
        }
    },

    isTheSameWizard: function(cmp, wizardName){
        return wizardName === cmp.get('v.name');
    },

    stepChange: function (cmp, payload) {

        var isTheSameWizard = this.isTheSameWizard(cmp, payload.wizardName);

        if(isTheSameWizard !== true){
            return;
        }

        var relativeStep = payload.relativeStep;
        if(relativeStep !== undefined){
            this.changeStepRelative(cmp, relativeStep);
        }
    },

    changeStepRelative: function (cmp, relativeStep) {
        var currentStepName = cmp.get('v.currentStep');
        var steps = cmp.get('v.steps');

        var currentStepIndex = -1;
        var previousStepIndex = -1;
        var nextStepIndex = -1;
        steps.forEach(function (step, index) {
            var stepName = step.get('v.name');
            if (stepName == currentStepName) {
                currentStepIndex = index;
            }

            var isAccessible = step.get('v.isAccessible');

            if(isAccessible === true){
                if(currentStepIndex == -1){
                    previousStepIndex = index
                } else if(nextStepIndex == -1 && currentStepIndex < index){
                    nextStepIndex = index;
                }
            }
        });

        if(currentStepIndex != -1){
            var newCurrentStepIndex = relativeStep === 'next' ?
                nextStepIndex :
                relativeStep === 'previous' ?
                    previousStepIndex :
                    currentStepIndex;

            // debugger

            if(newCurrentStepIndex != currentStepIndex && newCurrentStepIndex >= 0 && newCurrentStepIndex < steps.length){
                cmp.set('v.currentStep', steps[newCurrentStepIndex].get('v.name'));
                // steps[currentStepIndex].set('v.isVisible', false);
                // steps[newCurrentStepIndex].set('v.isVisible', true);

            }
        }
    }
})