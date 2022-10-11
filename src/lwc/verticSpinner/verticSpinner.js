import {api, LightningElement} from 'lwc';

export default class verticSpinner extends LightningElement {
    @api isBusy;
    @api size = 'medium';
    @api variant = 'brand';
}