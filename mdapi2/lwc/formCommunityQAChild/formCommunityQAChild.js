import { LightningElement, wire, api, track } from 'lwc';
import { getPicklistValues, getObjectInfo } from 'lightning/uiObjectInfoApi';
import getleadWithApplicantsRecord from '@salesforce/apex/TempControllerSohail.getleadWithApplicantsRec';
import getWrapperClassCommFormLists from '@salesforce/apex/TempControllerSohail.getWrapperClassCommFormList';
import creatCommFormLeadRecords1 from '@salesforce/apex/TempControllerSohail.creatCommFormLeadRecord111';
import getBranchRecord from '@salesforce/apex/TempControllerSohail.getBranchRecord';
import saveFinancialData from '@salesforce/apex/TempControllerSohail.saveFinancialData';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

export default class CommunityFormARSChild extends LightningElement {
    @track isLoading = false;
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

    //for bank 
    @track BankName;
    @track BranchId;
    @track BranchResult;
    @track BankName;
    @track MICR_Code__c;

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
    @wire(getPicklistValues, { recordTypeId: '$recordTypeId1', fieldApiName: '$apiAccTypePerAcc' })
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
        console.log("mydata" + this.mydata);
        this.initData();

    }
    initData() {
        // let listOfEmploymentTable = [];
        // this.createRowEmployment(listOfEmploymentTable);
        // this.listOfEmploymentTable = listOfEmploymentTable;

        // let listOfLoanTable = [];
        // this.createRowLoan(listOfLoanTable);
        // this.listOfLoanTable = listOfLoanTable;

        // let listOfFinancialTable = [];
        // this.createRowFinancial(listOfFinancialTable);
        // this.listOfFinancialTable = listOfFinancialTable;
        let documentTable = [];
        this.createRowFinancial(documentTable);
        this.documentTable = documentTable;

        // let listOfAssetTable = [];
        // this.createRowAsset(listOfAssetTable);
        // this.listOfAssetTable = listOfAssetTable;

        // let listOfLiabilitiesTable = [];
        // this.createRowLiabilities(listOfLiabilitiesTable);
        // this.listOfLiabilitiesTable = listOfLiabilitiesTable;

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
            console.log(FinancialData.index);
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
        console.log('fieldName' + fieldName);
        console.log('this.listOfEmploymentTable[index][fieldName]' + this.listOfEmploymentTable[index - 1]);
        this.listOfEmploymentTable[index - 1][fieldName] = value;
        console.log('this.listOfEmploymentTable[index][fieldName]' + this.listOfEmploymentTable[index - 1][fieldName]);
        //Show hide Salaried

        //var foundelement = this.listOfEmploymentTable.find(ele => ele.Id == event.target.dataset.id);

        if (event.target.value === "Salaried") {
            //this.ShowFieldsEmpTypeSalaried = true;
            this.emptypesalraiedtrue = true;
            //foundelement.emptypesalraiedtrue = true;
           // console.log("this.ShowFieldsEmpTypeSalaried====  " + this.ShowFieldsEmpTypeSalaried);
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
        console.log(index);
        console.log(value);
        

        //Loan table handlechange
        // for (let i = 0; i < this.listOfLoanTable.length; i++) {
        //     if (this.listOfLoanTable[i].index === parseInt(index)) {
        //         this.listOfLoanTable[i][fieldName] = value;
        //         console.log("event.target.valueaaa====  " + this.listOfLoanTable[i][fieldName]);
        //     }
        // }

        //Financial table handlechange
        for (let i = 0; i < this.listOfFinancialTable.length; i++) {
            console.log(this.listOfFinancialTable[i].index);
            console.log(parseInt(index));
            if (this.listOfFinancialTable[i].index === parseInt(index)) {
                this.listOfFinancialTable[i][fieldName] = value;
                console.log("event.target.valueaaa====  " + JSON.stringify(this.listOfFinancialTable)); //[i][fieldName]);
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

    //For financial section change
    handleChangeFinancial(event){
        var foundelement = this.listOfFinancialTable.find(ele => ele.Id == event.currentTarget.dataset.id);
        console.log(JSON.stringify(foundelement));
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
    @track norecordfound = false;
    @wire(getleadWithApplicantsRecord, {})
    WiredObjects_Type({ error, data }) {
        console.log('datatest' + JSON.stringify(data));
        if (data) {
           
           
            try {
                // this.l_All_Types = data; 
                 let options = [];
                let optionsisIncomeCon = [];
                console.log('datatest2' , data);
                 let newObj=[];
                for (var gg in data) {
                    newObj.push({ value: data[gg].Id,type:data[gg].Type__c})
                    console.log("tryyyyy",newObj)
                }
                
                for (var key in data) {
                    // Here key will have index of list of records starting from 0,1,2,....
                    options.push({ label: data[key].Account__r.Name, value: data[key].Id , type:data[key].Type__c });
                    console.log('datatest3' + data[key].Account__r.Name + data[key].Id);
                    console.log('datatest33333', options);
                    // Here Name and Id are fields from sObject list.
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

    handleBranchSelection(event){
        console.log('Bank branch selected');
        this.BranchId = event.target.value;
        console.log(event.target.value);

        getBranchRecord({ branch: this.BranchId })
        .then(result => {
            console.log('In branch section',JSON.stringify(result));
            this.BranchResult = result;
            
            console.log('branchResult=======> ' + JSON.stringify(this.BranchResult));

            this.BankName = this.BranchResult.Bank__c;
            this.MICR_Code__c = this.BranchResult.MICR__c;
        })
        .catch(error => {
            this.errors = error;
            console.log('errors=======> ' + this.errors);
        });
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
        if (event.target.name == 'ExpectedTuitionFees') {
            this.loanExpecTuitionFees = event.target.value;  
            console.log('dthis.loanExpecTuitionFees handle====>', this.loanExpecTuitionFees);   
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
            this.loanOwnSource =  event.target.value;
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
        if(this.loanExpecTuitionFees == '' || this.loanExpecTuitionFees == undefined){
            this.loanTotalCostSum = 0;
        }else{
            this.loanTotalCostSum = totalCost;
        }
        
    }
    calculateLoanRequired() {
        if(this.loanTotalCostSum == 0){
            this.loanLoanRequiredAB = 0;
        }else{
            this.loanLoanRequiredAB = this.loanTotalCostSum - this.loanTotalFunndsSum;
        }
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
    @track testempoly;
    //@track employsalariedtype = 'Salaried';
    @track emptypesalraiedtrue = true;
    @track emptypeSEProfessional = false;
    @track emptypeSENonProfessional = false;
    @track emptypeRetired = false;
    @track emptypestudenttrue = false;
    @track eploymentrecordfound = false;
    @track eploymentrecordnotfound = false;

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
           console.log('TUSTION FEES : ' +this.loanExpecTuitionFees);
           this.loanLivExpHostelFoodExp = this.wrapperForCommLeadForm.LeadRecords.Living_Hostel_Food_Expenses__c;
           this.loanTravelExp = this.wrapperForCommLeadForm.LeadRecords.Traveling_Expenses__c;
           this.loanOtherCost = this.wrapperForCommLeadForm.LeadRecords.Other_Costs__c;
           this.loanTotalCostSum = parseInt(this.loanExpecTuitionFees) + parseInt(this.loanLivExpHostelFoodExp) + parseInt(this.loanTravelExp) +parseInt(this.loanOtherCost);
            this.loanOwnSource = this.wrapperForCommLeadForm.LeadRecords.Own_Source__c;
            this.loanScholarship = this.wrapperForCommLeadForm.LeadRecords.Scholarship__c;
            this.loanOtherFunds = this.wrapperForCommLeadForm.LeadRecords.Others_Fund__c;
            this.loanTotalFunndsSum = parseInt(this.loanOwnSource) + parseInt(this.loanScholarship) + parseInt(this.loanOtherFunds)
            this.loanLoanRequiredAB = this.wrapperForCommLeadForm.LeadRecords.Loan_Required_A_B__c;

            //Eployment Record
            if(this.wrapperForCommLeadForm.EmploymentRecord.length > 0){
                this.eploymentrecordfound = true;
                console
               this.listOfEmploymentTable  = JSON.parse(JSON.stringify(this.wrapperForCommLeadForm.EmploymentRecord));
               console.log("Start Employment" + JSON.parse(JSON.stringify(this.wrapperForCommLeadForm.EmploymentRecord)));

            this.listOfEmploymentTable.forEach(function(employment){
                try{
                    if(employment.Employment_Type__c == 'Salaried'){
                        employment['emptypesalraiedtrue'] = true; 
                    }else{
                        employment['emptypesalraiedtrue'] = false; 
                    }
                    if(employment.Employment_Type__c == 'Self Employed Professional(SEP)'){
                        employment['emptypeSEProfessional'] = true;
                    }else{
                        employment['emptypeSEProfessional'] = false; 
                    }
                    if(employment.Employment_Type__c == 'Self Employed non Professional(SENP)'){
                        employment['emptypeSENonProfessional'] = true;
                    }else{
                        employment['emptypeSENonProfessional'] = false; 
                    }
                    if(employment.Employment_Type__c == 'Retired'){
                        employment['emptypeRetired'] = true;
                    }else{
                        employment['emptypeRetired'] = false; 
                    }
                    
                }catch(e){}
              });
            }else{
                this.eploymentrecordnotfound = true;
            //    // this.norecordfound = true;
            //    let randomId = Math.random() * 16;
            //  let myNewElement = { Id: randomId,Employment_Type__c: ""};
            //     console.log("myNewElement===>" + myNewElement);        
            //     this.listOfEmploymentTable = [myNewElement];
            //     console.log("this.listOfEmploymentTable updated===>" + this.listOfEmploymentTable);
            }

           //Change for financial section
            if(this.wrapperForCommLeadForm.bankAccount.length > 0){
                this.listOfFinancialTable  = JSON.parse(JSON.stringify(this.wrapperForCommLeadForm.bankAccount)); 
            }else{

             let randomId = Math.random() * 16;
             let myNewElement = { Id: randomId,Account_Holder_Name__c: "", Account_Number__c: "", Account_Operational_Since__c: "",Account_Type__c: "",Bank_Branch_IFSC__c: "",Name_of_Bank__c: ""};
                console.log("myNewElement===>" + myNewElement);        
                this.listOfFinancialTable = [myNewElement];
                console.log("this.listOfFinancialTable updated===>" + this.listOfFinancialTable); 
            }

            //Change for financial section
            if(this.wrapperForCommLeadForm.assetDetails.length > 0){
                this.listOfAssetTable  = JSON.parse(JSON.stringify(this.wrapperForCommLeadForm.assetDetails)); 
            }else{

             let randomId = Math.random() * 16;
             let myNewElement = { Id: randomId,Asset_Type__c: "", Price: "", Description: ""};
                console.log("myNewElement===>" + myNewElement);        
                this.listOfAssetTable = [myNewElement];
                console.log("this.listOfFinancialTable updated===>" + this.listOfAssetTable); 

            }

            //Change for financial section
            if(this.wrapperForCommLeadForm.liabilityDetails.length > 0){
                this.listOfLiabilitiesTable  = JSON.parse(JSON.stringify(this.wrapperForCommLeadForm.liabilityDetails)); 
            }else{

             let randomId = Math.random() * 16;
             let myNewElement = { Id: randomId,Loan_Type__c: "",Monthly_Installment__c: "",Original_Amount__c: "",Outstanding_Amount__c: "",Balance_Tenure_In_Months__c:""};
                console.log("myNewElement===>" + myNewElement);        
                this.listOfLiabilitiesTable = [myNewElement];
                console.log("this.listOfFinancialTable updated===>" + this.listOfLiabilitiesTable); 

            }
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
        console.log('this.loanExpecTuitionFees=====>' , this.loanExpecTuitionFees);
        if(this.loanExpecTuitionFees == '' || this.loanExpecTuitionFees == undefined || this.loanExpecTuitionFees == 0){           
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Error!!',
                    message: 'Please enter Expected Tuition Fees',
                    variant: 'Error',
                }),
            );
        }else{
            this.isLoading = true;
            let loanSecLeadSaveRec = {
                Id : this.leadIDLoan,
                Tuition_Fees__c : this.loanExpecTuitionFees,
                Living_Hostel_Food_Expenses__c : this.loanLivExpHostelFoodExp,
                Traveling_Expenses__c : this.loanTravelExp,
                Other_Costs__c : this.loanOtherCost,
                Total_Costs__c : this.loanTotalCostSum,
                Own_Source__c : this.loanOwnSource,
                Scholarship__c :  this.loanScholarship,
                Others_Fund__c : this.loanOtherFunds,
                Total_Funds__c : this.loanTotalFunndsSum,
                Loan_Required_A_B__c : this.loanLoanRequiredAB
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
                            title: 'Sucess',
                        message: 'Successfully Saved',
                        variant: 'Success',
                        }),
                    );
                }).catch(error => {
                    console.log(error);
                    this.isLoading = false;
                })
        }
        
    }

    //To save financial section
    handleSaveFinancial(){
        console.log('Saving financial section');
        console.log('financial section:'+JSON.stringify(this.listOfFinancialTable));
        console.log('financial section:'+JSON.stringify(this.listOfAssetTable));
        console.log('financial section:'+JSON.stringify(this.listOfLiabilitiesTable));
        saveFinancialData({
            financialData: this.listOfFinancialTable,
            assetData: this.listOfAssetTable,
            liabilityData: this.listOfLiabilitiesTable
        })
        .then(response => {
            console.log(response);
        
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Sucess',
                message: 'Successfully Saved',
                variant: 'Success',
                }),
            );
        }).catch(error => {
            console.log(error);
            this.isLoading = false;
        })
        console.log('Financial section saved');
    }
    @track temApplicant;
    @track temCoApplicant;
    @track typeofapp;
    

    categoryChange(event){
        // this.category=event.target.value
        console.log(event.target.value)
        console.log("gggggggggg   "+JSON.stringify(this.TypeOptions))
        
        for(var i in this.TypeOptions){
            if(event.target.value==this.TypeOptions[i].value){
                this.typeofapp = this.TypeOptions[i].type
                console.log("fgfgfgfggf "+this.typeofapp)
            }
        }
        if(this.typeofapp == "Applicant"){
            this.temApplicant = true;
           
           
           
          console.log("hello I am applicant");
        }else{
            
            this.temApplicant = false;
        }
        if(this.typeofapp == "Co-applicant"){
            console.log("hello I am coooo---applicant");
           
            this.temCoApplicant = true;
          
        }else{
            this.temCoApplicant = false;
        }
            
    }

    handleSuccess = (event) =>{
        console.log("inside Save "+ event.detail.error);
       // event.preventDefault();
        
        this.dispatchEvent(
            new ShowToastEvent({
                title: 'success',
                message:'Employment created successfully.',
                variant:'success'
            })
        ).catch(err => {
            console.log("Error Saving data ",err);
        })
        
    }
}