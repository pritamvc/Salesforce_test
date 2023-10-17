import { LightningElement,track,api,wire } from 'lwc';
import getReferenceAndAppList from '@salesforce/apex/LeadReferenceController.getReferenceAndAppList';
import getPincodeRecord from '@salesforce/apex/LeadReferenceController.getPincodeRecord';
import createReference from '@salesforce/apex/LeadReferenceController.createReferenceRecord';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import getLeadTotalPercentage from '@salesforce/apex/DocumentVerification.getLeadTotalPercentage';
import updateLeadTotalPercentage from '@salesforce/apex/DocumentVerification.updateLeadTotalPercentage';
import progressBar from '@salesforce/messageChannel/progressBar__c';
import {publish, MessageContext} from 'lightning/messageService';
export default class LeadReference extends LightningElement {

   
    //leadGetId='00QBi000004GBmnMAG';
    //leadGetId='00QBi000003jRaDMAU'

    @api leadRecordId; 
    @track isLoading = false;
    activeSectionName;
    @track listOfReference;
    @track AreaPinCodeRef;
    @track AreaPinCodeResultRef;
    @track hasReferenceRecord = false;
    @track firstCheck = false;

    @wire(MessageContext)
    messageContext;

    connectedCallback() {
        this.getReferenceFunction();    
    }

    handlechange(event) {
    //create a list and save the related record with considering dataset id is account id
        var foundelement = this.listOfReference.find(ele => ele.Account__c == event.target.dataset.id);
        if (event.target.name === 'Reference_First_Name__c') {
            foundelement.Reference_First_Name__c = event.target.value;
        } else if (event.target.name === 'Reference_Last_Name__c') {
            foundelement.Reference_Last_Name__c = event.target.value;
        } else if (event.target.name === 'Reference_Middle_Name__c') {
            foundelement.Reference_Middle_Name__c = event.target.value;
        } else if (event.target.name === 'Mobile_No__c') {
            foundelement.Mobile_No__c = event.target.value;
        } else if (event.target.name === 'Email_Id__c') {
            foundelement.Email_Id__c = event.target.value;
        } else if (event.target.name === 'Landline_No__c') {
            foundelement.Landline_No__c = event.target.value;
        } else if (event.target.name === 'Occupation__c') {
            foundelement.Occupation__c = event.target.value;
        } else if (event.target.name === 'Reference_Address_1__c') {
            foundelement.Reference_Address_1__c = event.target.value;
        } else if (event.target.name === 'Reference_Address_2__c') {
            foundelement.Reference_Address_2__c = event.target.value;
        } else if (event.target.name === 'Reference_Address_3__c') {
            foundelement.Reference_Address_3__c = event.target.value;
        } else if (event.target.name === 'City__c') {
            foundelement.City__c = event.target.value;
        } else if (event.target.name === 'District__c') {
            foundelement.District__c = event.target.value;
        } else if (event.target.name === 'State__c') {
            foundelement.State__c = event.target.value;
        } else if (event.target.name === 'Country__c') {
            foundelement.Country__c = event.target.value;
        } else if (event.target.name === 'Landmark__c') {
            foundelement.Landmark__c = event.target.value;
        }

       }
    handleRefPincode(event) {
    //create a list and save pincodes and related record record with considering dataset id is account id
        var foundelement1 = this.listOfReference.find(ele => ele.Account__c == event.target.dataset.id);     
        if (event.target.name === 'Pin_Code__c') {
            foundelement1.Pin_Code__c = event.target.value;
            this.AreaPinCodeRef = foundelement1.Pin_Code__c;           
        }              
        if(this.AreaPinCodeRef == ''){
            foundelement1.Pin_Code__c = '';
            foundelement1.City__c = '';
            foundelement1.District__c = '';
            foundelement1.State__c = '';
            foundelement1.Country__c = '';
        }else{
    //call getPincodeRecord method this return the value of city,state,country,district and map
        getPincodeRecord({ pincode: this.AreaPinCodeRef }) 
            .then(result => {              
                this.AreaPinCodeResultRef = result;             
                foundelement1.Pin_Code__c = this.AreaPinCodeResultRef.Id;
                foundelement1.City__c = this.AreaPinCodeResultRef.City_Name__c;
                foundelement1.District__c = this.AreaPinCodeResultRef.Area_Name_Taluka__c;
                foundelement1.State__c = this.AreaPinCodeResultRef.State__c;
                foundelement1.Country__c = this.AreaPinCodeResultRef.Country__c;
            })
            .catch(error => {
                this.errors = error;
            });
        }
    }  
    getReferenceFunction() {
    //debugger;
       // to send lead id and fetch Co-applicant and reference data related to this leadId 
        getReferenceAndAppList({ leadGetId : this.leadRecordId })
        .then(result => {
            if (result) {
                this.listOfReference = JSON.parse(JSON.stringify(result));
               if (this.listOfReference.length > 0) {
                 this.hasReferenceRecord = true;
                 //this.firstCheck = true;
                 
         // modified the listOfReference list if Reference_First_Name__c is null then make this id is null For DML Purpose      
                this.listOfReference = this.listOfReference.map(ref => {
                console.log('$$$name '+ref.Reference_First_Name__c);
                    if (!ref.Reference_First_Name__c) {
                    console.log('$$$name '+ref.Reference_First_Name__c);

                      ref.Id = null;
                    //this.firstCheck = true;
                    
                    }
                    if(ref.Reference_First_Name__c != undefined && this.firstCheck == false){
                        console.log('$$$Data present');
                        
                            this.firstCheck = true;
                            console.log('$$$value check'+this.firstCheck);
                        
                    }
                    
                   
                    return ref;
                  });
                  this.listOfReference = JSON.parse(JSON.stringify(this.listOfReference));
               }
            }
        })
        .catch(error => {
        }); 
    console.log('value check onload last'+this.firstCheck);

    }

    handleSaveReference() {
  //  debugger;
        var isError = false;
console.log('vallue check '+this.firstCheck);

        if (this.listOfReference.length > 0) {
    //to check mand fields
            for (var i = 0; i < this.listOfReference.length; i++) {
                var record = this.listOfReference[i];
                if (record.Reference_First_Name__c == '' || record.Reference_First_Name__c == undefined) {
                    isError = true;
                 }
//                 else if (record.Mobile_No__c == '' || record.Mobile_No__c == undefined) {
//                     isError = true;
//                 }
//                 else if (record.Reference_Address_1__c == '' || record.Reference_Address_1__c == undefined) {
//                     isError = true;
//                 }
//                 else if (record.Pin_Code__c == '' || record.Pin_Code__c == undefined) {
//                     isError = true;
//                 }
//                 else if (record.Account__c == '' || record.Account__c == undefined) {
//                     isError = true;
//                 }
            }
        }
        if (!isError) {
            this.isLoading = true;
            this.listOfReference.forEach(res => {
                if (!isNaN(res.Id)) {
                    res.Id = null;
                }
            });
            createReference({
                refRecordList: this.listOfReference,
                leadGetId: this.leadRecordId
            })
                .then(result => {
                    this.listOfReference = JSON.parse(JSON.stringify(result));
                    if (this.listOfReference.length > 0) {
                        this.listOfReference = JSON.parse(JSON.stringify(this.listOfReference));
                    }
                    this.isLoading = false;
                    const evt = new ShowToastEvent({
                        title: 'Reference',
                        message: 'Successfully Saved',
                        variant: 'success',
                    });
                    this.dispatchEvent(evt);
                    let sum;
                    if(this.firstCheck == true){
                        sum = 0;
                    }
                    else{
                        sum = 10;
                        this.firstCheck = true;
                        
                        let newPerc = sum;
                        
                        updateLeadTotalPercentage({ leadId: this.leadRecordId, percentage: newPerc })
                        .then(result => {
                            let ProgrssValueOfLoanSection = {ProgrssValueOfLoanSection:result };
                            publish(this.messageContext, progressBar, ProgrssValueOfLoanSection);                               
                        })
                        .catch(error => {
                            console.error(error);
                        });
                    }
                }).catch(error => {
                    this.isLoading = false;
                })
                //CAlling progress bar lead weightage 
                
                
        } else {
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Error!!',
                    message: 'Please fill all the reference mandatory fields',
                    variant: 'Error',
                }),
            );
        }
    }  

    handleNextReference() {
    debugger;
        var isError = false;
console.log('vallue check '+this.firstCheck);

        if (this.listOfReference.length > 0) {
    //to check mand fields
            for (var i = 0; i < this.listOfReference.length; i++) {
                var record = this.listOfReference[i];
                if (record.Reference_First_Name__c == '' || record.Reference_First_Name__c == undefined) {
                    isError = true;
                }
                else if (record.Mobile_No__c == '' || record.Mobile_No__c == undefined) {
                    isError = true;
                }
                else if (record.Reference_Address_1__c == '' || record.Reference_Address_1__c == undefined) {
                    isError = true;
                }
                else if (record.Pin_Code__c == '' || record.Pin_Code__c == undefined) {
                    isError = true;
                }
                else if (record.Account__c == '' || record.Account__c == undefined) {
                    isError = true;
                }
            }
        }
        if (!isError) {
            this.isLoading = true;
            this.listOfReference.forEach(res => {
                if (!isNaN(res.Id)) {
                    res.Id = null;
                }
            });
            createReference({
                refRecordList: this.listOfReference,
                leadGetId: this.leadRecordId
            })
                .then(result => {
                    this.listOfReference = JSON.parse(JSON.stringify(result));
                    if (this.listOfReference.length > 0) {
                        this.listOfReference = JSON.parse(JSON.stringify(this.listOfReference));
                    }
                    this.isLoading = false;
                    const evt = new ShowToastEvent({
                        title: 'Reference',
                        message: 'Successfully Saved',
                        variant: 'success',
                    });
                    this.dispatchEvent(evt);

                    console.log('### CHild CustomEvent'+this.nextbutton);
                           const onNextEvent = new CustomEvent('next', {
                             detail: {
                                 nextValue: '9',
                             },
                             });
                             this.dispatchEvent(onNextEvent);
                    let sum;
                    if(this.firstCheck == true){
                        sum = 0;
                    }
                    else{
                        sum = 10;
                        this.firstCheck = true;
                        
                        let newPerc = sum;
                        
                        updateLeadTotalPercentage({ leadId: this.leadRecordId, percentage: newPerc })
                        .then(result => {
                            let ProgrssValueOfLoanSection = {ProgrssValueOfLoanSection:result };
                            publish(this.messageContext, progressBar, ProgrssValueOfLoanSection);                               
                        })
                        .catch(error => {
                            console.error(error);
                        });
                    }
                }).catch(error => {
                    this.isLoading = false;
                })
                //CAlling progress bar lead weightage 
                
                
        } else {
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Error!!',
                    message: 'Please fill all the reference mandatory fields',
                    variant: 'Error',
                }),
            );
        }
    }

    handleSectionToggle(event) {
        const openSection = event.detail.openSections[0];
    
        if (openSection !== this.activeSectionName) {
            this.activeSectionName = openSection;
    
            const accordionSections = this.template.querySelectorAll('lightning-accordion-section');
            accordionSections.forEach((section) => {
                if (section.name !== this.activeSectionName) {
                    section.collapsed = true;
                }
            });
        }
    } 
}