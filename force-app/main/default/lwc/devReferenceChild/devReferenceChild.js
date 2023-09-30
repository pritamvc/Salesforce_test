import { LightningElement, wire, api, track } from 'lwc';
import getleadWithApplicantsRecord from '@salesforce/apex/TempControllerSohail.getleadWithApplicantsRec';
import getReferenceData from '@salesforce/apex/TempControllerSohail.getReferenceList';
import createReference from '@salesforce/apex/TempControllerSohail.createReferenceRecord';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import getPincodeRecord from '@salesforce/apex/TempControllerSohail.getPincodeRecord';
import getLeadTotalPercentage from '@salesforce/apex/DocumentVerification.getLeadTotalPercentage';
import updateLeadTotalPercentage from '@salesforce/apex/DocumentVerification.updateLeadTotalPercentage';
import progressBar from '@salesforce/messageChannel/progressBar__c';
import {publish, MessageContext} from 'lightning/messageService';


export default class CommunityFormTusharChild extends LightningElement {
    @api leadRecordId;
    @track isLoading = false;
    @track TypeOptions;
    @wire(MessageContext)
    messageContext;
    message;
    @track listOfReferenceTable;

    connectedCallback() {
        console.log('Lead ID Refernce==>', this.leadRecordId);
        this.getReferenceFunction();
    }

    handlechange(event) {
        var foundelement = this.listOfReferenceTable.find(ele => ele.Id == event.target.dataset.id);
        console.log('foundelement' + JSON.stringify(foundelement));
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

    @track AreaPinCodeRef;
    @track AreaPinCodeResultRef;
    handleRefPincode(event) {
        var foundelement1 = this.listOfReferenceTable.find(ele => ele.Id == event.target.dataset.id);     
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
        getPincodeRecord({ pincode: this.AreaPinCodeRef }) //this parameter is passed to Class-CommunityLeadFormController.getPincodeRecord
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
                console.log('errorsCoappli=======> ' + this.errors);
            });
        }
    }   

    handleTypeChange(event) {

        var foundelement1 = this.listOfReferenceTable.find(ele => ele.Id == event.target.dataset.id);
        console.log('foundelement1' + JSON.stringify(foundelement1));
        if (event.target.name == 'applicantNamesReference') {
            foundelement1.Account__c = event.target.value;
            console.log('tfoundelement1.Account__c  inside If===>', foundelement1.Account__c);
        }
        console.log('foundelement1 this.TypeOptions===>', this.TypeOptions)
        for (var i in this.TypeOptions) {
            if (event.target.value === this.TypeOptions[i].value) {
                foundelement1.Lead__c = this.TypeOptions[i].leadId;
            }
        }
    }

    getReferenceFunction() {
        //To get Account Names from Applicant object
        console.log('NEW DATA REF 1')
        getleadWithApplicantsRecord({ leadGetId: this.leadRecordId })
            .then(result => {
                let options = [];
                let newObj = [];
                for (var gg in result) {
                    newObj.push({ value: result[gg].Id, type: result[gg].Type__c })
                }
                for (var key in result) {
                    options.push({ label: result[key].Account__r.Name, value: result[key].Account__c, type: result[key].Type__c, leadId: result[key].Lead__r.Id });
                }
                this.TypeOptions = options;
            }).catch(error => {
                console.log('Error while fetching Account Names from SF.');
            });

        console.log('Lead Id', this.leadRecordId);
        getReferenceData({ leadGetId: this.leadRecordId })
            .then(result => {
                if (result) {
                    this.listOfReferenceTable = JSON.parse(JSON.stringify(result));
                    console.log('listOfReferenceTable result =>' + JSON.stringify(this.listOfReferenceTable));
                    if (this.listOfReferenceTable.length > 0) {
                        this.listOfReferenceTable = JSON.parse(JSON.stringify(this.listOfReferenceTable));
                    }

                    else {
                        let randomId = Math.random() * 16;
                        let myNewElement = {
                            Id: randomId, Reference_First_Name__c: "", Reference_Last_Name__c: "", Reference_Middle_Name__c: "", Mobile_No__c: "", Email_Id__c: "", Landline_No__c: "",
                            Reference_Address_1__c: "", Reference_Address_2__c: "", Reference_Address_3__c: "", City__c: "", District__c: "", State__c: "", Country__c: "", Landmark__c: "", Pin_Code__c: null,
                        };
                        console.log("myNewElement===>" + myNewElement);
                        this.listOfReferenceTable = [myNewElement];
                        console.log("this.listOfReferenceTable===>" + this.listOfReferenceTable);
                    }

                    console.log(error);
                    this.error = error;
                    if (this.listOfReferenceTable.length > 0) {
                        this.listOfReferenceTable.length + 1;
                    }
                }
            })
            .catch(error => {
            });
    }

    //Added by Avadhut
    handleSaveReference() {
        console.log('In submit');
        console.log('this.listOfReferenceTable SAVE====>', JSON.stringify(this.listOfReferenceTable));
        var isError = false;

        if (this.listOfReferenceTable.length > 0) {
            for (var i = 0; i < this.listOfReferenceTable.length; i++) {
                var record = this.listOfReferenceTable[i];
                console.log('record:', record.Reference_First_Name__c);
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

            if (this.deleteReferIds !== '') {
                this.deleteReferIds = this.deleteReferIds.substring(0);
            }

            this.listOfReferenceTable.forEach(res => {
                if (!isNaN(res.Id)) {
                    res.Id = null;
                    console.log(' res.Id====>' + res.Id);
                }
            });
            console.log(' this.deleteReferIds====>' + this.deleteReferIds);
            console.log('this.leadRecordId handle Save reference=>', this.leadRecordId);
            createReference({
                refRecordList: this.listOfReferenceTable,
                removeReferenceIds: this.deleteReferIds,
                leadGetId: this.leadRecordId
            })
                .then(result => {
                    console.log(' result reference1====>' + result);

                    this.listOfReferenceTable = JSON.parse(JSON.stringify(result));
                    console.log('listOfReferenceTable result =>' + JSON.stringify(this.listOfReferenceTable));
                    if (this.listOfReferenceTable.length > 0) {
                        this.listOfReferenceTable = JSON.parse(JSON.stringify(this.listOfReferenceTable));
                    }

                    else {
                        let randomId = Math.random() * 16;
                        let myNewElement = {
                            Id: randomId, Reference_First_Name__c: "", Reference_Last_Name__c: "", Reference_Middle_Name__c: "", Mobile_No__c: "", Email_Id__c: "", Landline_No__c: "",
                            Reference_Address_1__c: "", Reference_Address_2__c: "", Reference_Address_3__c: "", City__c: "", District__c: "", State__c: "", Country__c: "", Landmark__c: "", Pin_Code__c: null,
                        };
                        console.log("myNewElement===>" + myNewElement);
                        this.listOfReferenceTable = [myNewElement];
                        console.log("this.listOfReferenceTable===>" + this.listOfReferenceTable);
                    }
                    this.isLoading = false;
                    /****progress bar data pass****/
                   debugger
                   getLeadTotalPercentage({ leadId:this.leadRecordId })
                   .then(result => {
                       console.log('Total pppercentagee:', result);
                       let newPerc = result + 12;
                       let ProgrssValueOfLoanSection = {ProgrssValueOfLoanSection:newPerc };
                       console.log('ProgressValueOfLoanSection +++' , ProgrssValueOfLoanSection);
                       publish(this.messageContext, progressBar, ProgrssValueOfLoanSection);
                       updateLeadTotalPercentage({ leadId: this.leadRecordId, percentage: newPerc })
                       .then(result => {
                           if (result === 'Success') {
                               console.log('Lead updated successfully');
                               // Add any success logic here
                           } else {
                               console.error('Failed to update Lead');
                               // Add any failure logic here
                           }
                       })
                       .catch(error => {
                           console.error(error);
                           // Add any error handling here
                       });
                   })
                   .catch(error => {
                       console.error(error);
                   });
                    const evt = new ShowToastEvent({
                        title: 'Reference',
                        message: 'Successfully Saved',
                        variant: 'success',
                    });
                    this.dispatchEvent(evt);
                }).catch(error => {
                    this.isLoading = false;
                    console.log('error while inserting record -->', error);
                })
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

    //Added by Avadhut
    addRowReference() {
        let randomId = Math.random() * 16;
        let myNewElement = {
            Id: randomId, Reference_First_Name__c: "", Reference_Last_Name__c: "", Reference_Middle_Name__c: "", Mobile_No__c: "", Email_Id__c: "", Landline_No__c: "",
            Reference_Address_1__c: "", Reference_Address_2__c: "", Reference_Address_3__c: "", City__c: "", District__c: "", State__c: "", Country__c: "", Landmark__c: "", Pin_Code__c: null,
        };
        console.log("myNewElement===>" + myNewElement);
        this.listOfReferenceTable = [...this.listOfReferenceTable, myNewElement];
        console.log("this.listOfReferenceTable===>" + this.listOfReferenceTable);
    }

    @track deleteReferIds = '';
    removeRowReference(event) {
        console.log("Remove clicked ");
        if (isNaN(event.target.dataset.id)) {
            this.deleteReferIds = this.deleteReferIds + ',' + event.target.dataset.id;
        }
        console.log("this.deleteReferIds== " + this.deleteReferIds);
        console.log("this.deleteReferIds.length== " + this.deleteReferIds.length);
        console.log("this.listOfReferenceTable.length== " + this.listOfReferenceTable.length);
        if (this.listOfReferenceTable.length > 1) {
            this.listOfReferenceTable.splice(this.listOfReferenceTable.findIndex(row => row.Id === event.target.dataset.id), 1);
        }
        deleteRecord(this.deleteReferIds)
            .then(() => {
                console.log('Deleting the record...');
            })
            .catch(error => {

        });
    }
}