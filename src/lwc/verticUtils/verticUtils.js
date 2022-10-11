import executeApex from '@salesforce/apex/vertic_CommonCtrl.execute';
import {ShowToastEvent} from 'lightning/platformShowToastEvent';

const showToast = (page, title, message, type) => {
    const toastEvt = new ShowToastEvent({
        title: title,
        message: message,
        variant: type
    });
    page.dispatchEvent(toastEvt);
};

const execute = (processor, request) => {
    return new Promise((resolve, reject) => {

        console.log(processor, 'REQUEST', request);

        executeApex({
            processor: processor,
            requestJSON: JSON.stringify(request)
        }).then(responseJSON => {
            const response = JSON.parse(responseJSON);
            console.log(processor, 'RESPONSE', response);
            if (response.isValid !== true) {
                reject(response.errors);
            } else {
                resolve(response);
            }
        }).catch(errors => {
            reject(errors);
        });
    });
};

const validateComponents = (components) => {
    var validationResult = {
        errorsByInputs: [],
        allValid: true,
        getErrorMessages: function () {
            var errors = [];
            this.errorsByInputs.forEach(function (errorsByInput) {
                errors.push(errorsByInput.errors.join(','));
            })

            return errors;
        }
    };

    components.forEach(function (inputCmp) {

        var validationErrors = [
            'badInput',
            'customError',
            'patternMismatch',
            'rangeOverflow',
            'rangeUnderflow',
            'stepMismatch',
            'tooLong',
            'tooShort',
            'typeMismatch',
            'valueMissing'
        ];

        var defaultErrorMessages = {
            badInput: 'Enter a valid value.',
            patternMismatch: 'Your entry does not match the allowed pattern.',
            rangeOverflow: 'The number is too high.',
            rangeUnderflow: 'The number is too low.',
            stepMismatch: 'Your entry isn\'t a valid increment.',
            tooLong: 'Your entry is too long.',
            tooShort: 'Your entry is too short.',
            typeMismatch: 'You have entered an invalid format.',
            valueMissing: 'Complete this field.'
        };


        let capitalizeFirstLetter = function (string) {
            return string.charAt(0).toUpperCase() + string.slice(1);
        }

        if (inputCmp) {

            if (inputCmp.validity == undefined) {
                if (inputCmp.validate != undefined && !inputCmp.validate()) {
                    validationResult.errorsByInputs.push({
                        inputCmp: inputCmp,
                        errors: inputCmp.errorMessages
                    });

                }
                //
                // var hasShowErrorMethod = inputCmp.get('c.showError') != undefined;
                // var hasHideErrorMethod = inputCmp.get('c.hideError') != undefined;
                // if(hasShowErrorMethod == true){
                //
                //     var isRequired = inputCmp.get('v.required');
                //     var isEmptyValue = $A.util.isEmpty(inputCmp.get('v.value'));
                //
                //     if (isRequired && isEmptyValue){
                //
                //         inputCmp.showError('Complete this field.');
                //
                //         validationResult.errorsByInputs.push({
                //             inputCmp: inputCmp,
                //             errors: [
                //                 inputCmp.get('v.label') + ': Complete this field.'
                //             ]
                //         });
                //
                //         validationResult.allValid = false;
                //     } else if (hasHideErrorMethod == true) {
                //         inputCmp.hideError();
                //     }
                // }

            } else if (inputCmp.validity && inputCmp.validity.valid === false) {

                var errors = [];
                validationErrors.forEach(function (validationError) {
                    if (inputCmp.validity[validationError] === true) {
                        let errorMessageField = 'message-when-' + capitalizeFirstLetter(validationError);
                        let errorMessage = inputCmp[errorMessageField];
                        errorMessage = errorMessage || defaultErrorMessages[validationError];
                        if (errorMessage) {
                            errors.push(inputCmp.label + ': ' + errorMessage);
                        } else {
                            errors.push(inputCmp.label + ': ' + (
                                (!inputCmp.value ? inputCmp['message-when-value-missing']  : inputCmp['message-when-bad-input']) || inputCmp.label)
                            );
                        }
                    }
                })

                validationResult.errorsByInputs.push({
                    inputCmp: inputCmp,
                    errors: errors
                });

                validationResult.allValid = false;

                if (inputCmp.reportValidity != undefined) {
                    inputCmp.reportValidity();
                }

            }

        }
    })

    return validationResult;
}

const validate = (containerComponent, options) => {
    options = options || {}
    options.additionalComponentTypes = options.additionalComponentTypes || [];

    var componentTypes = [
        'lightning-input',
        'lightning-input-address',
        'lightning-input-field',
        'lightning-input-location',
        'lightning-input-name',
        'lightning-input-rich-text',
        'lightning-textarea',
        'lightning-select',
        'lightning-combobox',
        'lightning-radio-group',
        'lightning-checkbox-group',
        'c-vertic-multi-select',
        'c-vertic-counter'
    ];

    componentTypes = componentTypes.concat(options.additionalComponentTypes);

    return validateComponents([...containerComponent.querySelectorAll(componentTypes.join(', '))]);
};

const flatten = (data) => {
    let result = {};

    function recurse(cur, prop) {
        if (Object(cur) !== cur) {
            result[prop] = cur;
        } else if (Array.isArray(cur)) {
            for (let i = 0, l = cur.length; i < l; i++) {
                recurse(cur[i], prop + "[" + i + "]");
                if (l === 0) {
                    result[prop] = [];
                }
            }
        } else {
            let isEmpty = true;
            for (let p in cur) {
                isEmpty = false;
                recurse(cur[p], prop ? prop + "." + p : p);
            }
            if (isEmpty && prop)
                result[prop] = {};
        }
    }

    recurse(data, "");
    return result;
}

const chunk = (array, n) => {
    if (!array.length) {
        return [];
    }
    return [array.slice(0, n)].concat(this.chunk(array.slice(n), n));
}

const getURlParams = () => {
    return decodeURI(location.search)
        .replace('?', '')
        .split('&')
        .map(function (param) {
            return param.split('=');
        })
        .reduce(function (values, item) {
            let key = item[0];
            let value = item[1];
            values[key ? key.toLowerCase() : key] = value;
            return values
        }, {});
}

export {
    showToast,
    execute,
    validate,
    flatten,
    chunk,
    getURlParams
}