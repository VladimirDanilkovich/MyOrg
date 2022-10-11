import {api, LightningElement, wire} from 'lwc';
import {chunk, execute, flatten, getURlParams, showToast, validate} from 'c/verticUtils'
import {CurrentPageReference} from 'lightning/navigation';

export default class BaseElement extends LightningElement {

    /**
     * ==============================================================================================================
     *                                             BASE IMPLEMENTATION
     * ==============================================================================================================
     */

        // Public attributes
    @api recordId;
    @api processor;
    @api meta;
    @api isBusy = false;
    @api errorMessages;
    @api trueValue = !false;
    @api falseValue = false;

    // Private attributes
    currentPageReference;

    connectedCallback() {
        this.recordId = this.recordId || this.currentPageReference.state.recordId || this.currentPageReference.state.Id || this.currentPageReference.state.c__recordId || this.currentPageReference.state.c__Id;
        if (this.processor) {
            this.doInit().catch(errors => {
                this.clearErrors();
                showToast(this, 'Error', Array.isArray(errors) ? errors[0].message : errors.message || errors.body.message, 'error');
            });
        }
    }
    

    handleInit(event) {
        this.meta = JSON.parse(JSON.stringify(event.detail.meta));
        if (this.stepsCmp) {
            this.stepsCmp.meta = JSON.parse(JSON.stringify(this.meta));
        }
    }

    @wire(CurrentPageReference)
    getStateParameters(currentPageReference) {
        if (currentPageReference) {
            this.currentPageReference = currentPageReference;
        }
    }

    scrollTop() {
        let scroller = this.template.querySelector('[data-id="container"]');
        if (scroller) {
            setTimeout(function () {
                scroller.scrollIntoView();
            })
        }
    }

    @api
    clearErrors() {
        this.errorMessages = null;
    }

    showErrors(errors, isScrollTop) {
        this.errorMessages = errors || [];
        if (isScrollTop === true) {
            this.scrollTop();
        }
    }

    execute(processor, request) {
        this.isBusy = true;
        return execute(
            processor,
            request
        ).then((meta) => {
            this.isBusy = false;
            return meta;
        }).catch((errors) => {
            this.isBusy = false;
            this.errorMessages = errors;
            throw errors;
        });
    }

    @api
    doInit(request, processor) {
        return new Promise((resolve, reject) => {
            if (processor || this.processor) {
                request = request || {};
                if (this.recordId) {
                    request.recordId = this.recordId;
                }
                this.execute(
                    processor || this.processor,
                    request
                ).then((meta) => {
                    this.meta = meta;
                    this.dispatchEvent(new CustomEvent('init', {
                        bubbles: false,
                        composed: false,
                        detail: {
                            meta: JSON.parse(JSON.stringify(this.meta))
                        }
                    }));
                    resolve(meta);
                }).catch((errors) => {
                    this.errorMessages = errors;
                    reject(errors);
                });
            } else {
                this.meta = {
                    dto: {},
                    selectOptions: {},
                    dependentOptions: {}
                };
            }
        });
    }

    @api
    validate(formId, options) {
        formId = formId || 'container';
        options = options || {};
        options.isScrollTop = options.isScrollTop !== false;

        let formContainer = this.template.querySelector(`[data-id="${formId}"]`);
        if (Array.isArray(formContainer)) formContainer = formContainer[0];

        if (formContainer == null) {
            throw 'No Form with data-id: ' + formId;
        }

        this.clearErrors();

        let validationResult = validate(formContainer, options);
        if (validationResult.allValid !== true) {
            this.showErrors(validationResult.getErrorMessages(), options.isScrollTop);
            return false;
        }

        return true;
    }

    setMapValue(map, path, value) {
        if (!path || path.length === 0) {
            return value;
        }
        if (!Array.isArray(path)) {
            path = path.split('.');
        }
        let key = path[0];
        if (key.startsWith('[') && key.endsWith(']')) {
            key = parseInt(key.substring(0, key.length - 1).substring(1));
        }
        map[key] = map[key] || {};

        path.splice(0, 1);
        map[key] = this.setMapValue(map[key], path, value);

        return map;
    }

    handleFieldChange(event) {
        event.preventDefault();
        event.stopPropagation();

        let index = event.target.getAttribute('data-index');
        let path = event.target.getAttribute('data-path');
        path = path.replaceAll('[data-index]', '[' + index + ']');
        this.meta.dto = this.setMapValue(this.meta.dto, path, event.target.selectedValues || event.target.value || event.detail.value);
        let dependentOptionsAttribute = event.target.getAttribute('data-dependent-options');
        if (dependentOptionsAttribute) {
            let controllingFieldValue = event.target.value;
            let dependentOptions = this.meta.dependentOptions[dependentOptionsAttribute];
            this.meta.selectOptions[dependentOptionsAttribute] = dependentOptions[controllingFieldValue];
        }
        this.meta = this.meta;
    }

    get baseCmp() {
        return this.template.querySelector('c-vertic-base');
    }


    /**
     * ==============================================================================================================
     *                                             MODAL IMPLEMENTATION
     * ==============================================================================================================
     */

    @api modal = false;
    @api modalOpen = false;
    @api modalHeader;
    @api modalSubtitle;
    @api modalHeadless = false;
    @api modalFootless = false;
    @api modalSize;
    @api doNotCloseOnCancel = false;
    @api cancelButtonHidden = false;
    @api cancelButtonDisabled = false;
    @api saveButtonHidden = false;
    @api saveButtonDisabled = false;
    @api cancelButtonLabel = 'Cancel';
    @api saveButtonLabel = 'Save';

    @api
    open() {
        this.modalOpen = true;
        this.dispatchEvent(new CustomEvent('open', {
            bubbles: false,
            composed: false
        }));
    }

    handleOpen(event) {
        this.open();
    }

    @api
    close() {
        this.modalOpen = false;
        this.dispatchEvent(new CustomEvent('close', {
            bubbles: false,
            composed: false
        }));
    }

    handleClose(event) {
        this.close();
    }

    // Method that triggers an event to a Modal Implementation component
    cancel() {
        if (this.doNotCloseOnCancel !== true) {
            this.close();
        }
        this.dispatchEvent(new CustomEvent('cancel', {
            bubbles: false,
            composed: false
        }));
    }

    // The base implementation of the Cancel Event Handler that just throws the event (from the above method) further up
    handleCancel(event) {
        this.dispatchEvent(new CustomEvent('cancel', {
            bubbles: false,
            composed: false,
            detail: {
                meta: JSON.parse(JSON.stringify(this.meta))
            }
        }));
    }

    // Method that triggers an event to a Modal Implementation component
    submit() {
        this.dispatchEvent(new CustomEvent('submit', {
            bubbles: false,
            composed: false
        }));
    }

    // The base implementation of the Submit Event Handler that just throws the event (from the above method) further up
    handleSubmit(event) {
        this.dispatchEvent(new CustomEvent('submit', {
            bubbles: false,
            composed: false,
            detail: {
                meta: JSON.parse(JSON.stringify(this.meta))
            }
        }));
    }

    get modalClasses() {
        return 'slds-modal slds-fade-in-open' + (this.modalSize ? ' slds-modal_' + this.modalSize : '');
    }

    get isModalActive() {
        return this.modal === true && this.modalOpen === true;
    }


    /**
     * ==============================================================================================================
     *                                             STEPPER IMPLEMENTATION
     * ==============================================================================================================
     */

    handleNext(event) {
        if (this.stepsCmp.validate()) {
            this.stepperCmp.renderNextStep();
        }
    }

    handlePrevious(event) {
        this.stepperCmp.renderPreviousStep();
    }

    handleStepChanged(event) {
        this.stepsCmp.renderStepContent(event.detail.currentStep);
    }

    @api
    get stepsCmp() {
        if (this.stepperCmp && this.stepperCmp.isProgressIndicatorVertical) {
            let steps = this.template.querySelectorAll('[data-steps]');
            return steps && steps.length > this.stepperCmp.currentStepIndex ? steps[this.stepperCmp.currentStepIndex] : steps[0];
        }
        return this.template.querySelector('[data-steps]');
    }

    @api
    get stepperCmp() {
        return this.template.querySelector('c-vertic-stepper');
    }

    /**
     * ==============================================================================================================
     */
}

export {BaseElement, showToast, execute, validate, flatten, chunk, getURlParams}