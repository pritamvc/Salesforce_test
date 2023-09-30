import { LightningElement, wire, api, track } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { getObjectInfo } from 'lightning/uiObjectInfoApi';
import { deleteRecord } from 'lightning/uiRecordApi';
import { getPicklistValues } from 'lightning/uiObjectInfoApi';

import getleadWithApplicantsRecord from '@salesforce/apex/TempControllerSohail.getleadWithApplicantsRec';
import getleadWithApplicantsRecForAsset from '@salesforce/apex/TempControllerSohail.getleadWithApplicantsRecForAsset';
import getFinanceData from '@salesforce/apex/TempControllerSohail.getFinanceData';
import getBranchRecord from '@salesforce/apex/TempControllerSohail.getBranchRecord';
import saveFinancialData from '@salesforce/apex/TempControllerSohail.saveFinancialData';

import ASSET from '@salesforce/schema/Asset';
import BANK_ACCOUNT from '@salesforce/schema/Bank_Details__c';
import LIABILITY from '@salesforce/schema/Liability__c';

import ACCOUNT_TYPE from '@salesforce/schema/Bank_Details__c.Account_Type__c';
import ASSET_TYPE from '@salesforce/schema/Asset.Asset_Type__c';
import LOAN_TYPE from '@salesforce/schema/Liability__c.Loan_Type__c';
import getLeadTotalPercentage from '@salesforce/apex/DocumentVerification.getLeadTotalPercentage';
import updateLeadTotalPercentage from '@salesforce/apex/DocumentVerification.updateLeadTotalPercentage';

import SUBMITACTION from '@salesforce/messageChannel/submit__c';
import progressBar from '@salesforce/messageChannel/progressBar__c';
import {publish, MessageContext} from 'lightning/messageService';


export default class FinancialChildTemp extends LightningElement {
    @track isLoading = false;
    @track save = true;
    @wire(MessageContext)
    messageContext;
    message;
    @api secFive;
    @api secSix;
    @api secSeven;
    @api secEight;
    @api secNine;
    @api secTen;
    @api leadRecordId;
    @track todaysDate;

    @track listOfAssetTable;
    @track listOfLiabilitiesTable;
    @track listOfFinancialTable;
    @track TypeOptions;
    @track TypeOptionsAsset;
    @track BranchId;
    @track BranchResult;
    @track selectedBankId;
    @track branchData;
    @track selectedValue;
    @track blankField=true;

    @wire(getObjectInfo, { objectApiName: BANK_ACCOUNT })
    objectInfo;

    @wire(getPicklistValues, { recordTypeId: '$objectInfo.data.defaultRecordTypeId', fieldApiName: ACCOUNT_TYPE})
    TypePicklistValues;

    @wire(getObjectInfo, { objectApiName: ASSET })
    objectInfoAsset;

    @wire(getPicklistValues, { recordTypeId: '$objectInfoAsset.data.defaultRecordTypeId', fieldApiName: ASSET_TYPE})
    AssetTypePerAccOptions;

    @wire(getObjectInfo, { objectApiName: LIABILITY })
    objectInfoLiability;

    @wire(getPicklistValues, { recordTypeId: '$objectInfoLiability.data.defaultRecordTypeId', fieldApiName: LOAN_TYPE})
    LoanTypePerAccOptions;

    connectedCallback() {
        this.todaysDate = new Date().toISOString().split('T')[0];   
        this.initData();
        //this.branchData.querySelector('c-branch-custom-lookup').addEventListener('select', this.handleBranchSelection.bind(this));
    }
    initData(){
        //To get Account Names from Applicant object
        getleadWithApplicantsRecord({leadGetId: this.leadRecordId })
        .then(result =>{
            let options = [];
            let newObj=[];
            for (var gg in result) {
                newObj.push({ value: result[gg].Id,type:result[gg].Type__c})
            }
            for (var key in result) {
                options.push({ label: result[key].Account__r.Name, value: result[key].Account__c , type:result[key].Type__c,leadId: result[key].Lead__r.Id});   
            }
            this.TypeOptions = options;
        }).catch(error =>{
            console.log('Error while fetching Account Names from SF.');
        });

        //To get Account Names from Applicant object whose Income is considered Financial 
        getleadWithApplicantsRecForAsset({leadGetId:this.leadRecordId})
        .then(result =>{
            let options = [];
            let newObj=[];
            for (var gg in result) {
                newObj.push({ value: result[gg].Id,type:result[gg].Type__c})
            }
            for (var key in result) {
                options.push({ label: result[key].Account__r.Name, value: result[key].Account__c , type:result[key].Type__c,leadId: result[key].Lead__r.Id});   
            }
            this.TypeOptionsAsset = options;
        }).catch(error =>{
            console.log('Error while fetching Account Names from SF.');
        });

        //To get saved data of Bank,Asset and Liability
        getFinanceData({leadGetId:this.leadRecordId})
        .then(result =>{
            this.wrapperForCommLeadForm = result;

            //If have bank data to add in table
            if(this.wrapperForCommLeadForm.bankAccount.length > 0){
                this.listOfFinancialTable  = JSON.parse(JSON.stringify(this.wrapperForCommLeadForm.bankAccount)); 
            }
            
            
            //Or create one blank table for bank details
            else{
                let randomId = Math.random() * 16;
                let myNewElement = { Id: randomId,Account_Holder_Name__c: "", Account_Number__c: "", Account_Operational_Since__c: "",Account_Type__c: "",Bank_Branch_IFSC__c: "",Name_of_Bank__c: "",IFSC_Code__c:"",MICR_Code__c:""};        
                this.listOfFinancialTable = [myNewElement];
            }              
            //If have asset data to add in table
            if(this.wrapperForCommLeadForm.assetDetails.length > 0){
                this.listOfAssetTable  = JSON.parse(JSON.stringify(this.wrapperForCommLeadForm.assetDetails)); 
            }
            
            //Or create one blank table for asset details
            else{
                let randomId = Math.random() * 16;
                let myNewElement = { Id: randomId,Asset_Type__c: "", Asset_Value__c: "", Description: ""};       
                this.listOfAssetTable = [myNewElement];
            }

            //If have liability data to add in table
            if(this.wrapperForCommLeadForm.liabilityDetails.length > 0){
                this.listOfLiabilitiesTable  = JSON.parse(JSON.stringify(this.wrapperForCommLeadForm.liabilityDetails)); 
            }
            
            //Or create one blank table for liability details
            else{
                let randomId = Math.random() * 16;
                let myNewElement = { Id: randomId,Loan_Type__c: "",Monthly_Installment__c: "",Original_Amount__c: "",Outstanding_Amount__c: "",Balance_Tenure_In_Months__c:""};        
                this.listOfLiabilitiesTable = [myNewElement];
            }

            this.listOfFinancialTable.forEach(element => {
                element.selectedBankId = element.Name_of_Bank__c;
                element.selectedValue = element.Bank_Branch_IFSC__c;
                element.blankField = false;                
            });
        }).catch(error=>{
            console.log('Error while fetching data from SF...');
        });
    }

    handleSelection(event){
        var foundelement = this.listOfFinancialTable.find(ele => ele.Id == event.target.dataset.id);
        foundelement.Bank_Branch_IFSC__c = event.detail.selectedId;

        if(event.detail.selectedId == ''){
            foundelement.IFSC_Code__c = '';
            foundelement.MICR_Code__c = '';
        }
        else{
            getBranchRecord({ branchId: foundelement.Bank_Branch_IFSC__c})
            .then(result => {
                this.BranchResult = result;
                foundelement.IFSC_Code__c = this.BranchResult.IFSC__c;
                foundelement.MICR_Code__c = this.BranchResult.MICR__c;
                foundelement.Bank_Branch_IFSC__c = this.BranchResult.Id;
            })
            .catch(error => {
                this.errors = error;
                console.log('Error while getting branch data from master: ' + this.errors);
            });
        }
    }
    //Handle Change for Applicant Name and getting lead id from applicant object
    handleChangeNameBank(event) {
        var foundelement = this.listOfFinancialTable.find(ele => ele.Id == event.target.dataset.id);
        if(event.target.name == 'applicantNames'){
            foundelement.Account__c = event.target.value;
        }
        
        for(var i in this.TypeOptions){
            if(event.target.value === this.TypeOptions[i].value){
                foundelement.Lead__c = this.TypeOptions[i].leadId;   
            }
        }
    }

    //Handle Change for Applicant Name and getting lead id from applicant object
    handleChangeNameAsset(event) {
        var foundelement = this.listOfAssetTable.find(ele => ele.Id == event.target.dataset.id);
        if(event.target.name == 'applicantNameAsset'){
            foundelement.AccountId = event.target.value;
        }
        
        for(var i in this.TypeOptions){
            if(event.target.value === this.TypeOptions[i].value){
                foundelement.Lead__c = this.TypeOptions[i].leadId;
            }
        }
    }

    //Handle Change for Applicant Name and getting lead id from applicant object
    handleChangeNameLiability(event) {
        var foundelement = this.listOfLiabilitiesTable.find(ele => ele.Id == event.target.dataset.id);
        if(event.target.name == 'applicantNameLiabilities'){
            foundelement.Account__c = event.target.value;
        }
        
        for(var i in this.TypeOptions){
            if(event.target.value === this.TypeOptions[i].value){
                foundelement.Lead__c = this.TypeOptions[i].leadId;
            }
        }
    }

    //Handle change for fields of financial section 
    handleChangeFinancial(event){
        var foundelement = this.listOfFinancialTable.find(ele => ele.Id == event.target.dataset.id);

        if(event.target.name === 'Account_Holder_Name__c'){ 
            foundelement.Account_Holder_Name__c = event.target.value;
        } 
        else if(event.target.name === 'appliBank'){
            foundelement.Name_of_Bank__c = event.target.value;
            foundelement.blankField = false;
            foundelement.selectedBankId = event.target.value;
        }
        else if(event.target.name === 'Account_Number__c'){
            foundelement.Account_Number__c = event.target.value;
        }
        else if(event.target.name === 'Account_Type__c'){
            foundelement.Account_Type__c = event.target.value;
        }
        else if(event.target.name === 'Account_Operational_Since__c'){
            foundelement.Account_Operational_Since__c = event.target.value;
        }
        else if(event.target.name === 'IFSC_Code__c'){
            foundelement.IFSC_Code__c = event.target.value;
        }
        else if(event.target.name === 'MICR_Code__c'){
            foundelement.MICR_Code__c = event.target.value;
        }
        else if(event.target.name === 'applicantNames'){
            foundelement.applicantNames = event.target.value;
        }

        if(foundelement.Name_of_Bank__c && foundelement.branch == ''){
            foundelement.MICR_Code__c = '';
            foundelement.Bank_Branch_IFSC__c = '';
            foundelement.IFSC_Code__c = '';

        } 
    }

    //To create new row for Financial Details Table List for Add/Delete
    createRowFinancial(listOfFinancialTable) {
        let randomId = Math.random() * 16;
        let myNewElement = { Id: randomId,Account_Holder_Name__c: "", appliBranch: "", appliBank: "",Account_Number__c: "",Account_Type__c: "",Account_Operational_Since__c: "",IFSC_Code__c:"",MICR_Code__c:""};      
        this.listOfFinancialTable = [...this.listOfFinancialTable, myNewElement];
    }
    addNewRowFinancial() {
        this.createRowFinancial(this.listOfFinancialTable);
    }

    @track deleteBankIds = '';
    //To remove record from UI and SF
    removeTheRowFinancial(event) {
        if(isNaN(event.target.dataset.id)){
            this.deleteBankIds = this.deleteBankIds + ',' + event.target.dataset.id;
        }
        console.log("this.deleteBankIds== " + this.deleteBankIds);
        if(this.listOfFinancialTable.length > 1){
            this.listOfFinancialTable.splice(this.listOfFinancialTable.findIndex(row => row.Id === event.target.dataset.id), 1);
            // deleteRecord(this.deleteBankIds)
            // .then(() => {
            //     console.log('Deleting the record...');
            // })
            // .catch(error => {
                
            // }); 
        }    
    }

    //Handle change for fields of Asset Details
    handlechangeAsset(event){
        var foundelement = this.listOfAssetTable.find(ele => ele.Id == event.target.dataset.id);

        if(event.target.name === 'Asset_Type__c'){
            foundelement.Asset_Type__c = event.target.value;
        }
        else if(event.target.name === 'Asset_Value__c'){
            foundelement.Asset_Value__c = event.target.value; 
        }
        else if(event.target.name === 'Asset_Description__c'){
            foundelement.Asset_Description__c = event.target.value;
        }
    }

    //To create new row for Asset Table List for Add/Delete
    createRowAsset(listOfAssetTable) {
        let randomId = Math.random() * 16;
        let myNewElement = { Id: randomId,Asset_Type__c: "", Asset_Value__c: "", Asset_Description__c: ""};     
        this.listOfAssetTable = [...this.listOfAssetTable, myNewElement];
    }
    addNewRowAsset() {
        this.createRowAsset(this.listOfAssetTable);
    }

    @track deleteAssetId = '';
    //To remove record from UI and SF
    removeTheRowAsset(event) {
        if(isNaN(event.target.dataset.id)){
            this.deleteAssetId = this.deleteAssetId + ',' + event.target.dataset.id;
        }
        console.log("this.deleteAssetId== " + this.deleteAssetId);  
        if(this.listOfAssetTable.length > 1){
            this.listOfAssetTable.splice(this.listOfAssetTable.findIndex(row => row.Id === event.target.dataset.id), 1);
            // deleteRecord(this.deleteAssetId)
            // .then(() => {
            //     console.log('Deleting the record...');
            // })
            // .catch(error => {
                
            // }); 
        }    
    }


    //To create new record for Liabilities Table List for Add/Delete
    createRowLiabilities(listOfLiabilitiesTable) {
        let randomId = Math.random() * 16;
        let myNewElement = { Id: randomId,Loan_Type__c: "", Monthly_Installment__c: "", Balance_Tenure_In_Months__c: "",Outstanding_Amount__c:"",Original_Amount__c:""};     
        this.listOfLiabilitiesTable = [...this.listOfLiabilitiesTable, myNewElement];
    }
    addNewRowLiabilities() {
        this.createRowLiabilities(this.listOfLiabilitiesTable);
    }

    @track deleteLiabilityIds = '';
    //To remove record from UI and SF
    removeTheRowLiabilities(event) {
        if(isNaN(event.target.dataset.id)){
            this.deleteLiabilityIds = this.deleteLiabilityIds + ',' + event.target.dataset.id;
        }
        console.log("this.deleteLiabilityIds== " + this.deleteLiabilityIds);  
        if(this.listOfLiabilitiesTable.length > 1){
            this.listOfLiabilitiesTable.splice(this.listOfLiabilitiesTable.findIndex(row => row.Id === event.target.dataset.id), 1);
            // deleteRecord(this.deleteLiabilityIds)
            // .then(() => {
            //     console.log('Deleting the record...');
            // })
            // .catch(error => {
                
            // }); 
        }      
    }

    //Handle change for fields for Liability setion
    handlechangeLiability(event){
        var foundelement = this.listOfLiabilitiesTable.find(ele => ele.Id == event.target.dataset.id);

        if(event.target.name === 'Loan_Type__c'){
            foundelement.Loan_Type__c = event.target.value;
        }
        else if(event.target.name === 'Monthly_Installment__c'){
            foundelement.Monthly_Installment__c = event.target.value;
        }
        else if(event.target.name === 'Balance_Tenure_In_Months__c'){
            foundelement.Balance_Tenure_In_Months__c = event.target.value;
        }
        else if(event.target.name === 'Outstanding_Amount__c'){
            foundelement.Outstanding_Amount__c = event.target.value;
        }
        else if(event.target.name === 'Original_Amount__c'){
            foundelement.Original_Amount__c = event.target.value;
        }
    }

    //To save as Draft
    handleSaveAsDraftFinancial(){
        var error;
        if(this.listOfFinancialTable.length > 0){
            for(var i=0; i<this.listOfFinancialTable.length;i++){
                var record = this.listOfFinancialTable[i];

                if(record.Account_Holder_Name__c == '' || !record.Bank_Branch_IFSC__c || !record.Name_of_Bank__c || record.Account_Number__c == '' || record.Account_Type__c == '' || record.MICR_Code__c == ''){
                    error = true;
                    if(error)
                        break;    
                } 
            }

            //If error variable true then show error message 
            if(error){
                this.dispatchEvent(
                        new ShowToastEvent({
                            title: 'Error!!',
                            message: 'Please fill all the finance mandatory fields',
                            variant: 'Error',
                        }),
                    );
            } 

            //Or pass data to apex to save in SF
            else{
                this.isLoading = true;                

                if (this.deleteBankIds !== '') {
                    this.deleteBankIds = this.deleteBankIds.substring(0);
                }  
                if (this.deleteAssetId !== '') {
                    this.deleteAssetId = this.deleteAssetId.substring(0);
                } 
                if (this.deleteLiabilityIds !== '') {
                    this.deleteLiabilityIds = this.deleteLiabilityIds.substring(0);
                }  

                //If Id is generated random then assign to null
                this.listOfFinancialTable.forEach(res =>{
                    if(!isNaN(res.Id)){
                        res.Id = null;
                        res.branch = null;
                    }
                });

                //If Id is generated random then assign to null
                this.listOfAssetTable.forEach(res =>{
                    if(!isNaN(res.Id)){
                        res.Id = null;
                        res.Name = res.Asset_Type__c;
                    } 
                });
    
                //If Id is generated random then assign to null 
                this.listOfLiabilitiesTable.forEach(res =>{
                    if(!isNaN(res.Id)){
                            res.Id = null;
                    }
                });
                console.log(' this.deleteBankIds save method====>' + this.deleteBankIds);
                console.log(' this.deleteAssetId save method====>' + this.deleteAssetId);
                console.log(' this.deleteLiabilityIds save method====>' + this.deleteLiabilityIds);

                //Calling apex method
                saveFinancialData({
                    financialData: this.listOfFinancialTable,
                    assetData: this.listOfAssetTable,
                    liabilityData: this.listOfLiabilitiesTable,
                    leadGetId: this.leadRecordId,
                    removedeleteBankIds : this.deleteBankIds,
                    removedeleteAssetId : this.deleteAssetId,
                    removedeleteLiabilityIds : this.deleteLiabilityIds
                })
                .then(response => {
                    this.wrapperForCommLeadForm = response;
                    //If have bank data to add in table
                    if(this.wrapperForCommLeadForm.bankAccount.length > 0){
                        this.listOfFinancialTable  = JSON.parse(JSON.stringify(this.wrapperForCommLeadForm.bankAccount)); 
                    }
                    
                    //Or create one blank table for bank details
                    else{
                        let randomId = Math.random() * 16;
                        let myNewElement = { Id: randomId,Account_Holder_Name__c: "", Account_Number__c: "", Account_Operational_Since__c: "",Account_Type__c: "",Bank_Branch_IFSC__c: "",Name_of_Bank__c: ""};        
                        this.listOfFinancialTable = [myNewElement];
                    }              

                    //If have asset data to add in table
                    if(this.wrapperForCommLeadForm.assetDetails.length > 0){
                        this.listOfAssetTable  = JSON.parse(JSON.stringify(this.wrapperForCommLeadForm.assetDetails)); 
                    }
                    
                    //Or create one blank table for asset details
                    else{
                        let randomId = Math.random() * 16;
                        let myNewElement = { Id: randomId,Asset_Type__c: "", Asset_Value__c: "", Description: ""};       
                        this.listOfAssetTable = [myNewElement];
                    }

                    //If have liability data to add in table
                    if(this.wrapperForCommLeadForm.liabilityDetails.length > 0){
                        this.listOfLiabilitiesTable  = JSON.parse(JSON.stringify(this.wrapperForCommLeadForm.liabilityDetails)); 
                    }
                    
                    //Or create one blank table for liability details
                    else{
                        let randomId = Math.random() * 16;
                        let myNewElement = { Id: randomId,Loan_Type__c: "",Monthly_Installment__c: "",Original_Amount__c: "",Outstanding_Amount__c: "",Balance_Tenure_In_Months__c:""};        
                        this.listOfLiabilitiesTable = [myNewElement];
                    }
                    this.listOfFinancialTable.forEach(element => {
                        element.selectedBankId = element.Name_of_Bank__c;
                        element.selectedValue = element.Bank_Branch_IFSC__c;                        
                    });

                    this.isLoading = false;
                    /****progress bar data pass****/
                   debugger
                   getLeadTotalPercentage({ leadId:this.leadRecordId })
                   .then(result => {
                       console.log('Total pppercentagee:', result);
                       let newPerc = result + 8;
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

                    this.dispatchEvent(
                        new ShowToastEvent({
                            title: 'Finance',
                            message: 'Successfully Saved',
                            variant: 'Success',
                        }),
                    );
                }).catch(error => {
                    console.log('Error while saving the data :'+JSON.stringify(error));
                    this.isLoading = false;
                })
            }
        }
    }

    //To save and next financial section
    handleSaveNextFinancial(){
        var error;
        if(this.listOfFinancialTable.length > 0){
            for(var i=0; i<this.listOfFinancialTable.length;i++){
                var record = this.listOfFinancialTable[i];

                if(record.Account_Holder_Name__c == '' || !record.Bank_Branch_IFSC__c || !record.Name_of_Bank__c || record.Account_Number__c == '' || record.Account_Type__c == '' || record.MICR_Code__c == ''){
                    error = true;
                    if(error)
                        break;    
                } 
            }

            //If error variable true then show error message 
            if(error){
                this.dispatchEvent(
                        new ShowToastEvent({
                            title: 'Error!!',
                            message: 'Please fill all the finance mandatory fields',
                            variant: 'Error',
                        }),
                    );
            } 

            //Or pass data to apex to save in SF
            else{
                this.isLoading = true;                

                if (this.deleteBankIds !== '') {
                    this.deleteBankIds = this.deleteBankIds.substring(0);
                }  
                if (this.deleteAssetId !== '') {
                    this.deleteAssetId = this.deleteAssetId.substring(0);
                } 
                if (this.deleteLiabilityIds !== '') {
                    this.deleteLiabilityIds = this.deleteLiabilityIds.substring(0);
                }  

                //If Id is generated random then assign to null
                this.listOfFinancialTable.forEach(res =>{
                    if(!isNaN(res.Id)){
                        res.Id = null;
                        res.branch = null;
                    }
                });

                //If Id is generated random then assign to null
                this.listOfAssetTable.forEach(res =>{
                    if(!isNaN(res.Id)){
                        res.Id = null;
                        res.Name = res.Asset_Type__c;
                    } 
                });
    
                //If Id is generated random then assign to null 
                this.listOfLiabilitiesTable.forEach(res =>{
                    if(!isNaN(res.Id)){
                            res.Id = null;
                    }
                });
                console.log(' this.deleteBankIds save method====>' + this.deleteBankIds);
                console.log(' this.deleteAssetId save method====>' + this.deleteAssetId);
                console.log(' this.deleteLiabilityIds save method====>' + this.deleteLiabilityIds);

                //Calling apex method
                saveFinancialData({
                    financialData: this.listOfFinancialTable,
                    assetData: this.listOfAssetTable,
                    liabilityData: this.listOfLiabilitiesTable,
                    leadGetId: this.leadRecordId,
                    removedeleteBankIds : this.deleteBankIds,
                    removedeleteAssetId : this.deleteAssetId,
                    removedeleteLiabilityIds : this.deleteLiabilityIds
                })
                .then(response => {
                    this.wrapperForCommLeadForm = response;
                    //If have bank data to add in table
                    if(this.wrapperForCommLeadForm.bankAccount.length > 0){
                        this.listOfFinancialTable  = JSON.parse(JSON.stringify(this.wrapperForCommLeadForm.bankAccount)); 
                    }
                    
                    //Or create one blank table for bank details
                    else{
                        let randomId = Math.random() * 16;
                        let myNewElement = { Id: randomId,Account_Holder_Name__c: "", Account_Number__c: "", Account_Operational_Since__c: "",Account_Type__c: "",Bank_Branch_IFSC__c: "",Name_of_Bank__c: ""};        
                        this.listOfFinancialTable = [myNewElement];
                    }              

                    //If have asset data to add in table
                    if(this.wrapperForCommLeadForm.assetDetails.length > 0){
                        this.listOfAssetTable  = JSON.parse(JSON.stringify(this.wrapperForCommLeadForm.assetDetails)); 
                    }
                    
                    //Or create one blank table for asset details
                    else{
                        let randomId = Math.random() * 16;
                        let myNewElement = { Id: randomId,Asset_Type__c: "", Asset_Value__c: "", Description: ""};       
                        this.listOfAssetTable = [myNewElement];
                    }

                    //If have liability data to add in table
                    if(this.wrapperForCommLeadForm.liabilityDetails.length > 0){
                        this.listOfLiabilitiesTable  = JSON.parse(JSON.stringify(this.wrapperForCommLeadForm.liabilityDetails)); 
                    }
                    
                    //Or create one blank table for liability details
                    else{
                        let randomId = Math.random() * 16;
                        let myNewElement = { Id: randomId,Loan_Type__c: "",Monthly_Installment__c: "",Original_Amount__c: "",Outstanding_Amount__c: "",Balance_Tenure_In_Months__c:""};        
                        this.listOfLiabilitiesTable = [myNewElement];
                    }
                    this.listOfFinancialTable.forEach(element => {
                        element.selectedBankId = element.Name_of_Bank__c;
                        element.selectedValue = element.Bank_Branch_IFSC__c;                        
                    });

                    this.isLoading = false;
                    /****progress bar data pass****/
                   debugger
                   getLeadTotalPercentage({ leadId:this.leadRecordId })
                   .then(result => {
                       console.log('Total pppercentagee:', result);
                       let newPerc = result + 8;
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

                    this.dispatchEvent(
                        new ShowToastEvent({
                            title: 'Finance',
                            message: 'Successfully Saved',
                            variant: 'Success',
                        }),
                    );

                     //send success msg to submit button 
                     let financialSection = false;
                     publish(this.messageContext, SUBMITACTION , {
                        financialSection : financialSection
                     });
                     console.log('###Publishmsg financialSectionis'+financialSection);
                     /************/
                       /*****Next Child Component*****/
                       console.log('### CHild CustomEvent'+this.nextbutton);
                       const onNextEvent = new CustomEvent('next', {
                         detail: {
                             nextValue: '7',
                         },
                         });
                         this.dispatchEvent(onNextEvent);
                         this.nextPage=false;
  
                         /***************/
                }).catch(error => {
                    console.log('Error while saving the data :'+JSON.stringify(error));
                    this.isLoading = false;
                })
            }
        }
    }
}