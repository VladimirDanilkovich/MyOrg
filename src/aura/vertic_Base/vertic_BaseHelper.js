({
    utils: function(cmp){
        return this.getBaseCmp(cmp).utils;
    },

    getBaseCmp: function(cmp, type){
        var base = cmp;
        type = type || 'c:vertic_Base';
        while(base.getType() != type){
            base = base.getSuper();
        }
        return base;
    },

    execute: function (cmp, processor, request, success, fail) {

        var that = this;

        cmp.set('v.isBusy', true);

        return this.getBaseCmp(cmp).utils.execute(
            cmp,
            processor,
            request,
            function(response){
                cmp.set('v.isBusy', false);
                if(success){
                    success(response);
                }
            },
            function(errors){
                cmp.set('v.isBusy', false);
                if(fail){
                    fail(errors);
                } else {
                    that.getBaseCmp(cmp).find('errorMessages').showErrors(errors, true);
                }
            }
        );

    },

    validateForm: function (cmp, formId, options) {
        options = options || {}
        options.isScrollTop = options.isScrollTop !== false;

        var formContainer = cmp.find(formId);

        if(formContainer === undefined){
            throw 'No Form with aura:id: ' + formId;
        }

        var errorMessagesCmp = this.getBaseCmp(cmp).find('errorMessages');

        errorMessagesCmp.clearErrors();

        var validationResult = this.getBaseCmp(cmp).utils.validate(formContainer, options);
        if(validationResult.allValid !== true){
            errorMessagesCmp.showErrors(validationResult.getErrorMessages(), options.isScrollTop);
            return false;
        }

        return true;
    },

    doInit: function (cmp, processor, payload) {

        var helper = this;

        return new Promise($A.getCallback(function(resolve, reject) {
            if(payload.recordId === undefined){
                payload.recordId = cmp.get('v.recordId');
            }

            helper.execute(
                cmp,
                processor,
                payload,
                function (response) {
                    cmp.set('v.meta', response);
                    helper.getBaseCmp(cmp).find('errorMessages').clearErrors();
                    resolve(response);
                }, function (errors) {
                    helper.getBaseCmp(cmp).find('errorMessages').showErrors(errors, true);
                    reject(errors);
                }
            );
        }));
    }

})