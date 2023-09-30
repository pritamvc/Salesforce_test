import { LightningElement, wire, api, track } from 'lwc';
import { getPicklistValues, getObjectInfo } from 'lightning/uiObjectInfoApi';
import getleadWithApplicantsRecord from '@salesforce/apex/TempControllerSohail.getleadWithApplicantsRec';
//import getWrapperClassCommFormLists from '@salesforce/apex/TempControllerSohail.getWrapperClassCommFormList';
import newmetodtocallemployment from '@salesforce/apex/DemoCommunityLeadForm.getEmploymentWithAddress';
import saveEmployment from '@salesforce/apex/DemoCommunityLeadForm.saveEmployment';
import deleteEmployment from '@salesforce/apex/DemoCommunityLeadForm.deleteEmployment';
import getAccountsFromEmployment from '@salesforce/apex/DemoCommunityLeadForm.getAccountsFromEmploymentAndCoApplicants';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import getPincodeRecord from '@salesforce/apex/TempControllerSohail.getPincodeRecord';
import EMPLOYMENT from '@salesforce/schema/Employment_Details__c';
import EMP_TYPE from '@salesforce/schema/Employment_Details__c.Employment_Type__c';
import CMP_NAME from '@salesforce/schema/Employment_Details__c.Type_Of_Company__c';
import ROLE from '@salesforce/schema/Employment_Details__c.Role_In_Organization__c';
import { NavigationMixin } from 'lightning/navigation';
//import { getRecord } from 'lightning/uiRecordApi';
import getLeadTotalPercentage from '@salesforce/apex/DocumentVerification.getLeadTotalPercentage';
import updateLeadTotalPercentage from '@salesforce/apex/DocumentVerification.updateLeadTotalPercentage';
import progressBar from '@salesforce/messageChannel/progressBar__c';
import {publish, MessageContext} from 'lightning/messageService';

export default class CommunityFormARSChild extends NavigationMixin(LightningElement) {

    @api recordId;
    @api leadRecordId;
    @track applicantLead;
    @track appliWithLeadId;
    @track AppliWithLeadName;
    @api secFive;
    @api secSix;
    @api secSeven;
    @api secEight;
    @api secNine;
    @api secTen;
    //From Parent 
    @api mydata;
    @track todaysDate;

    //Show/Hide 
    @track ShowFieldsEmpTypeStud = false;
    @track ShowFieldsEmpTypeHomemaker = false;
    @track ShowFieldsEmpTypeSalaried = false;
    @track ShowFieldsEmpTypeSEP = false;
    @track ShowFieldsEmpTypeSENonP = false;
    @track ShowFieldsEmpTypeRetired = false;
    @track ShowFieldsapplicantNameAssetIsIncome = false;
    @track ShowFieldsapplicantNameLiabilitiesIsIncome = false;
    @track ShowAddressSection = false;

    //Lead Picklist values 
    @api objectName = 'Lead';
    @api recordTypeId;
    //Local Authority Lead 
    @track localAuthority;
    @api localAuthorityField = 'Local_Authority__c';
    @track localAuthorityLabel;
    @api localAuthorityValue;
    @track localAuthorityOptions;
    apilocalAuthority;

    //Table Add/Delete section data list
    @track listOfEmploymentTable;
    @track listOfAssetTable;
    @track listOfLiabilitiesTable;
    // @track listOfLoanTable;
    @track listOfFinancialTable;
    @track listOfCollateralTable;
    @track listOfReferenceTable;
    @track documentTable;

    //Account Picklist values 
    @api recordTypeId1;
    @api objectNameAcc = 'Employment_Details__c';
    //Employment Details Section
    //Employment Type from Account from SFDC
    @track EmploymentTypePerAcc;
    @api EmploymentTypePerAccField = 'Employment_Type__c';
    @track EmploymentTypePerAccLabel;
    @api EmploymentTypePerAccValue;
    @track EmploymentTypePerAccOptions;
    apiEmploymentTypePerAcc;
    //No. of Years with current employer from Account from SFDC
    @track NumYearsCurrEmployerPerAcc;
    @api NumYearsCurrEmployerPerAccField = 'No_Of_Years_with_Current_Employer__c';
    @track NumYearsCurrEmployerPerAccLabel;
    @api NumYearsCurrEmployerPerAccValue;
    @track NumYearsCurrEmployerPerAccOptions;
    apiNumYearsCurrEmployerPerAcc;
    //Type of Company from Account from SFDC
    @track TypeOfCompanyPerAcc;
    @api TypeOfCompanyPerAccField = 'Type_Of_Company__c';
    @track TypeOfCompanyPerAccLabel;
    @api TypeOfCompanyPerAccValue;
    @track TypeOfCompanyPerAccOptions;
    apiTypeOfCompanyPerAcc;
    //Role in Organization from Account from SFDC
    @track RoleInOrgPerAcc;
    @api RoleInOrgPerAccField = 'Role_In_Organization__c';
    @track RoleInOrgPerAccLabel;
    @api RoleInOrgPerAccValue;
    @track RoleInOrgPerAccOptions;
    apiRoleInOrgPerAcc;
    //Account Type from Account from SFDC
    @track AccTypePerAcc;
    @api AccTypePerAccField = 'Account_Type__c';
    @track AccTypePerAccLabel;
    @api AccTypePerAccValue;
    @track AccTypePerAccOptions;
    apiAccTypePerAcc;
    //Account Type from Account from SFDC
    @track AssetTypePerAcc;
    @api AssetTypePerAccField = 'Asset_Type__c';
    @track AssetTypePerAccLabel;
    @api AssetTypePerAccValue;
    @track AssetTypePerAccOptions;
    apiAssetTypePerAcc;
    //Account Type from Account from SFDC
    @track LoanTypePerAcc;
    @api LoanTypePerAccField = 'Loan_Type__c';
    @track LoanTypePerAccLabel;
    @api LoanTypePerAccValue;
    @track LoanTypePerAccOptions;
    apiLoanTypePerAcc;
    AppliCategoryvalue = '';
    @track duplicateAccountResult;
    @track isLoading = false;

    //for bank 
    @track BankName;
    @track BranchId;
    @track BranchResult;
    @track BankName;
    @track MICR_Code__c;
    @track monthlyIncomeValid = false;
    @track noYearValid = false;
    @track noTotalYearValid = false;
    @track dateError = false;
    @track gstValid = false;
    @track showChildComponent = false;
    @track firstCheck = false;

    get AppliCategoryOptions() {
        return [
            { label: 'Co-applicant', value: 'Co-applicant' },
            { label: 'Guarantor', value: 'Guarantor' },
        ];
    }
    @wire(MessageContext)
    messageContext;

    @wire(getObjectInfo, { objectApiName: EMPLOYMENT })
    objectInfo;

    @wire(getPicklistValues, { recordTypeId: '$objectInfo.data.defaultRecordTypeId', fieldApiName: EMP_TYPE})
    EmploymentTypePerAccOptions;

    @wire(getPicklistValues, { recordTypeId: '$objectInfo.data.defaultRecordTypeId', fieldApiName: CMP_NAME})
    TypeOfCompanyPerAccOptions;

    @wire(getPicklistValues, { recordTypeId: '$objectInfo.data.defaultRecordTypeId', fieldApiName: ROLE})
    RoleInOrgPerAccOptions;

    connectedCallback() {
        this.todaysDate = new Date().toISOString().split('T')[0];  
        this.initData();
        this.callingFromParent();
    }
    initData() {
    }

    //Employment Table List for Add/Delete
    @track convertToString;
    addNewRowEmployment() {
        let randomId = Math.random() * 16;

        let myNewElement = {
            "objEmployment": { "Id": randomId, "Employment_Type__c": "" },
            "appOfficeAdd": {
                "Id": randomId, "Address_1__c": "", "Pin_Code__c": null, "City__c": "", "District__c": "",
                "State__c": "", "Country__c": "", "Landmark__c": ""
            }
        };

        this.listOfEmploymentTable = [...this.listOfEmploymentTable, myNewElement];
    }

    @track deleteEmpId = '';
    removeTheRowEmployment(event) {
        if (isNaN(event.target.dataset.id)) {
            this.deleteEmpId = this.deleteEmpId + event.target.dataset.id;
        }

        console.log('deleteEmpId', this.deleteEmpId);
        if(this.listOfEmploymentTable.length == 1){
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Error!!',
                    message: 'You cannot delete this Record. One record is mandatory',
                    variant: 'Error',
                }),
            );

        }
        else if (this.listOfEmploymentTable.length > 1) {
            this.listOfEmploymentTable.splice(this.listOfEmploymentTable.findIndex(row => row.objEmployment.Id == event.target.dataset.id), 1);

            this.isLoading = true;

            deleteEmployment({employmentId:this.deleteEmpId})
            .then(result => {
                this.isLoading = false;
                this.wrapperForCommLeadForm = result;

                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Success',
                        message: 'Deleted Successfully',
                        variant: 'Success',
                    }),
                );

                if (result.length > 0) {
                    this.eploymentrecordfound = true;

                    this.listOfEmploymentTable = JSON.parse(JSON.stringify(this.wrapperForCommLeadForm));

                    this.listOfEmploymentTable.forEach(function (employment) {
                        try {
                            if (employment.objEmployment.Employment_Type__c == 'Salaried') {
                                employment['emptypesalraiedtrue'] = true;
                            } else {
                                employment['emptypesalraiedtrue'] = false;
                            }
                            if (employment.objEmployment.Employment_Type__c == 'Self Employed Professional(SEP)') {
                                employment['emptypeSEProfessional'] = true;
                            } else {
                                employment['emptypeSEProfessional'] = false;
                            }
                            if (employment.objEmployment.Employment_Type__c == 'Self Employed non Professional(SENP)') {
                                employment['emptypeSENonProfessional'] = true;
                            } else {
                                employment['emptypeSENonProfessional'] = false;
                            }
                            if (employment.objEmployment.Employment_Type__c == 'Retired') {
                                employment['emptypeRetired'] = true;

                            } else {
                                employment['emptypeRetired'] = false;
                            }
                            if (employment.objEmployment.Employment_Type__c == 'Retired' || employment.objEmployment.Employment_Type__c == 'Self Employed non Professional(SENP)' ||
                                employment.objEmployment.Employment_Type__c == 'Self Employed Professional(SEP)' || employment.objEmployment.Employment_Type__c == 'Salaried') {
                                employment['ShowAddressSection'] = true;

                            } else {
                                employment['ShowAddressSection'] = false;
                            }

                        } catch (e) { }
                    });
                }
                console.log('Deleting Account');
            })
            .catch(error => {
                this.isLoading = false;
                console.log(error);
            }) 
        } 
    }

    //Used to set values based on Employment Type
    handleEmploymentTypeSelect(event) {
        var foundelement = this.listOfEmploymentTable.find(ele => ele.objEmployment.Id == event.target.dataset.id);

        if (event.target.name == 'Employment_Type__c') {
            foundelement.objEmployment.Employment_Type__c = event.target.value;
        }

        if (event.target.value === "Salaried") {
            foundelement.emptypesalraiedtrue = true;
        }
        else {
            foundelement.emptypesalraiedtrue = false;
        }

        //Show hide Self Employed Professional(SEP)
        if (event.target.value === "Self Employed Professional(SEP)") {
            foundelement.emptypeSEProfessional = true;
        }
        else {
            foundelement.emptypeSEProfessional = false;
        }

        //Show hide Self Employed Non Professional(SENP)
        if (event.target.value === "Self Employed non Professional(SENP)") {
            foundelement.emptypeSENonProfessional = true;
        }
        else {
            foundelement.emptypeSENonProfessional = false;
        }

        //Show hide Retired
        if (event.target.value === "Retired") {
            foundelement.emptypeRetired = true;
        }
        else {
            foundelement.emptypeRetired = false;
        }

        if(event.target.value === "Retired" || event.target.value === "Self Employed non Professional(SENP)" ||
        event.target.value === "Self Employed Professional(SEP)" || event.target.value === "Salaried"){
            foundelement.ShowAddressSection = true;
        }
        else{
            foundelement.ShowAddressSection = false;
        }
    }

    handleEmpTypeSalaried(event) {
        //TABLE TARGETS FORMAT
        let index = event.target.dataset.id;
        let fieldName = event.target.name;
        let value = event.target.value;

        //Employment table handlechange
        for (let i = 0; i < this.listOfEmploymentTable.length; i++) {
            if (this.listOfEmploymentTable[i].index === parseInt(index)) {
                this.listOfEmploymentTable[i][fieldName] = value;
            }
        }

    }

    handleEmpTypeSEP(event) {
        //TABLE TARGETS FORMAT
        let index = event.target.dataset.id;
        let fieldName = event.target.name;
        let value = event.target.value;

        //Employment table handlechange
        for (let i = 0; i < this.listOfEmploymentTable.length; i++) {
            if (this.listOfEmploymentTable[i].index === parseInt(index)) {
                this.listOfEmploymentTable[i][fieldName] = value;
            }
        }
    }

    handleEmpTypeSENP(event) {
        //TABLE TARGETS FORMAT
        let index = event.target.dataset.id;
        let fieldName = event.target.name;
        let value = event.target.value;

        //Employment table handlechange
        for (let i = 0; i < this.listOfEmploymentTable.length; i++) {
            if (this.listOfEmploymentTable[i].index === parseInt(index)) {
                this.listOfEmploymentTable[i][fieldName] = value;
            }
        }
    }

    handleEmpTypeRetired(event) {
        //TABLE TARGETS FORMAT
        let index = event.target.dataset.id;
        let fieldName = event.target.name;
        let value = event.target.value;

        //Employment table handlechange
        for (let i = 0; i < this.listOfEmploymentTable.length; i++) {
            if (this.listOfEmploymentTable[i].index === parseInt(index)) {
                this.listOfEmploymentTable[i][fieldName] = value;
            }
        }
    }

    //@track l_All_Types;
    @track TypeOptions;
    @track isIncomeConsideroptions;
    @track norecordfound = false;

    

    //On change Applicant Name
    handleTypeChange(event) {
        var foundelement1 = this.listOfEmploymentTable.find(ele => ele.objEmployment.Id == event.target.dataset.id);

        if (event.target.name == 'applicantNamesEmployment') {
            foundelement1.objEmployment.Account__c = event.target.value;
        }
        for (var i in this.TypeOptions) {
            if (event.target.value === this.TypeOptions[i].value) {
                foundelement1.objEmployment.Lead__c = this.TypeOptions[i].leadId;
            }
        }      
    }
       

    

    //@track employsalariedtype = 'Salaried';
    @track emptypesalraiedtrue = false;
    @track emptypeSEProfessional = false;
    @track emptypeSENonProfessional = false;
    @track emptypeRetired = false;
    @track emptypestudenttrue = false;
    @track eploymentrecordfound = false;
    @track eploymentrecordnotfound = false;

    callingFromParent() {
        
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

        newmetodtocallemployment({ leadId: this.leadRecordId })
            .then(result => {

                this.wrapperForCommLeadForm = result;
                console.log('data'+JSON.stringify(this.wrapperForCommLeadForm));
                if (result.length > 0) {
                    this.eploymentrecordfound = true;

                    this.listOfEmploymentTable = JSON.parse(JSON.stringify(this.wrapperForCommLeadForm));

                    this.listOfEmploymentTable.forEach((employment) => {
                        this.firstCheck = true;
                        try{
                            console.log('INSIDE TRY');
                            if (employment.objEmployment.Employment_Type__c == 'Salaried') {
                                employment['emptypesalraiedtrue'] = true;
                            } else {
                                employment['emptypesalraiedtrue'] = false;
                            }
                            if (employment.objEmployment.Employment_Type__c == 'Self Employed Professional(SEP)') {
                                employment['emptypeSEProfessional'] = true;
                            } else {
                                employment['emptypeSEProfessional'] = false;
                            }
                            if (employment.objEmployment.Employment_Type__c == 'Self Employed non Professional(SENP)') {
                                employment['emptypeSENonProfessional'] = true;
                            } else {
                                employment['emptypeSENonProfessional'] = false;
                            }
                            if (employment.objEmployment.Employment_Type__c == 'Retired') {
                                employment['emptypeRetired'] = true;

                            } else {
                                employment['emptypeRetired'] = false;
                            }
                            if (employment.objEmployment.Employment_Type__c == 'Retired' || employment.objEmployment.Employment_Type__c == 'Self Employed non Professional(SENP)' ||
                            employment.objEmployment.Employment_Type__c == 'Self Employed Professional(SEP)' || employment.objEmployment.Employment_Type__c == 'Salaried') {
                                employment['ShowAddressSection'] = true;

                            } else {
                                employment['ShowAddressSection'] = false;
                            }
                            console.log('employmentShowAddressSection=>' , employment.ShowAddressSection);
                            if(employment.objEmployment.Monthly_Income__c < 0){
                                employment.objEmployment.monthlyIncomeValid = true;
                            }
                            if(employment.objEmployment.No_Of_Years_with_Current_Employer__c > 99){
                                employment.objEmployment.noYearValid = true;
                            }
                            if(employment.objEmployment.Total_Professional_Experience__c > 99){
                                employment.objEmployment.noTotalYearValid = true;
                            }

                        } catch (e) { }
                    });
                } else {
                    let randomId = Math.random() * 16;

                    let myNewElement = {
                        "objEmployment": { "Id": randomId, "Employment_Type__c": "" },
                        "appOfficeAdd": {
                            "Id": randomId, "Address_1__c": "", "Pin_Code__c": null, "City__c": "", "District__c": "",
                            "State__c": "", "Country__c": "", "Landmark__c": ""
                        }
                    };

                    this.listOfEmploymentTable = [myNewElement];
                }

            })
            .catch(error => {

            });
    }

    @track AreaPinCodeRef;
    @track AreaPinCodeResultRef;
    handleRefPincode(event) {
        var foundelement1 = this.listOfEmploymentTable.find(ele => ele.appOfficeAdd.Id == event.target.dataset.id);
        if (event.target.name === 'Pin_Code__c') {
            foundelement1.appOfficeAdd.Pin_Code__c = event.target.value;
            this.AreaPinCodeRef = foundelement1.appOfficeAdd.Pin_Code__c;
        }
        getPincodeRecord({ pincode: this.AreaPinCodeRef }) //this parameter is passed to Class-CommunityLeadFormController.getPincodeRecord
            .then(result => {
                this.AreaPinCodeResultRef = result;
                foundelement1.appOfficeAdd.Pin_Code__c = this.AreaPinCodeResultRef.Id;
                foundelement1.appOfficeAdd.City__c = this.AreaPinCodeResultRef.City_Name__c;
                foundelement1.appOfficeAdd.District__c = this.AreaPinCodeResultRef.Area_Name_Taluka__c;
                foundelement1.appOfficeAdd.State__c = this.AreaPinCodeResultRef.State__c;
                foundelement1.appOfficeAdd.Country__c = this.AreaPinCodeResultRef.Country__c;
            })
            .catch(error => {
                this.errors = error;
                console.log('errorsCoappli=======> ' + this.errors);
            });
    }


    handleSuccess = (event) => {
        // event.preventDefault();

        this.dispatchEvent(
            new ShowToastEvent({
                title: 'Success',
                message: 'Employment created successfully.',
                variant: 'success'
            })
        ).catch(err => {
            console.log("Error Saving data ", err);
        })

    }

    handleChangeEmployment(event) {
        var foundelement = this.listOfEmploymentTable.find(ele => ele.objEmployment.Id == event.target.dataset.id);

        if (event.target.name === 'Name_Of_The_Company__c') {
            foundelement.objEmployment.Name_Of_The_Company__c = event.target.value;
        }
        else if (event.target.name === 'Type_Of_Company__c') {
            foundelement.objEmployment.Type_Of_Company__c = event.target.value;
        }
        else if (event.target.name === 'Role_In_Organization__c') {
            foundelement.objEmployment.Role_In_Organization__c = event.target.value;
        }
        else if (event.target.name === 'Official_Email_Id__c') {
            foundelement.objEmployment.Official_Email_Id__c = event.target.value;
        }
        else if (event.target.name === 'Monthly_Income__c') {
            let fieldValue = event.target.value;
            let pattern = /^[1-9][0-9]{0,5}$/;
            if (!pattern.test(fieldValue)) {
                foundelement.objEmployment.monthlyIncomeValid = true;
            } else {
                foundelement.objEmployment.Monthly_Income__c = event.target.value;
                foundelement.objEmployment.monthlyIncomeValid = false;
            }
        }
        else if (event.target.name === 'No_Of_Years_with_Current_Employer__c') {
            let fieldValue = event.target.value;
            let pattern = /^[0-9]{0,2}$/;
            if (!pattern.test(fieldValue)) {
                foundelement.objEmployment.noYearValid = true;
            } else {
                foundelement.objEmployment.No_of_Years_with_Current_Employer__c = event.target.value;
                foundelement.objEmployment.noYearValid = false;
            }
        }
        else if (event.target.name === 'Total_Professional_Experience__c') {
            let fieldValue = event.target.value;
            let pattern = /^[0-9]{0,2}$/;
            if (!pattern.test(fieldValue)) {
                foundelement.objEmployment.noTotalYearValid = true;
            } else {
                foundelement.objEmployment.Total_Professional_Experience__c = event.target.value;
                foundelement.objEmployment.noTotalYearValid = false;
            }
        }
        else if (event.target.name === 'Nature_of_Professional__c') {
            foundelement.objEmployment.Nature_of_Professional__c = event.target.value;
        }
        else if (event.target.name === 'Address_of_Current_Business__c') {
            foundelement.objEmployment.Address_of_Current_Business__c = event.target.value;
        }
        else if (event.target.name === 'Membership_Number__c') {
            foundelement.objEmployment.Membership_Number__c = event.target.value;
        }
        else if (event.target.name === 'GST_IN__c') {
            let fieldValue = event.target.value;
            let pattern = /^[0-9]{2}[A-Z]{5}[0-9]{4}[A-Z]{1}[0-9A-Z]{1}[Z]{1}[0-9A-Z]{1}$/;
            if (!pattern.test(fieldValue)) {
                foundelement.objEmployment.gstValid = true;
            } else {
                foundelement.objEmployment.GST_IN__c = event.target.value;
                foundelement.objEmployment.gstValid = false;
            }
            //foundelement.objEmployment.GST_IN__c = event.target.value;
        }
        else if (event.target.name === 'Nature_of_Business__c') {
            foundelement.objEmployment.Nature_of_Business__c = event.target.value;
        }
        else if (event.target.name === 'Date_of_Retirement__c') {
            if(event.target.value > this.todaysDate){
                console.log('Greater date')
                foundelement.objEmployment.dateError = true;
                console.log('true');
                console.log(foundelement.objEmployment.dateError);
                console.log(foundelement.objEmployment.Date_of_Retirement__c);
            }
            else if(event.target.value === this.todaysDate){
                console.log('accepting todays date');
                foundelement.objEmployment.dateError = false;
                foundelement.objEmployment.Date_of_Retirement__c = event.target.value;
            }
            else{
                foundelement.objEmployment.dateError = false;
                foundelement.objEmployment.Date_of_Retirement__c = event.target.value;
                console.log('Accept date');
                console.log(foundelement.objEmployment.dateError);
                console.log(foundelement.objEmployment.Date_of_Retirement__c);
            }      
        }
        else if (event.target.name === 'Organisation_Name__c') {
            foundelement.objEmployment.Organisation_Name__c = event.target.value;
        }
        else if (event.target.name === 'Pension_Amount__c') {
            foundelement.objEmployment.Pension_Amount__c = event.target.value;
        }
    }

    handleChangeAddress(event) {
        var foundelement = this.listOfEmploymentTable.find(ele => ele.appOfficeAdd.Id == event.target.dataset.id);

        if (event.target.name === 'Address_1__c') {
            foundelement.appOfficeAdd.Address_1__c = event.target.value;
        }
        else if (event.target.name === 'City__c') {
            foundelement.appOfficeAdd.City__c = event.target.value;
        }
        else if (event.target.name === 'Area_Taluka_District_Area_name__c') {
            foundelement.appOfficeAdd.Area_Taluka_District_Area_name__c = event.target.value;
        }
        else if (event.target.name === 'District__c') {
            foundelement.appOfficeAdd.District__c = event.target.value;
        }
        else if (event.target.name === 'State__c') {
            foundelement.appOfficeAdd.State__c = event.target.value;
        }
        else if (event.target.name === 'Country__c') {
            foundelement.appOfficeAdd.Country__c = event.target.value;
        }
        else if (event.target.name === 'Landmark__c') {
            foundelement.appOfficeAdd.Landmark__c = event.target.value;
        }
    }

    handleSaveEmployment(event) {
        console.log('List'+JSON.stringify(this.listOfEmploymentTable));
        var typeaccountmissing;
        var monthyError;
        var noYear;
        var noTotalYear;
        var dateErr;
        var gstError;
        let accountSet = new Set();
        let hasDuplicate = false;

        if(this.listOfEmploymentTable.length > 0){
            for (var i = 0; i < this.listOfEmploymentTable.length; i++) {
                let employment = this.listOfEmploymentTable[i].objEmployment;
                let account = employment.Account__c;

                if (accountSet.has(account)) {
                    console.log('INSIDE 2 CO-APPLICANT');
                    hasDuplicate = true;
                    break;
                }else if(!accountSet.has(account)){
                    console.log('INSIDE ELSE ADD CO-APPLICANT');
                    accountSet.add(account);
                }               
            }
        }

        if (this.listOfEmploymentTable.length > 0) {

            for (var i = 0; i < this.listOfEmploymentTable.length; i++) {
                var record = this.listOfEmploymentTable[i];
                console.log('record'+record.objEmployment.Date_of_Retirement__c);

                 if(record.objEmployment.monthlyIncomeValid == true){
                    monthyError = true;
                    if(monthyError)
                        break;
                }

                else if(record.objEmployment.noYearValid == true){
                    noYear = true;
                    if(noYear)
                        break;
                }

                else if(record.objEmployment.noTotalYearValid == true){
                    noTotalYear = true;
                    if(noTotalYear)
                        break;
                }

                else if(record.objEmployment.dateError == true){
                    dateErr = true;
                    if(dateErr)
                        break;
                }

                else if(record.objEmployment.gstValid == true){
                    gstError = true;
                    if(gstError)
                        break;
                }

                else if (record.objEmployment.Employment_Type__c == '' || record.objEmployment.Employment_Type__c == undefined ||
                    record.objEmployment.Account__c == '' || record.objEmployment.Account__c == undefined) {
                    typeaccountmissing = true;
                    if (typeaccountmissing)
                        break;
                }
            }


            if(hasDuplicate){
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Error!!',
                        message: 'The applicant name for the new record already exists.',
                        variant: 'Error',
                    }),
                );
            }
            else if(monthyError){
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Error!!',
                        message: 'Please enter valid income',
                        variant: 'Error',
                    }),
                );
            }
            else if(noYear){
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Error!!',
                        message: 'Please enter valid experience',
                        variant: 'Error',
                    }),
                );
            }

            else if(noTotalYear){
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Error!!',
                        message: 'Please enter valid experience',
                        variant: 'Error',
                    }),
                );
            }

            else if(dateErr){
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Error!!',
                        message: 'Please enter valid date',
                        variant: 'Error',
                    }),
                );
            }

            else if(gstError){
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Error!!',
                        message: 'Please enter valid GST Number ',
                        variant: 'Error',
                    }),
                );
            }

            else if (typeaccountmissing) {
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Error!!',
                        message: 'Please fill the mandatory fields of Employment Section',
                        variant: 'Error',
                    }),
                );
            } 
            else {
                this.listOfEmploymentTable.forEach(res => {
                    
                        if (!isNaN(res.objEmployment.Id)) {
                            res.objEmployment.Id = null;
                        }
                        if (!isNaN(res.appOfficeAdd.Id)) {
                            res.appOfficeAdd.Name = 'Office Address';
                            res.appOfficeAdd.Address_Type__c = 'Office';
                            res.appOfficeAdd.Id = null;
                        }
                     
                });
               
                this.isLoading = true;
                saveEmployment({employmentAddressData:this.listOfEmploymentTable, leadId:this.leadRecordId})
                    .then(result => {
                        this.isLoading = false; 
                        this.wrapperForCommLeadForm = result;
        
                        if (result.length > 0) {
                            this.eploymentrecordfound = true;
        
                            this.listOfEmploymentTable = JSON.parse(JSON.stringify(this.wrapperForCommLeadForm));
        
                            this.listOfEmploymentTable.forEach(function (employment) {
                                try {
                                    if (employment.objEmployment.Employment_Type__c == 'Salaried') {
                                        employment['emptypesalraiedtrue'] = true;
                                    } else {
                                        employment['emptypesalraiedtrue'] = false;
                                    }
                                    if (employment.objEmployment.Employment_Type__c == 'Self Employed Professional(SEP)') {
                                        employment['emptypeSEProfessional'] = true;
                                    } else {
                                        employment['emptypeSEProfessional'] = false;
                                    }
                                    if (employment.objEmployment.Employment_Type__c == 'Self Employed non Professional(SENP)') {
                                        employment['emptypeSENonProfessional'] = true;
                                    } else {
                                        employment['emptypeSENonProfessional'] = false;
                                    }
                                    if (employment.objEmployment.Employment_Type__c == 'Retired') {
                                        employment['emptypeRetired'] = true;
        
                                    } else {
                                        employment['emptypeRetired'] = false;
                                    }
                                    if (employment.objEmployment.Employment_Type__c == 'Retired' || employment.objEmployment.Employment_Type__c == 'Self Employed non Professional(SENP)' ||
                                        employment.objEmployment.Employment_Type__c == 'Self Employed Professional(SEP)' || employment.objEmployment.Employment_Type__c == 'Salaried') {
                                        employment['ShowAddressSection'] = true;

                                    } else {
                                employment['ShowAddressSection'] = false;
                                    }
        
                                } catch (e) { }
                            });
                        } 
                        this.dispatchEvent(
                            new ShowToastEvent({
                                title: 'Employment',
                                message: 'Successfully Saved',
                                variant: 'Success',
                            }),
                        );
                    })
                    .catch(error => {
                        this.isLoading = false;
                        console.log(error);
                    })
            }
        }
    }

    handleNextEmployment(event) {
        debugger;
        console.log('List'+JSON.stringify(this.listOfEmploymentTable));
        var typeaccountmissing;
        var salariedmissing;
        var selfemploymissing;
        var selfempnonprofmissing;
        var retiredmissing;
        var employmentSection;
        var addressSection;
        var monthyError;
        var noYear;
        var noTotalYear;
        var dateErr;
        var gstError;
        var getAccountsFromEmploymentError;
        let accountSet = new Set();
        let hasDuplicate = false;

        getAccountsFromEmployment({leadId:this.leadRecordId})
            .then(result => {
                console.log('result.length' , result.length);
                console.log('Listfdvddv'+JSON.stringify(this.listOfEmploymentTable));
    
                // Filter the listOfEmploymentTable array to create a new array that only contains elements with matching Account__c field
                const filteredEmployment = this.listOfEmploymentTable.filter(emp => result.includes(emp.objEmployment.Account__c));
                console.log('filteredEmployment' ,filteredEmployment.length);
    
                // Compare the lengths of the two arrays to check if all the Ids in result are present in objEmployment.Account__c
                 if (result.length !== filteredEmployment.length) {
                    console.log('Some Ids are missing from objEmployment.Account__c');
                    getAccountsFromEmploymentError=true; 
                }   
            })
            .catch(error => {
                console.log('Error while fetching Account Id from Co-Applicant ' +error);
            })

        if(this.listOfEmploymentTable.length > 0){
            for (var i = 0; i < this.listOfEmploymentTable.length; i++) {
                let employment = this.listOfEmploymentTable[i].objEmployment;
                let account = employment.Account__c;

                if (accountSet.has(account)) {
                    console.log('INSIDE 2 CO-APPLICANT');
                    hasDuplicate = true;
                    break;
                }else if(!accountSet.has(account)){
                    console.log('INSIDE ELSE ADD CO-APPLICANT');
                    accountSet.add(account);
                }               
            }
        }

        if (this.listOfEmploymentTable.length > 0) {

            for (var i = 0; i < this.listOfEmploymentTable.length; i++) {
                var record = this.listOfEmploymentTable[i];
                console.log('record'+record.objEmployment.Date_of_Retirement__c);

                 if(record.objEmployment.monthlyIncomeValid == true){
                    monthyError = true;
                    if(monthyError)
                        break;
                }

                else if(record.objEmployment.noYearValid == true){
                    noYear = true;
                    if(noYear)
                        break;
                }

                else if(record.objEmployment.noTotalYearValid == true){
                    noTotalYear = true;
                    if(noTotalYear)
                        break;
                }

                else if(record.objEmployment.dateError == true){
                    dateErr = true;
                    if(dateErr)
                        break;
                }

                else if(record.objEmployment.gstValid == true){
                    gstError = true;
                    if(gstError)
                        break;
                }

                else if (record.objEmployment.Employment_Type__c == '' || record.objEmployment.Employment_Type__c == undefined ||
                    record.objEmployment.Account__c == '' || record.objEmployment.Account__c == undefined) {
                    typeaccountmissing = true;
                    if (typeaccountmissing)
                        break;
                }
                else if ((record.objEmployment.Employment_Type__c == 'Salaried') &&
                    (record.objEmployment.Name_Of_The_Company__c == '' || record.objEmployment.Name_Of_The_Company__c == undefined ||
                        record.objEmployment.Type_Of_Company__c == '' || record.objEmployment.Type_Of_Company__c == undefined ||
                        record.objEmployment.Role_In_Organization__c == '' || record.objEmployment.Role_In_Organization__c == undefined ||
                        record.objEmployment.Official_Email_Id__c == '' || record.objEmployment.Official_Email_Id__c == undefined ||
                        record.objEmployment.Monthly_Income__c == '' || record.objEmployment.Monthly_Income__c == undefined ||
                        record.objEmployment.No_of_Years_with_Current_Employer__c == '' || record.objEmployment.No_of_Years_with_Current_Employer__c == undefined ||
                        record.objEmployment.Total_Professional_Experience__c == '' || record.objEmployment.Total_Professional_Experience__c == undefined)) {
                    salariedmissing = true;
                    if (salariedmissing)
                        break;
                }
                else if ((record.objEmployment.Employment_Type__c == 'Self Employed Professional(SEP)') &&
                    (record.objEmployment.Total_Professional_Experience__c == '' || record.objEmployment.Total_Professional_Experience__c == undefined)) {
                    selfemploymissing = true;
                    if (selfemploymissing)
                        break;
                }
                else if ((record.objEmployment.Employment_Type__c == 'Self Employed non Professional(SENP)') &&
                    (record.objEmployment.Total_Professional_Experience__c == '' || record.objEmployment.Total_Professional_Experience__c == undefined)) {
                    selfempnonprofmissing = true;
                    if (selfempnonprofmissing)
                        break;
                }
                else if ((record.objEmployment.Employment_Type__c == 'Retired') &&
                    (record.objEmployment.Total_Professional_Experience__c == '' || record.objEmployment.Total_Professional_Experience__c == undefined)) {
                    retiredmissing = true;
                    if (retiredmissing)
                        break;
                }
                else if ((record.appOfficeAdd.Address_1__c == '' || record.appOfficeAdd.Address_1__c == undefined ||
                    record.appOfficeAdd.Pin_Code__c == '' || record.appOfficeAdd.Pin_Code__c == undefined) && 
                    (record.objEmployment.Employment_Type__c == 'Retired' || record.objEmployment.Employment_Type__c == 'Self Employed non Professional(SENP)' ||
                    record.objEmployment.Employment_Type__c == 'Self Employed Professional(SEP)' || record.objEmployment.Employment_Type__c == 'Salaried')) {
                    addressSection = true;
                    if (addressSection)
                        break;
                }
            }


            if(hasDuplicate){
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Error!!',
                        message: 'The applicant name for the new record already exists.',
                        variant: 'Error',
                    }),
                );
            }
            else if(monthyError){
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Error!!',
                        message: 'Please enter valid income',
                        variant: 'Error',
                    }),
                );
            }
            else if(noYear){
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Error!!',
                        message: 'Please enter valid experience',
                        variant: 'Error',
                    }),
                );
            }

            else if(noTotalYear){
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Error!!',
                        message: 'Please enter valid experience',
                        variant: 'Error',
                    }),
                );
            }

            else if(dateErr){
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Error!!',
                        message: 'Please enter valid date',
                        variant: 'Error',
                    }),
                );
            }

            else if(gstError){
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Error!!',
                        message: 'Please enter valid GST Number ',
                        variant: 'Error',
                    }),
                );
            }

            else if (typeaccountmissing || salariedmissing || selfemploymissing || selfempnonprofmissing || retiredmissing) {
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Error!!',
                        message: 'Please fill the mandatory fields of Employment Section',
                        variant: 'Error',
                    }),
                );
            } else if (addressSection) {
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Error!!',
                        message: 'Please fill the mandatory fields of Address Section',
                        variant: 'Error',
                    }),
                );
            } else if (getAccountsFromEmploymentError) {
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Error!!',
                        message: 'Employments details of financial applicant and co-applicants must be entered',
                        variant: 'Error',
                    }),
                );
            }

            else {
                this.listOfEmploymentTable.forEach(res => {
                    
                        if (!isNaN(res.objEmployment.Id)) {
                            res.objEmployment.Id = null;
                        }
                        if (!isNaN(res.appOfficeAdd.Id)) {
                            res.appOfficeAdd.Name = 'Office Address';
                            res.appOfficeAdd.Address_Type__c = 'Office';
                            res.appOfficeAdd.Id = null;
                        }
                     
                });
               
                this.isLoading = true;
                console.log(progressBar);
                saveEmployment({employmentAddressData:this.listOfEmploymentTable, leadId:this.leadRecordId})
                    .then(result => {
                        this.isLoading = false; 
                        this.wrapperForCommLeadForm = result;
                        let sum;
                        console.log('value check '+this.firstCheck);
                        if(this.firstCheck == true){
                            sum = 0;
                        }
                        else{
                            sum = 10;
                            this.firstCheck = true;
                            let newPerc = sum;
                        
                            updateLeadTotalPercentage({ leadId: this.leadRecordId, percentage: newPerc })
                            .then(result => {
                                let ProgrssValueOfLoanSection = {ProgrssValueOfLoanSection:result};
                                publish(this.messageContext, progressBar, ProgrssValueOfLoanSection);
                                
                            })
                            .catch(error => {
                                console.error(error);
                                // Add any error handling here
                            });
                    
                    // .catch(error => {
                    //     console.error(error);
                    // });
                    }
        
                        if (result.length > 0) {
                            this.eploymentrecordfound = true;
        
                            this.listOfEmploymentTable = JSON.parse(JSON.stringify(this.wrapperForCommLeadForm));
        
                            this.listOfEmploymentTable.forEach(function (employment) {
                                try {
                                    if (employment.objEmployment.Employment_Type__c == 'Salaried') {
                                        employment['emptypesalraiedtrue'] = true;
                                    } else {
                                        employment['emptypesalraiedtrue'] = false;
                                    }
                                    if (employment.objEmployment.Employment_Type__c == 'Self Employed Professional(SEP)') {
                                        employment['emptypeSEProfessional'] = true;
                                    } else {
                                        employment['emptypeSEProfessional'] = false;
                                    }
                                    if (employment.objEmployment.Employment_Type__c == 'Self Employed non Professional(SENP)') {
                                        employment['emptypeSENonProfessional'] = true;
                                    } else {
                                        employment['emptypeSENonProfessional'] = false;
                                    }
                                    if (employment.objEmployment.Employment_Type__c == 'Retired') {
                                        employment['emptypeRetired'] = true;
        
                                    } else {
                                        employment['emptypeRetired'] = false;
                                    }
                                    if (employment.objEmployment.Employment_Type__c == 'Retired' || employment.objEmployment.Employment_Type__c == 'Self Employed non Professional(SENP)' ||
                                        employment.objEmployment.Employment_Type__c == 'Self Employed Professional(SEP)' || employment.objEmployment.Employment_Type__c == 'Salaried') {
                                        employment['ShowAddressSection'] = true;

                                    } else {
                                employment['ShowAddressSection'] = false;
                                    }
        
                                } catch (e) { }
                            });
                        } 
                        this.dispatchEvent(
                            new ShowToastEvent({
                                title: 'Employment',
                                message: 'Successfully Saved',
                                variant: 'Success',
                            }),
                        );
                        const onNextEvent = new CustomEvent('next', {
                            detail: {
                                      nextValue:'6',
                                   },
                               });
                       this.dispatchEvent(onNextEvent);
                    })
                    .catch(error => {
                        this.isLoading = false;
                        console.log('Error while saving:'+JSON.stringify(error));
                    })

                    //Calling lead weightage progress bar
                    
            }
        }
    }

    // handleNextEmployment() {

    //     getAccountsFromEmployment({leadId:this.leadRecordId})
    //     .then(result => {
    //         console.log('result.length' , result.length);
    //         console.log('Listfdvddv'+JSON.stringify(this.listOfEmploymentTable));

    //         // Filter the listOfEmploymentTable array to create a new array that only contains elements with matching Account__c field
    //         const filteredEmployment = this.listOfEmploymentTable.filter(emp => result.includes(emp.objEmployment.Account__c));
    //         console.log('filteredEmployment' ,filteredEmployment.length);

    //         // Compare the lengths of the two arrays to check if all the Ids in result are present in objEmployment.Account__c
    //          if (result.length !== filteredEmployment.length) {
    //             console.log('Some Ids are missing from objEmployment.Account__c');

    //             this.dispatchEvent(
    //                 new ShowToastEvent({
    //                     title: 'Error!!',
    //                     message: 'Employments details of financial applicant and co-applicants must be entered',
    //                     variant: 'Error',
    //                 }),
    //             );
    //         }   
    //     })
    //     .catch(error => {
    //         console.log('Error while fetching Account Id from Co-Applicant ' +error);
    //     })



    //   }
}