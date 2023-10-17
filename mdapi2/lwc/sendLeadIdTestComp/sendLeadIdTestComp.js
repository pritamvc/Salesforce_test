import { LightningElement, api, track, wire } from 'lwc';
import getleadDetails from '@salesforce/apex/GetLeadIdHandler.getLeadDetails';
import updateLead from '@salesforce/apex/GetLeadIdHandler.updateLead';

export default class SendLeadIdTestComp extends LightningElement {
    @api recordId;
    @track LeadName;
    @track leadId;
    @track firstName;
    
    @track email;

    @wire(getleadDetails, {
        recordId: "$recordId"
    })
    wiredGetDetails(result) {
        this.wiredLeadResults = result;
        if (result.data) {
            this.data = result.data;
            this.LeadName = this.data.Name;
            this.leadId = this.data.Id;
            console.log('this.data ' + JSON.stringify(this.data));
        }
        else if (result.error) {
            this.error = result.error;
            console.log('this.error ' + this.error);
        }
    }

    handleFirstNameChange(event) {
      if(event.target.name=="First Name"){
        this.firstName = event.target.value;
        console.log('this.firstName ' + this.firstName);
      }
        
    }

    handleEmailChange(event) {
      if(event.target.name=="email"){
        this.email = event.target.value;
        console.log('Email ' + this.email);
      }
        
    }

    handleUpdate() {
        console.log('handleUpdate Button Click....');
        updateLead({ leadId: this.recordId, firstName: this.firstName, email: this.email })
            .then(result => {
                console.log('Handle the success case');
            })
            .catch(error => {
                console.log('Handle the error case');
            });
    }
}