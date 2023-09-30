import { LightningElement,track,api,wire } from 'lwc';
import getAccountDetails from'@salesforce/apex/leadDataDisplay.getAccountDetails';
import updateAccount from'@salesforce/apex/leadDataDisplay.updateAccount';
import { updateRecord } from 'lightning/uiRecordApi';
import ACCOUNT_OBJECT from '@salesforce/schema/Account';
import NAME_FIELD from '@salesforce/schema/Account.Name';
import FATHER_FIRST_NAME from '@salesforce/schema/Account.Father_First_Name__c';
import FATHER_LAST_NAME from '@salesforce/schema/Account.Father_Last_Name__c';

import LEAD_OBJECT from '@salesforce/schema/Lead';
import LAST_NAME_FIELD from '@salesforce/schema/Lead.LastName';




export default class LeadDataDisplay extends LightningElement {
  
@track records;
    @api recordId
   @track Account_Name_Formula__c;
   @track Father_First_Name;
   @track Father_Last_Name;
   @track PersonMobilePhone;
   @track leadlastname;
   
   @track error;
   @track account={};

    Account_Name_Formula__c;
    Father_First_Name;
    Father_Last_Name;
    PersonMobilePhone;
  
  @wire(getAccountDetails,{recordId:'$recordId'})
  wireAccount({error,data}){
    if(data){
        this.Account_Name_Formula__c=data.Account_Name_Formula__c;
        this.Father_First_Name=data.Father_First_Name;
        this.Father_Last_Name=data.Father_Last_Name;
        this.PersonMobilePhone=data.PersonMobilePhone;

    }
  }
   
 
    handelNameChange(event){
        this.Account_Name_Formula__c=event.target.value;
    }
    handelFatherFirstNameChange(event){
        this.Father_First_Name=event.target.value;

    }
    handelFatherLastNameChange(event){
        this.Father_Last_Name=event.target.value;

    }
    handelPhoneChange(event){
        this.phone=event.target.value;

    }
    handelsave() { 
        const accountFields = {};
        accountFields[NAME_FIELD.fieldApiName] = this.account.Account_Name_Formula__c;
        accountFields[FATHER_FIRST_NAME.fieldApiName] = this.account.Father_First_Name;
        accountFields[FATHER_LAST_NAME.fieldApiName] = this.account.Father_Last_Name;


        const leadFields = {};
        leadFields[LAST_NAME_FIELD.fieldApiName] = this.leadLastName;

        const accountRecordInput = { fields: accountFields };
        accountRecordInput.objectApiName = ACCOUNT_OBJECT.objectApiName;
        accountRecordInput.recordId = this.accountId;

        const leadRecordInput = { fields: leadFields };
        leadRecordInput.objectApiName = LEAD_OBJECT.objectApiName;
        leadRecordInput.recordId = this.leadId;

        Promise.all([
            updateRecord(accountRecordInput),
            updateRecord(leadRecordInput)
        ])
            .then(() => {
                // handle success
            })
            .catch(error => {
                // handle error
            });
    
    }
   
}