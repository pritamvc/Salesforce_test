import { LightningElement,api,wire,track } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

export default class ToastFlow extends LightningElement{
    @api mode;
    @api variant;    
    @api message;    

    connectedCallback() {
        this.showToast();   
    }

    showToast(event) {
        const toastEvt = new ShowToastEvent({
            title:"Raise Query",
            mode: this.mode,
            variant: this.variant,            
            message: this.message
        });
        this.dispatchEvent(toastEvt);
    }
}