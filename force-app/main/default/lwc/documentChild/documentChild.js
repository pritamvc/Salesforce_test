import { LightningElement, wire, api, track } from 'lwc';
import { getPicklistValues, getObjectInfo } from 'lightning/uiObjectInfoApi';
import getleadWithApplicantsRecord from '@salesforce/apex/CommunityLeadFormController.getleadWithApplicantsRec';
import getWrapperClassCommFormLists from '@salesforce/apex/CommunityLeadFormController.getWrapperClassCommFormList';
import creatCommFormLeadRecords1 from '@salesforce/apex/CommunityLeadFormController.creatCommFormLeadRecord111';
import saveBase64File from '@salesforce/apex/CommunityLeadFormController.saveBase64File';
import saveBase64FileAcc from '@salesforce/apex/CommunityLeadFormController.saveBase64FileAcc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import DMS_NAMES from '@salesforce/apex/LoanApplicationFormHelper.DMSNames';

export default class DocumentChild extends LightningElement {
    
    @wire(DMS_NAMES)
    dmsNames;
    @api dmsNames
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
    @api recordId;
    @api leadRecordId;

    //Show/Hide 
    @track ShowFieldsEmpTypeStud = false;
    @track ShowFieldsEmpTypeHomemaker = false;
    @track ShowFieldsEmpTypeSalaried = false;
    @track ShowFieldsEmpTypeSEP = false;
    @track ShowFieldsEmpTypeSENonP = false;
    @track ShowFieldsEmpTypeRetired = false;
    @track ShowFieldsapplicantNameAssetIsIncome = false;
    @track ShowFieldsapplicantNameLiabilitiesIsIncome = false;

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
    @api objectNameAcc = 'Account';
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

    get AppliCategoryOptions() {
        return [
            { label: 'Co-applicant', value: 'Co-applicant' },
            { label: 'Guarantor', value: 'Guarantor' },
        ];
    }

    @wire(getObjectInfo, { objectApiName: '$objectName' })
    getObjectData1({ error, data }) {
        if (data) {
            if (this.recordTypeId == null)
                this.recordTypeId = data.defaultRecordTypeId;

            //Lead Authority Level
            this.apilocalAuthority = this.objectName + '.' + this.localAuthorityField;
            this.localAuthorityLabel = data.fields[this.localAuthorityField].label;

        } else if (error) {
            // Handle error
            console.log('==============Error ');
            console.log(error);
        }
    }

    //Country of Study
    @wire(getPicklistValues, { recordTypeId: '$recordTypeId', fieldApiName: '$apilocalAuthority' })
    getPicklistValues1({ error, data }) {
        
        if (data) {
            // Map picklist values
            this.localAuthorityOptions = data.values.map(plValue => {
                return {
                    label: plValue.label,
                    value: plValue.value
                };
            });
            console.log('==============localAuthorityOptions  ' + data);

        } else if (error) {
            // Handle error
            console.log('==============Error  ' + error);
            console.log(error);
        }
    }

    //Account Picklist field from SFDC
    @wire(getObjectInfo, { objectApiName: '$objectNameAcc' })
    getObjectData2({ error, data }) {
        console.log('Inside objectApiName: Account');
        console.log('objectApiName' + this.objectApiName);
        if (data) {
            console.log('Inside if');
            if (this.recordTypeId1 == null)
                console.log('Inside recordTypeId1');
            this.recordTypeId1 = data.defaultRecordTypeId;
            console.log('Inside this.recordTypeId1' + this.recordTypeId1); //its Non indivial acc recordtpye     

            //Employment Type from Account from SFDC
            this.apiEmploymentTypePerAcc = this.objectNameAcc + '.' + this.EmploymentTypePerAccField;
            this.EmploymentTypePerAccLabel = data.fields[this.EmploymentTypePerAccField].label;

            //No. of Years with current employer from Account from SFDC 
            this.apiNumYearsCurrEmployerPerAcc = this.objectNameAcc + '.' + this.NumYearsCurrEmployerPerAccField;
            this.NumYearsCurrEmployerPerAccLabel = data.fields[this.NumYearsCurrEmployerPerAccField].label;

            //Type of Company from Account from SFDC
            this.apiTypeOfCompanyPerAcc = this.objectNameAcc + '.' + this.TypeOfCompanyPerAccField;
            this.TypeOfCompanyPerAccLabel = data.fields[this.TypeOfCompanyPerAccField].label;

            //Role in Organization from Account from SFDC
            this.apiRoleInOrgPerAcc = this.objectNameAcc + '.' + this.RoleInOrgPerAccField;
            this.RoleInOrgPerAccLabel = data.fields[this.RoleInOrgPerAccField].label;

            //Account Type from Account from SFDC
            this.apiAccTypePerAcc = this.objectNameAcc + '.' + this.AccTypePerAccField;
            this.AccTypePerAccLabel = data.fields[this.AccTypePerAccField].label;

            //Asset Type from Account from SFDC
            this.apiAssetTypePerAcc = this.objectNameAcc + '.' + this.AssetTypePerAccField;
            this.AssetTypePerAccLabel = data.fields[this.AssetTypePerAccField].label;

            //Loan Type from Account from SFDC
            this.apiLoanTypePerAcc = this.objectNameAcc + '.' + this.LoanTypePerAccField;
            this.LoanTypePerAccLabel = data.fields[this.LoanTypePerAccField].label;

        } else if (error) {
            // Handle error
            console.log('==============Error ');
            console.log(error);
        }
    }
    //Employment Type - Account 
    @wire(getPicklistValues, { recordTypeId: '$recordTypeId1', fieldApiName: '$apiEmploymentTypePerAcc' })
    getPicklistValues017({ error, data }) {
        if (data) {
            // Map picklist values
            this.EmploymentTypePerAccOptions = data.values.map(plValue => {
                return {
                    label: plValue.label,
                    value: plValue.value
                };
            });
            console.log('==============EmploymentTypePerAccOptions  ' + data);

        } else if (error) {
            // Handle error
            console.log('==============Error  ' + error);
            console.log(error);
        }
    }

    //No. of Years with current employer - Account
    @wire(getPicklistValues, { recordTypeId: '$recordTypeId1', fieldApiName: '$apiNumYearsCurrEmployerPerAcc' })
    getPicklistValues018({ error, data }) {
        if (data) {
            // Map picklist values
            this.NumYearsCurrEmployerPerAccOptions = data.values.map(plValue => {
                return {
                    label: plValue.label,
                    value: plValue.value
                };
            });
            console.log('==============NumYearsCurrEmployerPerAccOptions  ' + data);

        } else if (error) {
            // Handle error
            console.log('==============Error  ' + error);
            console.log(error);
        }
    }

    //Type of Company - Account
    @wire(getPicklistValues, { recordTypeId: '$recordTypeId1', fieldApiName: '$apiTypeOfCompanyPerAcc' })
    getPicklistValues019({ error, data }) {
        if (data) {
            // Map picklist values
            this.TypeOfCompanyPerAccOptions = data.values.map(plValue => {
                return {
                    label: plValue.label,
                    value: plValue.value
                };
            });
            console.log('==============TypeOfCompanyPerAccOptions  ' + data);

        } else if (error) {
            // Handle error
            console.log('==============Error  ' + error);
            console.log(error);
        }
    }
    //Role in organisation - Account
    @wire(getPicklistValues, { recordTypeId: '$recordTypeId1', fieldApiName: '$apiRoleInOrgPerAcc' })
    getPicklistValues020({ error, data }) {
        if (data) {
            // Map picklist values
            this.RoleInOrgPerAccOptions = data.values.map(plValue => {
                return {
                    label: plValue.label,
                    value: plValue.value
                };
            });
            console.log('==============RoleInOrgPerAccOptions  ' + data);

        } else if (error) {
            // Handle error
            console.log('==============Error  ' + error);
            console.log(error);
        }
    }
    //Account Type - Account
    @wire(getPicklistValues, { recordTypeId: '$recordTypeId1', fieldApiName: '$apiLoanTypePerAcc' })
    getPicklistValues021({ error, data }) {
        if (data) {
            // Map picklist values
            this.AccTypePerAccOptions = data.values.map(plValue => {
                return {
                    label: plValue.label,
                    value: plValue.value
                };
            });
            console.log('==============AccTypePerAccOptions  ' + data);

        } else if (error) {
            // Handle error
            console.log('==============Error  ' + error);
            console.log(error);
        }
    }
    //Asset Type - Account
    @wire(getPicklistValues, { recordTypeId: '$recordTypeId1', fieldApiName: '$apiAssetTypePerAcc' })
    getPicklistValues022({ error, data }) {
        if (data) {
            // Map picklist values
            this.AssetTypePerAccOptions = data.values.map(plValue => {
                return {
                    label: plValue.label,
                    value: plValue.value
                };
            });
            console.log('==============AssetTypePerAccOptions  ' + data);

        } else if (error) {
            // Handle error
            console.log('==============Error  ' + error);
            console.log(error);
        }
    }
    //Loan Type - Account
    @wire(getPicklistValues, { recordTypeId: '$recordTypeId1', fieldApiName: '$apiLoanTypePerAcc' })
    getPicklistValues023({ error, data }) {
        if (data) {
            // Map picklist values
            this.LoanTypePerAccOptions = data.values.map(plValue => {
                return {
                    label: plValue.label,
                    value: plValue.value
                };
            });
            console.log('==============LoanTypePerAccOptions  ' + data);

        } else if (error) {
            // Handle error
            console.log('==============Error  ' + error);
            console.log(error);
        }
    }

    connectedCallback() {
       
        console.log("names ",this.dmsNames);
        console.log("mydata" + this.mydata);
        console.log("mydataforrec" + JSON.stringify(this.records));
        this.initData();

    }
    initData() {
        let listOfEmploymentTable = [];
        this.createRowEmployment(listOfEmploymentTable);
        this.listOfEmploymentTable = listOfEmploymentTable;

        // let listOfLoanTable = [];
        // this.createRowLoan(listOfLoanTable);
        // this.listOfLoanTable = listOfLoanTable;

        let listOfFinancialTable = [];
        this.createRowFinancial(listOfFinancialTable);
        this.listOfFinancialTable = listOfFinancialTable;
        let documentTable = [];
        this.createRowFinancial(documentTable);
        this.documentTable = documentTable;

        let listOfAssetTable = [];
        this.createRowAsset(listOfAssetTable);
        this.listOfAssetTable = listOfAssetTable;

        let listOfLiabilitiesTable = [];
        this.createRowLiabilities(listOfLiabilitiesTable);
        this.listOfLiabilitiesTable = listOfLiabilitiesTable;

        let listOfCollateralTable = [];
        this.createRowCollateral(listOfCollateralTable);
        this.listOfCollateralTable = listOfCollateralTable;

        let listOfReferenceTable = [];
        this.createRowReference(listOfReferenceTable);
        this.listOfReferenceTable = listOfReferenceTable;
    }

    //Employment Table List for Add/Delete
    createRowEmployment(listOfEmploymentTable) {
        let EmploymentData = {};
        if (listOfEmploymentTable.length > 0) {
            EmploymentData.index = listOfEmploymentTable[listOfEmploymentTable.length - 1].index + 1;
            console.log("EmploymentData====>" + JSON.stringify(EmploymentData));
            console.log("listOfEmploymentTable====>" + JSON.stringify(listOfEmploymentTable));
        } else {
            EmploymentData.index = 1;
        }

        // this.ShowFieldsEmpTypeSalaried =false;
        EmploymentData.Asset_Type__c = null;
        EmploymentData.Asset_Value__c = null;
        EmploymentData.Asset_Description__c = null;
        listOfEmploymentTable.push(EmploymentData);
    }
    addNewRowEmployment() {
        this.createRowEmployment(this.listOfEmploymentTable);
        // this.ShowFieldsEmpTypeSalaried=false;
        console.log("Clickkkkkkkkkk")

    }
    removeTheRowEmployment(event) {
        let sum = 0;

        for (let i = 0; i < this.listOfEmploymentTable.length; i++) {
            sum += this.listOfEmploymentTable[i].index;
        }
        if (sum == 1) {
            console.log("Not Possible")
        } else {
            let toBeDeletedRowIndex = event.target.name;

            let listOfEmploymentTable = [];
            for (let i = 0; i < this.listOfEmploymentTable.length; i++) {
                let tempRecord = Object.assign({}, this.listOfEmploymentTable[i]); //cloning object
                if (tempRecord.index !== toBeDeletedRowIndex) {
                    listOfEmploymentTable.push(tempRecord);
                }
            }

            for (let i = 0; i < listOfEmploymentTable.length; i++) {
                listOfEmploymentTable[i].index = i + 1;
            }

            this.listOfEmploymentTable = listOfEmploymentTable;
        }
    }

    //Loan Details Table List for Add/Delete
    // createRowLoan(listOfLoanTable) {
    //     let LoanData = {};
    //     if (listOfLoanTable.length > 0) {
    //         LoanData.index = listOfLoanTable[listOfLoanTable.length - 1].index + 1;
    //     } else {
    //         LoanData.index = 1;
    //     }
    //     LoanData.Asset_Type__c = null;
    //     LoanData.Asset_Value__c = null;
    //     LoanData.Asset_Description__c = null;
    //     listOfLoanTable.push(LoanData);
    // }
    // addNewRowLoan() {
    //     this.createRowLoan(this.listOfLoanTable);
    // }
    // removeTheRowLoan(event) {
    //     let toBeDeletedRowIndex = event.target.name;

    //     let listOfLoanTable = [];
    //     for (let i = 0; i < this.listOfLoanTable.length; i++) {
    //         let tempRecord = Object.assign({}, this.listOfLoanTable[i]); //cloning object
    //         if (tempRecord.index !== toBeDeletedRowIndex) {
    //             listOfLoanTable.push(tempRecord);
    //         }
    //     }

    //     for (let i = 0; i < listOfLoanTable.length; i++) {
    //         listOfLoanTable[i].index = i + 1;
    //     }

    //     this.listOfLoanTable = listOfLoanTable;
    // }

    // Financial Details Table List for Add/Delete
    createRowFinancial(listOfFinancialTable) {
        let FinancialData = {};
        if (listOfFinancialTable.length > 0) {
            FinancialData.index = listOfFinancialTable[listOfFinancialTable.length - 1].index + 1;
        } else {
            FinancialData.index = 1;
        }
        FinancialData.Asset_Type__c = null;
        FinancialData.Asset_Value__c = null;
        FinancialData.Asset_Description__c = null;
        listOfFinancialTable.push(FinancialData);
    }
    addNewRowFinancial() {
        this.createRowFinancial(this.listOfFinancialTable);

    }
    removeTheRowFinancial(event) {
        let sum = 0;

        for (let i = 0; i < this.listOfFinancialTable.length; i++) {
            sum += this.listOfFinancialTable[i].index;
        }
        if (sum == 1) {
            console.log("Not Possible")
        } else {

            let toBeDeletedRowIndex = event.target.name;

            let listOfFinancialTable = [];
            for (let i = 0; i < this.listOfFinancialTable.length; i++) {
                let tempRecord = Object.assign({}, this.listOfFinancialTable[i]); //cloning object
                if (tempRecord.index !== toBeDeletedRowIndex) {
                    listOfFinancialTable.push(tempRecord);
                }
            }

            for (let i = 0; i < listOfFinancialTable.length; i++) {
                listOfFinancialTable[i].index = i + 1;
            }

            this.listOfFinancialTable = listOfFinancialTable;
        }
    }
    createRowDocument(documentTable) {
        let documentData = {};
        if (documentTable.length > 0) {
            documentData.index = documentTable[documentTable.length - 1].index + 1;
        } else {
            documentData.index = 1;
        }

        documentTable.push(documentData);
    }
    addNewRowDocument() {
        this.createRowDocument(this.documentTable);

    }
    removeTheRowDocument(event) {
        let sum = 0;

        for (let i = 0; i < this.documentTable.length; i++) {
            sum += this.documentTable[i].index;
        }
        if (sum == 1) {
            console.log("Not Possible")
        } else {

            let toBeDeletedRowIndex = event.target.name;

            let listOfDocumentTable = [];
            for (let i = 0; i < this.documentTable.length; i++) {
                let tempRecord = Object.assign({}, this.documentTable[i]); //cloning object
                if (tempRecord.index !== toBeDeletedRowIndex) {
                    listOfDocumentTable.push(tempRecord);
                }
            }

            for (let i = 0; i < listOfDocumentTable.length; i++) {
                listOfDocumentTable[i].index = i + 1;
            }

            this.documentTable = listOfDocumentTable;
        }
    }

    //Asset Table List for Add/Delete
    createRowAsset(listOfAssetTable) {
        let assetData = {};
        if (listOfAssetTable.length > 0) {
            assetData.index = listOfAssetTable[listOfAssetTable.length - 1].index + 1;
        } else {
            assetData.index = 1;
        }
        assetData.Asset_Type__c = null;
        assetData.Asset_Value__c = null;
        assetData.Asset_Description__c = null;
        listOfAssetTable.push(assetData);
    }
    addNewRowAsset() {
        this.createRowAsset(this.listOfAssetTable);
    }
    removeTheRowAsset(event) {
        let sum = 0;

        for (let i = 0; i < this.listOfAssetTable.length; i++) {
            sum += this.listOfAssetTable[i].index;
        }

        if (sum == 1) {
            console.log("Not Possible")

        } else {

            let toBeDeletedRowIndex = event.target.name;

            let listOfAssetTable = [];
            for (let i = 0; i < this.listOfAssetTable.length; i++) {
                let tempRecord = Object.assign({}, this.listOfAssetTable[i]); //cloning object
                if (tempRecord.index !== toBeDeletedRowIndex) {
                    listOfAssetTable.push(tempRecord);
                }
            }

            for (let i = 0; i < listOfAssetTable.length; i++) {
                listOfAssetTable[i].index = i + 1;
            }

            this.listOfAssetTable = listOfAssetTable;
        }
    }
    //Liabilities Table List for Add/Delete
    createRowLiabilities(listOfLiabilitiesTable) {
        let LiabilitiesData = {};
        if (listOfLiabilitiesTable.length > 0) {
            LiabilitiesData.index = listOfLiabilitiesTable[listOfLiabilitiesTable.length - 1].index + 1;
        } else {
            LiabilitiesData.index = 1;
        }
        LiabilitiesData.Asset_Type__c = null;
        LiabilitiesData.Asset_Value__c = null;
        LiabilitiesData.Asset_Description__c = null;
        listOfLiabilitiesTable.push(LiabilitiesData);
    }
    addNewRowLiabilities() {
        this.createRowAsset(this.listOfLiabilitiesTable);
    }
    removeTheRowLiabilities(event) {
        let sum = 0;

        for (let i = 0; i < this.listOfLiabilitiesTable.length; i++) {
            sum += this.listOfLiabilitiesTable[i].index;
        }
        if (sum == 1) {
            console.log("Not Possible")
        } else {

            let toBeDeletedRowIndex = event.target.name;

            let listOfLiabilitiesTable = [];
            for (let i = 0; i < this.listOfLiabilitiesTable.length; i++) {
                let tempRecord = Object.assign({}, this.listOfLiabilitiesTable[i]); //cloning object
                if (tempRecord.index !== toBeDeletedRowIndex) {
                    listOfLiabilitiesTable.push(tempRecord);
                }
            }

            for (let i = 0; i < listOfLiabilitiesTable.length; i++) {
                listOfLiabilitiesTable[i].index = i + 1;
            }

            this.listOfLiabilitiesTable = listOfLiabilitiesTable;
        }
    }

    //Collateral Table List for Add/Delete
    createRowCollateral(listOfCollateralTable) {
        let CollateralData = {};
        if (listOfCollateralTable.length > 0) {
            CollateralData.index = listOfCollateralTable[listOfCollateralTable.length - 1].index + 1;
        } else {
            CollateralData.index = 1;
        }
        CollateralData.Asset_Type__c = null;
        CollateralData.Asset_Value__c = null;
        CollateralData.Asset_Description__c = null;
        listOfCollateralTable.push(CollateralData);
    }
    addNewRowCollateral() {
        this.createRowCollateral(this.listOfCollateralTable);
    }
    removeTheRowCollateral(event) {
        let sum = 0;

        for (let i = 0; i < this.listOfCollateralTable.length; i++) {
            sum += this.listOfCollateralTable[i].index;
        }
        if (sum == 1) {
            console.log("Not Possible")
        } else {

            let toBeDeletedRowIndex = event.target.name;

            let listOfCollateralTable = [];
            for (let i = 0; i < this.listOfCollateralTable.length; i++) {
                let tempRecord = Object.assign({}, this.listOfCollateralTable[i]); //cloning object
                if (tempRecord.index !== toBeDeletedRowIndex) {
                    listOfCollateralTable.push(tempRecord);
                }
            }

            for (let i = 0; i < listOfCollateralTable.length; i++) {
                listOfCollateralTable[i].index = i + 1;
            }

            this.listOfCollateralTable = listOfCollateralTable;
        }
    }

    //Reference Table List for Add/Delete
    createRowReference(listOfReferenceTable) {
        let ReferenceData = {};
        if (listOfReferenceTable.length > 0) {
            ReferenceData.index = listOfReferenceTable[listOfReferenceTable.length - 1].index + 1;
        } else {
            ReferenceData.index = 1;
        }
        ReferenceData.Asset_Type__c = null;
        ReferenceData.Asset_Value__c = null;
        ReferenceData.Asset_Description__c = null;
        listOfReferenceTable.push(ReferenceData);
    }
    addNewRowReference() {
        this.createRowReference(this.listOfReferenceTable);
    }
    removeTheRowReference(event) {
        let sum = 0;

        for (let i = 0; i < this.listOfReferenceTable.length; i++) {
            sum += this.listOfReferenceTable[i].index;
        }
        if (sum == 1) {
            console.log("Not Possible")
        } else {

            let toBeDeletedRowIndex = event.target.name;

            let listOfReferenceTable = [];
            for (let i = 0; i < this.listOfReferenceTable.length; i++) {
                let tempRecord = Object.assign({}, this.listOfReferenceTable[i]); //cloning object
                if (tempRecord.index !== toBeDeletedRowIndex) {
                    listOfReferenceTable.push(tempRecord);
                }
            }

            for (let i = 0; i < listOfReferenceTable.length; i++) {
                listOfReferenceTable[i].index = i + 1;
            }

            this.listOfReferenceTable = listOfReferenceTable;
        }
    }
    handleEmploymentTypeSelect(event) {
        //TABLE TARGETS FORMAT
        let index = event.target.dataset.id;
        console.log('Index' + index);
        let fieldName = event.target.name;
        let value = event.target.value;
        console.log('value' + value);
        //Employment table handlechange
        // for(let i = 0; i < this.listOfEmploymentTable.length; i++) {
        //     if(this.listOfEmploymentTable[i].index === parseInt(index)) {
        //         this.listOfEmploymentTable[i][fieldName] = value;
        //         console.log("event.target.valueaaa====  " + this.listOfEmploymentTable[i][fieldName]);        
        //     }
        // }    
        console.log('fieldName' + fieldName);
        console.log('this.listOfEmploymentTable[index][fieldName]' + this.listOfEmploymentTable[index - 1]);
        this.listOfEmploymentTable[index - 1][fieldName] = value;
        console.log('this.listOfEmploymentTable[index][fieldName]' + this.listOfEmploymentTable[index - 1][fieldName]);
        //Show hide Salaried
        if (event.target.value === "Salaried") {
            this.ShowFieldsEmpTypeSalaried = true;
            console.log("this.ShowFieldsEmpTypeSalaried====  " + this.ShowFieldsEmpTypeSalaried);
            // console.log("indeeeexxxxx " + this.index);
        }
        else {
            this.ShowFieldsEmpTypeSalaried = false;
            console.log("this.ShowFieldsEmpTypeSalaried====  " + this.ShowFieldsEmpTypeSalaried);
        }

        // //Show hide Homemaker
        // if (event.target.value !=="Homemaker"){
        //     this.ShowFieldsEmpTypeStud = true;
        //     console.log("this.ShowFieldsEmpTypeStud====  " + this.ShowFieldsEmpTypeStud);
        // } 
        // else{
        //     this.ShowFieldsEmpTypeStud = false;
        //     console.log("this.ShowFieldsEmpTypeStud====  " + this.ShowFieldsEmpTypeStud);
        // }  

        // //Show hide Student
        // if (event.target.value !=="Student"){
        //     this.ShowFieldsEmpTypeHomemaker = true;
        //     console.log("this.ShowFieldsEmpTypeHomemaker====  " + this.ShowFieldsEmpTypeHomemaker);
        // } 
        // else{
        //     this.ShowFieldsEmpTypeHomemaker = false;
        //     console.log("this.ShowFieldsEmpTypeHomemaker====  " + this.ShowFieldsEmpTypeHomemaker);
        // }          

        //Show hide Self Employed Professional(SEP)
        if (event.target.value === "Self Employed Professional(SEP)") {
            this.ShowFieldsEmpTypeSEP = true;
            console.log("this.ShowFieldsEmpTypeSEP====  " + this.ShowFieldsEmpTypeSEP);
        }
        else {
            this.ShowFieldsEmpTypeSEP = false;
            console.log("this.ShowFieldsEmpTypeSEP====  " + this.ShowFieldsEmpTypeSEP);
        }

        //Show hide Self Employed Non Professional(SENP)
        if (event.target.value === "Self Employed Non Professional(SENP)") {
            this.ShowFieldsEmpTypeSENonP = true;
            console.log("this.ShowFieldsEmpTypeSENonP====  " + this.ShowFieldsEmpTypeSENonP);
        }
        else {
            this.ShowFieldsEmpTypeSENonP = false;
            console.log("this.ShowFieldsEmpTypeSENonP====  " + this.ShowFieldsEmpTypeSENonP);
        }

        //Show hide Retired
        if (event.target.value === "Retired") {
            this.ShowFieldsEmpTypeRetired = true;
            console.log("this.ShowFieldsEmpTypeRetired====  " + this.ShowFieldsEmpTypeRetired);
        }
        else {
            this.ShowFieldsEmpTypeRetired = false;
            console.log("this.ShowFieldsEmpTypeRetired====  " + this.ShowFieldsEmpTypeRetired);
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
                console.log("event.target.valueaaa====  " + this.listOfEmploymentTable[i][fieldName]);
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
                console.log("event.target.valueaaa====  " + this.listOfEmploymentTable[i][fieldName]);
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
                console.log("event.target.valueaaa====  " + this.listOfEmploymentTable[i][fieldName]);
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
                console.log("event.target.valueaaa====  " + this.listOfEmploymentTable[i][fieldName]);
            }
        }
    }

    handlechange(event) {

        //TABLE TARGETS FORMAT
        let index = event.target.dataset.id;
        let fieldName = event.target.name;
        let value = event.target.value;

        //Loan table handlechange
        // for (let i = 0; i < this.listOfLoanTable.length; i++) {
        //     if (this.listOfLoanTable[i].index === parseInt(index)) {
        //         this.listOfLoanTable[i][fieldName] = value;
        //         console.log("event.target.valueaaa====  " + this.listOfLoanTable[i][fieldName]);
        //     }
        // }

        //Financial table handlechange
        for (let i = 0; i < this.listOfFinancialTable.length; i++) {
            if (this.listOfFinancialTable[i].index === parseInt(index)) {
                this.listOfFinancialTable[i][fieldName] = value;
                console.log("event.target.valueaaa====  " + this.listOfFinancialTable[i][fieldName]);
            }
        }
        for (let i = 0; i < this.documentTable.length; i++) {
            if (this.documentTable[i].index === parseInt(index)) {
                this.documentTable[i][fieldName] = value;
                console.log("event.target.valueaaa====  " + this.documentTable[i][fieldName]);
            }
        }

        //Asset table handlechange
        for (let i = 0; i < this.listOfAssetTable.length; i++) {
            if (this.listOfAssetTable[i].index === parseInt(index)) {
                this.listOfAssetTable[i][fieldName] = value;
                console.log("event.target.valueaaa====  " + this.listOfAssetTable[i][fieldName]);
            }
        }

        //Liabilities table handlechange
        for (let i = 0; i < this.listOfLiabilitiesTable.length; i++) {
            if (this.listOfLiabilitiesTable[i].index === parseInt(index)) {
                this.listOfLiabilitiesTable[i][fieldName] = value;
                console.log("event.target.valueaaa====  " + this.listOfLiabilitiesTable[i][fieldName]);
            }
        }

        //Collateral table handlechange
        for (let i = 0; i < this.listOfCollateralTable.length; i++) {
            if (this.listOfCollateralTable[i].index === parseInt(index)) {
                this.listOfCollateralTable[i][fieldName] = value;
                console.log("event.target.valueaaa====  " + this.listOfCollateralTable[i][fieldName]);
            }
        }

        //Reference table handlechange
        for (let i = 0; i < this.listOfReferenceTable.length; i++) {
            if (this.listOfReferenceTable[i].index === parseInt(index)) {
                this.listOfReferenceTable[i][fieldName] = value;
                console.log("event.target.valueaaa====  " + this.listOfReferenceTable[i][fieldName]);
            }
        }


    }
    // @track applicantFieldLookField;
    // get applicantFieldLook() {
    //     return [
    //         { label: this.salutation + " "+ this.LfNName, value: this.salutation + " "+ this.LfNName },

    //     ];
    // }
    //  @track AppliWithLeadNameoptions;
    //  @track Picklist_Value;
    //@track l_All_Types;
    @track TypeOptions;
    @track isIncomeConsideroptions;

    @wire(getleadWithApplicantsRecord, {})
    WiredObjects_Type({ error, data }) {
        console.log("namess"+JSON.stringify(this.records))
        console.log('datatest' + JSON.stringify(data));
        if (data) {


            try {
                // this.l_All_Types = data; 
                let options = [];
                let optionsisIncomeCon = [];
                console.log('datatest2', data);
                let newObj = [];
                for (var gg in data) {
                    newObj.push({ value: data[gg].Id, type: data[gg].Type__c })
                    console.log("tryyyyy", newObj)
                }

                for (var key in data) {
                    // Here key will have index of list of records starting from 0,1,2,....
                    options.push({ label: data[key].Account__r.Name, value: data[key].Id, type: data[key].Type__c,accountId:data[key].Account__c,leadId:data[key].lead__c });
                    console.log('datatest3' + data[key].Account__r.Name + data[key].Id);
                    console.log('datatest33333', options);
                    // Here Name and Id are fields from sObject list.
                    
                }
                let coApplicantCount = 0;
                for( var i in options){
                    if(options[i].type ==="Co-applicant"){
                        coApplicantCount++;
                        options[i].index = coApplicantCount;
                    }
                }
                this.TypeOptions = options;
                console.log('this.TypeOptions======>  ' + JSON.stringify(this.TypeOptions));

                for (var keys in data) {
                    // Here key will have index of list of records starting from 0,1,2,....
                    optionsisIncomeCon.push({ label: data[keys].Name, value: data[keys].Lead__r.Is_Income_Considered_Is_Financial__c });
                    console.log('optionsisIncomeCondatatest4==>' + data[keys].Name + data[keys].Lead__r.Is_Income_Considered_Is_Financial__c);
                    // Here Name and Id are fields from sObject list.
                }
                this.isIncomeConsideroptions = optionsisIncomeCon;
                console.log('this.isIncomeConsideroptions======>  ' + JSON.stringify(this.isIncomeConsideroptions));

            } catch (error) {
                console.error('check error here', error);
            }
        } else if (error) {
            console.error('check error here', error);
        }
        //     if (data) {

        //         this.TypeOptions = data.values.map(plValue => {
        //                 console.log('this.TypeOptions======>  ' +  this.TypeOptions);
        //                 return {
        //                     label: plValue.name,
        //                     value: plValue.id
        //                 };

        //             });
        //                 console.log('this.TypeOptions======>  ' +  this.TypeOptions);  
        // } else if (error) {
        //     console.error('check error here', error);
        // }


        // if (data) {
        //     // Map picklist values
        //     this.AppliWithLeadNameoptions = data.values.map(plValue => {
        //         console.log('his.AppliWithLeadNameoptions======>  ' +  this.AppliWithLeadNameoptions);
        //         return {
        //             label: plValue.name,
        //             value: plValue.id
        //         };

        //     });
        //     console.log('his.AppliWithLeadNameoptions======>  ' +  this.AppliWithLeadNameoptions);
        // } else if (error) {
        //     // Handle error
        //     console.log('==============Error  ' + error);
        //     console.log(error);
        // }
    }
    handleTypeChange(event) {
        this.value = event.target.value;
        console.log('==============this.value  ' + this.value);

        //Show hide applicantNameAsset
        if (event.target.name === "applicantNameAsset" && event.target.value === "Yes") {
            this.ShowFieldsapplicantNameAssetIsIncome = true;
            console.log("this.ShowFieldsapplicantNameAssetIsIncome====  " + this.ShowFieldsapplicantNameAssetIsIncome);
        }
        else {
            this.ShowFieldsapplicantNameAssetIsIncome = false;
            console.log("this.ShowFieldsapplicantNameAssetIsIncome====  " + this.ShowFieldsapplicantNameAssetIsIncome);
        }

        //Show hide applicantNameLiabilities
        if (event.target.name === "applicantNameLiabilities" && event.target.value === "Yes") {
            this.ShowFieldsapplicantNameLiabilitiesIsIncome = true;
            console.log("this.ShowFieldsapplicantNameLiabilitiesIsIncome====  " + this.ShowFieldsapplicantNameLiabilitiesIsIncome);
        }
        else {
            this.ShowFieldsapplicantNameLiabilitiesIsIncome = false;
            console.log("this.ShowFieldsapplicantNameLiabilitiesIsIncome====  " + this.ShowFieldsapplicantNameLiabilitiesIsIncome);
        }

    }

    //Aqeel code put 28-Feb Loan Section

    handlechangeLoan(event) {
        if (event.target.name === 'Expected Tuition Fees') {
            this.loanExpecTuitionFees = event.target.value;
        } else if (event.target.name === 'Living Expenses/Hostel and Food') {
            this.loanLivExpHostelFoodExp = event.target.value;
        } else if (event.target.name === 'Travelling Expenses') {
            this.loanTravelExp = event.target.value;
        } else if (event.target.name === 'Others') {
            this.loanOtherCost = event.target.value;

        }
        this.total();
        this.calculateLoanRequired();

    }
    handlechangeFund(event) {
        if (event.target.name === 'Own Source') {
            this.loanOwnSource = event.target.value;
        } else if (event.target.name === 'Scholarship') {
            this.loanScholarship = event.target.value;
        } else if (event.target.name === 'Other Funds') {
            this.loanOtherFunds = event.target.value;
        }
        this.loanTotalFunndsSum = parseFloat(this.loanOwnSource || 0) + parseFloat(this.loanScholarship || 0)
            + parseFloat(this.loanOtherFunds || 0);
        this.calculateLoanRequired();
    }
    total() {
        let totalCost = parseFloat(this.loanExpecTuitionFees || 0) +
            parseFloat(this.loanLivExpHostelFoodExp || 0) +
            parseFloat(this.loanTravelExp || 0) +
            parseFloat(this.loanOtherCost || 0);
        this.loanTotalCostSum = totalCost;
    }
    calculateLoanRequired() {
        this.loanLoanRequiredAB = this.loanTotalCostSum - this.loanTotalFunndsSum;
    }
    @track leadIDLoan;
    @track loanExpecTuitionFees;
    @track loanLivExpHostelFoodExp;
    @track loanTravelExp;
    @track loanOtherCost;
    @track loanTotalCostSum;
    @track loanOwnSource;
    @track loanScholarship;
    @track loanOtherFunds;
    @track loanTotalFunndsSum;
    @track loanLoanRequiredAB;

    @wire(getWrapperClassCommFormLists, {})
    wiredWrapperClassCommFormList1({ error, data }) {
        console.log('dataTest1CHILD====>' + JSON.stringify(data));
        if (data) {
            console.log('data CHILD inside If' + data);
            this.wrapperForCommLeadForm = data;
            console.log('CHILD wrapperForCommLeadForm data' + JSON.stringify(this.wrapperForCommLeadForm));

            //Applicant Loan requirement on Lead  
            this.leadIDLoan = this.wrapperForCommLeadForm.LeadRecords.Id;
            console.log('this.leadIDLoan data===>' + this.leadIDLoan);
            this.loanExpecTuitionFees = this.wrapperForCommLeadForm.LeadRecords.Tuition_Fees__c;
            this.loanLivExpHostelFoodExp = this.wrapperForCommLeadForm.LeadRecords.Living_Hostel_Food_Expenses__c;
            this.loanTravelExp = this.wrapperForCommLeadForm.LeadRecords.Traveling_Expenses__c;
            this.loanOtherCost = this.wrapperForCommLeadForm.LeadRecords.Other_Costs__c;
            this.loanTotalCostSum = parseInt(this.loanExpecTuitionFees) + parseInt(this.loanLivExpHostelFoodExp) + parseInt(this.loanTravelExp) + parseInt(this.loanOtherCost);
            this.loanOwnSource = this.wrapperForCommLeadForm.LeadRecords.Own_Source__c;
            this.loanScholarship = this.wrapperForCommLeadForm.LeadRecords.Scholarship__c;
            this.loanOtherFunds = this.wrapperForCommLeadForm.LeadRecords.Others_Fund__c;
            this.loanTotalFunndsSum = parseInt(this.loanOwnSource) + parseInt(this.loanScholarship) + parseInt(this.loanOtherFunds)
            this.loanLoanRequiredAB = this.wrapperForCommLeadForm.LeadRecords.Loan_Required_A_B__c;
            console.log(error);
            this.error = error;
        }
        // if(this.AppliMaritlStatus == "Married"){
        //     this.ShowFieldsAppliSpouse = true;
        // }
        // else{
        //     this.ShowFieldsAppliSpouse = false;
        // }
    }

    handleSaveLeadLoan() {
        let loanSecLeadSaveRec = {
            Id: this.leadIDLoan,
            Tuition_Fees__c: this.loanExpecTuitionFees,
            Living_Hostel_Food_Expenses__c: this.loanLivExpHostelFoodExp,
            Traveling_Expenses__c: this.loanTravelExp,
            Other_Costs__c: this.loanOtherCost,
            Total_Costs__c: this.loanTotalCostSum,
            Own_Source__c: this.loanOwnSource,
            Scholarship__c: this.loanScholarship,
            Others_Fund__c: this.loanOtherFunds,
            Total_Funds__c: this.loanTotalFunndsSum,
            Loan_Required_A_B__c: this.loanLoanRequiredAB
        }
        console.log('loanSecLeadSaveRec=====>' + JSON.stringify(loanSecLeadSaveRec));

        //Wrapper Class variable
        let wrapperCommFormRecord1 = {
            loanSectionLeadRec: JSON.stringify(loanSecLeadSaveRec)
        }
        console.log('wrapperCommFormRecord1 child=====>' + JSON.stringify(wrapperCommFormRecord1));

        creatCommFormLeadRecords1({
            wrapperCommFormDetails111: JSON.stringify(wrapperCommFormRecord1)
        })
            .then(response => {
                console.log(response);
                if (response != null) {
                    console.log('child response inside if=====>' + response);
                }
                this.isLoading = false;
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Success',
                        message: 'Successfully Saved',
                        variant: 'Success',
                    }),
                );
            }).catch(error => {
                console.log(error);
                this.isLoading = false;
            })
    }
    @track temApplicant;
    @track temCoApplicant;
    @track typeofapp;

    @track IdDoc;
    categoryChange(event) {
        console.log(event.target.value)
        console.log("gggggggggg   " + JSON.stringify(this.TypeOptions))

        for (var i in this.TypeOptions) {
            let newpost = this.TypeOptions[i].value
            console.log("hiiaaiaiaiiiiiiiiiiiiii " + newpost);
            if (event.target.value == this.TypeOptions[i].value) {
                this.typeofapp = this.TypeOptions[i].type
                this.IdDoc = this.TypeOptions[i].value
                console.log("fgfgfgfggf " + this.typeofapp)
                console.log("idddddddd " + this.IdDoc)
            }
        }
        if (this.typeofapp == "Applicant") {
            this.temApplicant = true;
            console.log("hello I am applicant");
        } else {
            this.temApplicant = false;
        }
        if (this.typeofapp == "Co-applicant") {
            console.log("hello I am coooo---applicant");
            this.temCoApplicant = true;
        } else {
            this.temCoApplicant = false;
        }
    }
    @track fileData = [];
    @track tempName;
    @track fileDataFront = false;
    openFrontfileUpload(event,fileName) {
        let file = event.target.files[0]
        let reader = new FileReader()
        reader.onload = () => {
            let base64 = reader.result.split(',')[1]
            console.log(base64);
            let fullName = fileName +  file.type.split('/')[1];
            saveBase64File({ 
                leadId: this.lead_id,
                accountId: this.accid,
                base64File: base64,
                fileName: fullName,
            })
            .then(result => {
                console.log('File saved successfully',result);
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Success',
                        message: 'File Uploaded Successfully',
                        variant: 'success',
                    })
                );
            })
            .catch(error => {
                console.error("error",error);
                console.error(error.message);
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Error',
                        message: 'Error Uploading File',
                        variant: 'error',
                    })
                );
            });
            saveBase64FileAcc({
                leadId:this.lead_id,
                accountId: this.accid,
               
                base64File: base64,
                fileName: fullName,
            })
            .then(result => {
                console.log('File saved successfully',result);
            })
            .catch(error => {
                console.error("error",error);
            });
           

          
            this.fileDataFront = true;
        }
        reader.onerror = () => {
            const event = new ShowToastEvent({
                title: 'Error',
                message: 'File Not Uploaded',
                variant: 'error',
            });
            this.dispatchEvent(event);
        };
         // Create a new file object with the renamed file
        const newFile = new File([file], fileName, { type: file.type });

        reader.readAsDataURL(newFile);
    }
    
    
   
    @track aadharTemp;
    @track apAadharback=false;
    aadharFrontName;
    aadharBackName;
    appdoc1=false;
    aadharFront(event) {
        const fileName = "Aadhar_card_App_1.";
        this.openFrontfileUpload(event,fileName);
        this.appdoc1 = true;
        let file = event.target.files[0]
        this.aadharFrontName = file.name
    }
    aadharBack(event) {
        const fileName = "Aadhar_card_back_App_1.";
        this.openFrontfileUpload(event,fileName);
        this.apAadharback = true;
        let file = event.target.files[0]
        this.aadharBackName = file.name
    }
    doc3;
    doc3name;
    passportFront(event) {
        const fileName = "passport_App_1.";
        this.openFrontfileUpload(event,fileName);
        this.doc3 = true;
        let file = event.target.files[0]
        this.doc3name = file.name
    }
    doc4;
    doc4name;
    passportBack(event) {
        const fileName = "passport_back_App_1.";
        this.openFrontfileUpload(event,fileName);
        this.doc4 = true;
        let file = event.target.files[0]
        this.doc4name = file.name
    }
    doc5;
    doc5name;
    visaApp(event) {
        const fileName = "Viva_copy_App_1.";
        this.openFrontfileUpload(event,fileName);
        this.doc5 = true;
        let file = event.target.files[0]
        this.doc5name = file.name
    }
    doc6;
    doc6name;
    panApp(event) {
        const fileName = "pan_card_App_1.";
        this.openFrontfileUpload(event,fileName);
        this.doc6 = true;
        let file = event.target.files[0]
        this.doc6name = file.name
    }
    doc7;
    doc7name;
    voterFront(event) {
        const fileName = "voter_card_App_1.";
        this.openFrontfileUpload(event,fileName);
        this.doc7 = true;
        let file = event.target.files[0]
        this.doc7name = file.name
    }
    doc8;
    doc8name;
    voterBack(event) {
        const fileName = "voter_card_back_App_1.";
        this.openFrontfileUpload(event,fileName);
        this.doc8 = true;
        let file = event.target.files[0]
        this.doc8name = file.name
    }
    doc9;
    doc9name;
    dlFront(event) {
        const fileName = "Driving_license_App_1.";
        this.openFrontfileUpload(event,fileName);
        this.doc9 = true;
        let file = event.target.files[0]
        this.doc9name = file.name
    }
    doc10;
    doc10name;
    dlBack(event) {
        const fileName = "Driving_license_back_App_1.";
        this.openFrontfileUpload(event,fileName);
        this.doc10 = true;
        let file = event.target.files[0]
        this.doc10name = file.name
    }
    doc11;
    doc11name;
    bankStatementApp(event) {
        const fileName = "Bank_statement_App_1.";
        this.openFrontfileUpload(event,fileName);
        this.doc11 = true;
        let file = event.target.files[0]
        this.doc11name = file.name
    }
    doc12;
    doc12name;
    photoApp(event) {
        const fileName = "Photo_App_1.";
        this.openFrontfileUpload(event,fileName);
        this.doc12 = true;
        let file = event.target.files[0]
        this.doc12name = file.name;
    }
    doc13;
    doc13name;
    incomeApp(event) {
        const fileName = "Income_Proof_App_1.";
        this.openFrontfileUpload(event,fileName);
        this.doc13 = true;
        let file = event.target.files[0]
        this.doc13name = file.name
    }
    doc14;
    doc14name;
    otherApp1(event) {
        const fileName = "other_1_App_1.";
        this.openFrontfileUpload(event,fileName);
        this.doc14 = true;
        let file = event.target.files[0]
        this.doc14name = file.name
    }
    doc15;
    doc15name;
    otherApp2(event) {
        const fileName = "other_2_App_1.";
        this.openFrontfileUpload(event,fileName);
        this.doc15 = true;
        let file = event.target.files[0]
        this.doc15name = file.name
    }
    doc16;
    doc16name;
    otherApp3(event) {
        const fileName = "other_3_App_1.";
        this.openFrontfileUpload(event,fileName);
        this.doc16 = true;
        let file = event.target.files[0]
        this.doc16name = file.name
    }
    doc17;
    doc17name;
    sscApp(event) {
        const fileName = "SSC_score_App_1.";
        this.openFrontfileUpload(event,fileName);
        this.doc17 = true;
        let file = event.target.files[0]
        this.doc17name = file.name
    }
    doc18;
    doc18name;
    hscApp(event) {
        const fileName = "HSC_score_App_1.";
        this.openFrontfileUpload(event,fileName);
        this.doc18 = true;
        let file = event.target.files[0]
        this.doc18name = file.name
    }
    doc19;
    doc19name;
    graduationApp(event) {
        const fileName = "Graduation_score_App_1.";
        this.openFrontfileUpload(event,fileName);
        this.doc19 = true;
        let file = event.target.files[0]
        this.doc19name = file.name
    }
    doc20;
    doc20name;
    otherAppGradu(event) {
        const fileName = "Other_score_App_1.";
        this.openFrontfileUpload(event,fileName);
        this.doc20 = true;
        let file = event.target.files[0]
        this.doc20name = file.name
    }
    doc21;
    doc21name;
    testScore(event) {
        const fileName = "Test_score_App_1.";
        this.openFrontfileUpload(event,fileName);
        this.doc21 = true;
        let file = event.target.files[0]
        this.doc21name = file.name
    }
    doc22;
    doc22name;
    anaScore(event) {
        const fileName = "Analytical_score_App_1.";
        this.openFrontfileUpload(event,fileName);
        this.doc22 = true;
        let file = event.target.files[0]
        this.doc22name = file.name
    }
    //--------------Co-Applicants---------------//
    doc23;
    doc23name;
    aadharFront1(event) {
        const fileName = "new_file_name"+this.coAppIndex+".";
        this.openFrontfileUpload(event,fileName);
        this.doc23 = true;
        let file = event.target.files[0]
        this.doc23name = file.name
    }
    doc24;
    doc24name;
    back1(event) {
        const fileName = "new_file_name"+this.coAppIndex+".";
        this.openFrontfileUpload(event,fileName);
        this.doc24 = true;
        let file = event.target.files[0]
        this.doc24name = file.name
    }
    doc25;
    doc25name;
    pass1(event) {
        const fileName = "new_file_name"+this.coAppIndex+".";
        this.openFrontfileUpload(event,fileName);
        this.doc25 = true;
        let file = event.target.files[0]
        this.doc25name = file.name
    }
    doc26;
    doc26name;
    pass2(event) {
        const fileName = "new_file_name"+this.coAppIndex+".";
        this.openFrontfileUpload(event,fileName);
        this.doc26 = true;
        let file = event.target.files[0]
        this.doc26name = file.name
    }
    doc27;
    doc27name;
    photo1(event) {
        const fileName = "new_file_name"+this.coAppIndex+".";
        this.openFrontfileUpload(event,fileName);
        this.doc27 = true;
        let file = event.target.files[0]
        this.doc27name = file.name
    }
    doc27;
    doc27name;
    photo1(event) {
        const fileName = "new_file_name"+this.coAppIndex+".";
        this.openFrontfileUpload(event,fileName);
        this.doc27 = true;
        let file = event.target.files[0]
        this.doc27name = file.name
    }
    doc28;
    doc28name;
    pan1(event) {
        const fileName = "new_file_name"+this.coAppIndex+".";
        this.openFrontfileUpload(event,fileName);
        this.doc28 = true;
        let file = event.target.files[0]
        this.doc28name = file.name
    }
    doc29;
    doc29name;
    vid1(event) {
        const fileName = "new_file_name"+this.coAppIndex+".";
        this.openFrontfileUpload(event,fileName);
        this.doc29 = true;
        let file = event.target.files[0]
        this.doc29name = file.name
    }
    doc30;
    doc30name;
    vid2(event) {
        const fileName = "new_file_name"+this.coAppIndex+".";
        this.openFrontfileUpload(event,fileName);
        this.doc30 = true;
        let file = event.target.files[0]
        this.doc30name = file.name
    }
    doc31;
    doc31name;
    bank8(event) {
        const fileName = "new_file_name"+this.coAppIndex+".";
        this.openFrontfileUpload(event,fileName);
        this.doc31 = true;
        let file = event.target.files[0]
        this.doc31name = file.name
    }
    doc32;
    doc32name;
    income1(event) {
        const fileName = "new_file_name"+this.coAppIndex+".";
        this.openFrontfileUpload(event,fileName);
        this.doc32 = true;
        let file = event.target.files[0]
        this.doc32name = file.name
    }
    doc33;
    doc33name;
    ot11(event) {
        const fileName = "new_file_name"+this.coAppIndex+".";
        this.openFrontfileUpload(event,fileName);
        this.doc33 = true;
        let file = event.target.files[0]
        this.doc33name = file.name
    }
    doc34;
    doc34name;
    ot22(event) {
        const fileName = "new_file_name"+this.coAppIndex+".";
        this.openFrontfileUpload(event,fileName);
        this.doc34 = true;
        let file = event.target.files[0]
        this.doc34name = file.name
    }
    doc35;
    doc35name;
    ot33(event) {
        const fileName = "new_file_name"+this.coAppIndex+".";
        this.openFrontfileUpload(event,fileName);
        this.doc35 = true;
        let file = event.target.files[0]
        this.doc35name = file.name
    }

    @track toggler=false;
    @track Cotoggler=false;
    @track typeValue;
    coAppIndex;
    accid;
    lead_id;
    handleAccordionClick(event){
        console.log(event.detail.openSections);
        console.log("======"+this.recordId);
        for (var i in this.TypeOptions) {
            if (event.detail.openSections == this.TypeOptions[i].value) {
                debugger
               console.log("inside if  ");
               this.typeValue = this.TypeOptions[i].value;
               if( this.TypeOptions[i].type ==="Applicant"){
                    this.toggler=true;
                    console.log(this.TypeOptions[i].type);
                    this.accid = this.TypeOptions[i].accountId
                    this.lead_id = this.TypeOptions[i].value
                
                }else{
                    this.toggler=false;
                }
                if( this.TypeOptions[i].type==="Co-applicant"){
                    this.Cotoggler=true;
                    console.log( this.TypeOptions[i].type);
                    this.coAppIndex=this.TypeOptions[i].index;
                    this.accid = this.TypeOptions[i].accountId
                    this.lead_id = this.TypeOptions[i].value
                }else{
                    this.Cotoggler=false;
                }
               
            }
        }
       
    }
}