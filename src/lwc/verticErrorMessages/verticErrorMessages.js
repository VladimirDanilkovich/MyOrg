import {api, LightningElement} from 'lwc';

export default class verticErrorMessages extends LightningElement {
    @api title = 'Errors:';
    @api errors;
}