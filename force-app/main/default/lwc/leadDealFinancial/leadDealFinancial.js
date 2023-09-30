import { LightningElement, wire, api, track } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { getObjectInfo } from 'lightning/uiObjectInfoApi';
import { deleteRecord } from 'lightning/uiRecordApi';
import { getPicklistValues } from 'lightning/uiObjectInfoApi';
import getCoApplicants from '@salesforce/apex/DealLeadFinancialController.getCoApplicants';//Chnages in Apex
import getFinancialCoApplicants from '@salesforce/apex/DealLeadFinancialController.getFinancialCoApplicants';//Changes in Apex
import getFinanceData from '@salesforce/apex/DealLeadFinancialController.getFinanceData';//Changes in Apex
import getBankBranchDetails from '@salesforce/apex/LeadFinancialController.getBankBranchDetails';//Not required to change
import saveFinancialData from '@salesforce/apex/DealLeadFinancialController.saveFinancialData';
import updateLeadTotalPercentage from '@salesforce/apex/DocumentVerification.updateLeadTotalPercentage';//LWC Condition for lead Id
import progressBar from '@salesforce/messageChannel/progressBar__c';
import {publish, MessageContext} from 'lightning/messageService';
import getSectionWeightage from '@salesforce/apex/LoanApplicationFormHelper.getSectionWeightage';//LWC Condition for lead Id
import getCheck  from '@salesforce/apex/LeadCoapplicantEmploymentController.getCheck';//LWC Condition for lead Id
import updateFinancialCheck  from '@salesforce/apex/LeadFinancialController.updateFinancialCheck';//LWC Condition for lead Id
import ASSET from '@salesforce/schema/Asset';
import BANK_ACCOUNT from '@salesforce/schema/Bank_Details__c';
import LIABILITY from '@salesforce/schema/Liability__c';
import ACCOUNT_TYPE from '@salesforce/schema/Bank_Details__c.Account_Type__c';
import ASSET_TYPE from '@salesforce/schema/Asset.Asset_Type__c';
import LOAN_TYPE from '@salesforce/schema/Liability__c.Loan_Type__c';

export default class LeadFinancial extends LightningElement {
@track isLoading = false;

@api leadRecordId;
@track todaysDate;

@track listOfAssetTable;
@track listOfLiabilitiesTable;
@track listOfFinancialTable;
@track TypeApplicantOptions;
@track TypeFinancialAppOptions;
@track BranchId;
@track BranchResult;
@track selectedBankId;
@track branchData;
@track selectedValue;

@track deleteBankIds = '';
@track deleteAssetId = '';
@track deleteLiabilityIds = '';

@track blankField=true;
@track financialCheck = false;

//lightning message channel Method use for Progress bar
@wire(MessageContext)
messageContext;

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
}

initData(){
    //To get Account Names from Co-Applicant object
    getCoApplicants({leadGetId: this.leadRecordId })
    .then(result =>{
        let options = [];
        for (var key in result) {
            options.push({ label: result[key].Account__r.Name, value: result[key].Account__c , type:result[key].Type__c, leadId: result[key].Lead__r.Id, dealId: result[key].Deal__c});   
        }
        this.TypeApplicantOptions = options;
    }).catch(error =>{
        console.log('Error while fetching Account Names from SF.'+ error);
    });

    //To get Account Names from Applicant object whose Income is considered Financial 
    getFinancialCoApplicants({leadGetId:this.leadRecordId})
    .then(result =>{
        let options = [];

        for (var key in result) {
            options.push({ label: result[key].Account__r.Name, value: result[key].Account__c , type:result[key].Type__c,leadId: result[key].Lead__r.Id, dealId: result[key].Deal__c});   
        }
        this.TypeFinancialAppOptions = options;
    }).catch(error =>{
        console.log('Error while fetching Account Names from SF.'+error);
    });

    //To get saved data of Bank,Asset and Liability
    getFinanceData({leadGetId:this.leadRecordId})
    .then(result =>{
        this.wrapperForCommLeadForm = result;

        //If have bank data to add in table
        if(this.wrapperForCommLeadForm.bankAccount.length > 0){
            this.listOfFinancialTable  = JSON.parse(JSON.stringify(this.wrapperForCommLeadForm.bankAccount));
            //this.firstCheck = true;
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

    //To get the Check
    if(this.leadRecordId.startsWith('00Q')){
        getCheck({leadId:this.leadRecordId})
        .then(result=>{
            this.financialCheck = result.Financial_Section__c;
        })
    }
    
}

handleBankBranchSelection(event){
    var foundelement = this.listOfFinancialTable.find(element => element.Id == event.target.dataset.id);
    foundelement.Bank_Branch_IFSC__c = event.detail.selectedId;

    if(event.detail.selectedId == ''){
        foundelement.IFSC_Code__c = '';
        foundelement.MICR_Code__c = '';
    }
    else{
        getBankBranchDetails({ branchId: foundelement.Bank_Branch_IFSC__c})
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

handleChangeBankAccountApp(event) {
    var foundelement = this.listOfFinancialTable.find(element => element.Id == event.target.dataset.id);
    if(event.target.name == 'applicantNames'){
        foundelement.Account__c = event.target.value;
    }
    
    for(var i in this.TypeApplicantOptions){
        if(event.target.value === this.TypeApplicantOptions[i].value){
            if(this.leadRecordId.startsWith('00Q')){
                foundelement.Lead__c = this.TypeApplicantOptions[i].leadId;
            }else{
                foundelement.Deal__c = this.TypeApplicantOptions[i].dealId;
            }
               
        }
    }
}

//Handle Change for Applicant Name and getting lead id from applicant object
handleChangeAssetApplicant(event) {
    var foundelement = this.listOfAssetTable.find(element => element.Id == event.target.dataset.id);
    if(event.target.name == 'applicantNameAsset'){
        foundelement.AccountId = event.target.value;
    }
    
    for(var i in this.TypeApplicantOptions){
        if(event.target.value === this.TypeApplicantOptions[i].value){
            if(this.leadRecordId.startsWith('00Q')){
                foundelement.Lead__c = this.TypeApplicantOptions[i].leadId;
            }else{
                foundelement.Deal__c = this.TypeApplicantOptions[i].dealId;
            }
        }
    }
}

//Handle Change for Applicant Name and getting lead id from applicant object
handleLiabilityApplicant(event) {
    var foundelement = this.listOfLiabilitiesTable.find(ele => ele.Id == event.target.dataset.id);
    if(event.target.name == 'applicantNameLiabilities'){
        foundelement.Account__c = event.target.value;
    }
    
    for(var i in this.TypeApplicantOptions){
        if(event.target.value === this.TypeApplicantOptions[i].value){
            if(this.leadRecordId.startsWith('00Q')){
                foundelement.Lead__c = this.TypeApplicantOptions[i].leadId;
            }else{
                foundelement.Deal__c = this.TypeApplicantOptions[i].dealId;
            }
        }
    }
}

//Handle change for fields of financial section 
handleChangeBankAccount(event){
    var foundelement = this.listOfFinancialTable.find(element => element.Id == event.target.dataset.id);

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
    if(foundelement.Name_of_Bank__c && foundelement.branch == ''){
        foundelement.MICR_Code__c = '';
        foundelement.Bank_Branch_IFSC__c = '';
    } 
}

//To create new row for Financial Details Table List for Add/Delete

addBankAccountsRow() {
    this.createBankAccountsRow();
}

createBankAccountsRow(listOfFinancialTable) {
    let randomId = Math.random() * 16;
    let myNewElement = { Id: randomId,Account_Holder_Name__c: "", appliBranch: "", appliBank: "",Account_Number__c: "",Account_Type__c: "",Account_Operational_Since__c: "",IFSC_Code__c:"",MICR_Code__c:""};      
    this.listOfFinancialTable = [...this.listOfFinancialTable, myNewElement];
}

//To remove record from UI and SF
removeBankAccountsRow(event) {
    if(isNaN(event.target.dataset.id)){
        this.deleteBankIds = this.deleteBankIds + ',' + event.target.dataset.id;
    }
    console.log("this.deleteBankIds== " + this.deleteBankIds);
    if(this.listOfFinancialTable.length > 1){
        this.listOfFinancialTable.splice(this.listOfFinancialTable.findIndex(row => row.Id === event.target.dataset.id), 1);        
    }    
}

//Handle change for fields of Asset Details
handleChangeAsset(event){
    var foundelement = this.listOfAssetTable.find(element => element.Id == event.target.dataset.id);

    if(event.target.name === 'Asset_Type__c'){
        foundelement.Asset_Type__c = event.target.value;
    }
    else if(event.target.name === 'Asset_Value__c'){
        foundelement.Asset_Value__c = event.target.value; 
    }
    else if(event.target.name === 'Asset_Description__c'){
        foundelement.Description = event.target.value;
    }
}

//To create new row for Asset Table List for Add/Delete

addAssetRow() {
    this.createAssetRow(this.listOfAssetTable);
}
createAssetRow(listOfAssetTable) {
    let randomId = Math.random() * 16;
    let myNewElement = { Id: randomId,Asset_Type__c: "", Asset_Value__c: "", Asset_Description__c: ""};     
    this.listOfAssetTable = [...this.listOfAssetTable, myNewElement];
}

//To remove record from UI and SF
removeAssetRow(event) {
    if(isNaN(event.target.dataset.id)){
        this.deleteAssetId = this.deleteAssetId + ',' + event.target.dataset.id;
    } 
    if(this.listOfAssetTable.length > 1){
        this.listOfAssetTable.splice(this.listOfAssetTable.findIndex(row => row.Id === event.target.dataset.id), 1);
    } 
}


//To create new record for Liabilities Table List for Add/Delete

addLiabilitiesRow() {
    this.createLiabilitiesRow(this.listOfLiabilitiesTable);
}

createLiabilitiesRow(listOfLiabilitiesTable) {
    let randomId = Math.random() * 16;
    let myNewElement = { Id: randomId,Loan_Type__c: "", Monthly_Installment__c: "", Balance_Tenure_In_Months__c: "",Outstanding_Amount__c:"",Original_Amount__c:""};     
    this.listOfLiabilitiesTable = [...this.listOfLiabilitiesTable, myNewElement];
}

//To remove record from UI and SF
removeLiabilitiesRow(event) {
    if(isNaN(event.target.dataset.id)){
        this.deleteLiabilityIds = this.deleteLiabilityIds + ',' + event.target.dataset.id;
    } 
    if(this.listOfLiabilitiesTable.length > 1){
        this.listOfLiabilitiesTable.splice(this.listOfLiabilitiesTable.findIndex(row => row.Id === event.target.dataset.id), 1); 
    }      
}

//Handle change for fields for Liability setion
handleChangeLiability(event){
    var foundelement = this.listOfLiabilitiesTable.find(element => element.Id == event.target.dataset.id);

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
handleFinancialSaveAsDraft(){
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

            //Calling apex method
            saveFinancialData({
                financialData: this.listOfFinancialTable,
                assetData: this.listOfAssetTable,
                liabilityData: this.listOfLiabilitiesTable,
                leadGetId: this.leadRecordId,
                deleteBankIds : this.deleteBankIds,
                deleteAssetId : this.deleteAssetId,
                deleteLiabilityIds : this.deleteLiabilityIds
            })
            .then(response => {
                console.log('response ', JSON.stringify(response));
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
                this.handleErrorMessage(error);
            })
        }
    }
}

//To Next button financial section
handleFinancialSaveNext(){
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

            //Calling apex method
            saveFinancialData({
                financialData: this.listOfFinancialTable,
                assetData: this.listOfAssetTable,
                liabilityData: this.listOfLiabilitiesTable,
                leadGetId: this.leadRecordId,
                deleteBankIds : this.deleteBankIds,
                deleteAssetId : this.deleteAssetId,
                deleteLiabilityIds : this.deleteLiabilityIds
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

                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Finance',
                        message: 'Successfully Saved',
                        variant: 'Success',
                    }),
                );


                if(this.leadRecordId.startsWith('00Q')){
                //Progress bar update
                let sum;
                if(this.financialCheck == true){
                    sum = 0;
                }
                else{
                    //Get the weightage for financial Section
                    getSectionWeightage({sectionName:'Financial'})
                    .then(result=>{  
                        sum = result;
                        if(sum){
                            let newPerc = sum;
                            updateLeadTotalPercentage({ leadId: this.leadRecordId, percentage: newPerc })
                            .then(result => {
                                let ProgrssValueOfLoanSection = {ProgrssValueOfLoanSection:result };
                                publish(this.messageContext, progressBar, ProgrssValueOfLoanSection);
                                
                            })
                            .catch(error => {
                                console.error('Error while updating lead percentage:'+JSON.stringify(error));
                            });
                        }
                    })                            
                    .catch(error=>{

                    })
                    
                        updateFinancialCheck({leadId:this.leadRecordId,isCheck:true})
                        .then(result=>{
                            this.financialCheck = result.Financial_Section__c;
                        })
                    
                }

                }

                    /*****Next Child Component*****/
                    const onNextEvent = new CustomEvent('next', {
                    detail: {
                        nextValue: '7',
                    },
                    });
                    this.dispatchEvent(onNextEvent);
                    /***************/
            }).catch(error => {
                console.log('Error while saving the data :'+JSON.stringify(error));
                this.isLoading = false;
                this.handleErrorMessage(error);
            })
            
        }
    }
}

handleErrorMessage(error) {
    let errorMessage = 'An error occurred';

    if (error.body && error.body.fieldErrors) {
        const fieldErrors = error.body.fieldErrors;
        const firstFieldName = Object.keys(fieldErrors)[0];
        if (fieldErrors[firstFieldName].length > 0) {
            errorMessage = fieldErrors[firstFieldName][0].message;
        }
    } else if (error.pageErrors && error.pageErrors.length > 0) {
        errorMessage = error.pageErrors[0].message;
    } else {
        errorMessage = error.statusText;
    }
    
    this.dispatchEvent(
        new ShowToastEvent({
            title: 'Error!!',
            message: errorMessage,
            variant: 'Error',
        }),
    );
}
}