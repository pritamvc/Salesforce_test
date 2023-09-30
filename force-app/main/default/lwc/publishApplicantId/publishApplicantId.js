import { LightningElement,api,wire } from 'lwc';
import { publish, MessageContext } from 'lightning/messageService';
import ABC from '@salesforce/messageChannel/picklistwizeDocument__c';
export default class PublishApplicantId extends LightningElement {
     //wire method used for messageChannel 
     @wire(MessageContext)
     messageContext;
    @api inputevalue;
    connectedCallback() {
        // This code will run when the component is connected to the DOM
        this.handleLoad(); // You can call your handling function here
    }
    handleLoad() {
        // Your onload logic goes here
        console.log('The applicant id is ',this.inputevalue);
        publish(this.messageContext, ABC , {
            applicantId: this.inputevalue
        });
       //publish(this.messageContext, applicantIdNew, this.inputevalue);
    }
}