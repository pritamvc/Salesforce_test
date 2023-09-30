import { LightningElement,track,api,wire } from 'lwc';
import getAccountDetails from'@salesforce/apex/leadDataDisplay.getAccountDetails';
import updateAccount from'@salesforce/apex/leadDataDisplay.updateAccount';



export default class LeadDataDisplay extends LightningElement {
  
@track records;
    @api recordId
   @track Account_Name_Formula__c;
   @track Father_First_Name;
   @track Father_Last_Name;
   @track PersonMobilePhone;
   
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
        consol.log('name'+event.target.value);
    }
    handelFatherFirstNameChange(event){
        this.Father_First_Name=event.target.value;
        this.Father_First_Name=event.target.value;
        consol.log(event.target.value);

    }
    handelFatherLastNameChange(event){
        this.Father_Last_Name=event.target.value;
        this.Father_Last_Name=event.target.value;
           consol.log(Father_Last_Name);
    }
    handelPhoneChange(event){
        this.PersonMobilePhone=event.target.value;
        consol.log(PersonMobilePhone);

    }
    handelsave() { 
        alert('id'+recordId);
        
     if(this.recordId && this.Account_Name_Formula__c && this.Father_First_Name__c && this.Father_First_Name && this.PersonMobilePhone){
        updateAccount({recordId:'$recordId',
            Account_Name_Formula__c: this.Account_Name_Formula__c,
            Father_First_Name:this.Father_First_Name,
            Father_Last_Name:this.Father_Last_Name,
            PersonMobilePhone:this.PersonMobilePhone})
          .then(result => {
            this.error= undefined;
          })
          .catch(error=>{
            this.error=error.message;
          });
       }else{
        this.error='not save'
       }
    }
   
}