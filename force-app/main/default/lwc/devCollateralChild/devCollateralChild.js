import { LightningElement, wire, api, track } from 'lwc';
import { getPicklistValues, getObjectInfo } from 'lightning/uiObjectInfoApi';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

import getleadWithApplicantsRecForAsset from '@salesforce/apex/LoanApplicationFormHelper.getleadWithApplicantsRecForAsset';
import getPincodeRecord from '@salesforce/apex/LoanApplicationFormHelper.getPincodeRecord';
import getCollateralAssetList from '@salesforce/apex/LoanApplicationFormHelper.getCollateralAssetList';
import createCollateralSave from '@salesforce/apex/LoanApplicationFormHelper.createCollateralSave';
import getLeadTotalPercentage from '@salesforce/apex/DocumentVerification.getLeadTotalPercentage';
import updateLeadTotalPercentage from '@salesforce/apex/DocumentVerification.updateLeadTotalPercentage';
import deleteCollateral from '@salesforce/apex/LoanApplicationFormHelper.deleteCollateral';
import getMovableCollTypeRecords from '@salesforce/apex/LoanApplicationFormHelper.getMovableCollTypeRecords';
import getImmovableCollTypeRecords from '@salesforce/apex/LoanApplicationFormHelper.getImmovableCollTypeRecords';

import SUBMITACTION from '@salesforce/messageChannel/submit__c';
import progressBar from '@salesforce/messageChannel/progressBar__c';
import { publish, MessageContext } from 'lightning/messageService';

export default class CollateralChild extends LightningElement {
    @api leadRecordId;
    @track isLoading = false;
    @wire(MessageContext)
    messageContext;
    message;
    //Show/Hide 
    @track ShowCollateralFDBankBal = false;
    @track ShowCollateralResiPlotComm = false;
    @track CollateralRecordFound = false;

    @track listOfCollateralTable;
    @track TypeOptionsCollateral;

    //Collateral(Asset) Picklist values 
    @api objectNameAsset = 'Asset';
    @api recordTypeId3;

    //Local Authority Asset 
    @track localAuthority;
    @api localAuthorityField = 'Local_Authority__c';
    @track localAuthorityLabel;
    @api localAuthorityValue;
    @track localAuthorityOptions;
    apilocalAuthority;

    //Local Authority Asset 
    @track typeOfSecurityCollAsset;
    @api typeOfSecurityCollAssetField = 'Collateral_Type__c';
    @track typeOfSecurityCollAssetLabel;
    @api typeOfSecurityCollAssetValue;
    @track typeOfSecurityCollAssetOptions;
    apitypeOfSecurityCollAsset;

    //Security Offered
    @track SecurityOfferedChecked = false;
    @track isModalOpen = false;
    @track securityOfferedShowHide = false;
    @track saveButtonShowHide = false;
    @track isDelete = false;
    @track AreaPinCodeAssetColl;
    @track AreaPinCodeResultAssetColl;
    @track deleteCollateralIds = '';
    @track movableCollTypeRecords = [];
    @track immovableCollTypeRecords = [];

  
    //Local Authority Picklist
    @wire(getObjectInfo, { objectApiName: '$objectNameAsset' })
    getObjectData501({ error, data }) {
        if (data) {
            if (this.recordTypeId3 == null)
                this.recordTypeId3 = data.defaultRecordTypeId;

            //Collateral Asset Authority Level
            this.apilocalAuthority = this.objectNameAsset + '.' + this.localAuthorityField;
            this.localAuthorityLabel = data.fields[this.localAuthorityField].label;

            //Collateral Asset Type of Security
            this.apitypeOfSecurityCollAsset = this.objectNameAsset + '.' + this.typeOfSecurityCollAssetField;
            this.typeOfSecurityCollAssetLabel = data.fields[this.typeOfSecurityCollAssetField].label;

        } else if (error) {
            // Handle error
            console.log('==============Error', error);
        }
    }

    //Collateral Asset Authority Level
    @wire(getPicklistValues, { recordTypeId: '$recordTypeId3', fieldApiName: '$apilocalAuthority' })
    getPicklistValues501({ error, data }) {
        if (data) {
            // Map picklist values
            this.localAuthorityOptions = data.values.map(plValue => {
                return {
                    label: plValue.label,
                    value: plValue.value
                };
            });

        } else if (error) {
            // Handle error
            console.log('==============Error  ' + error);
        }
    }
    //Collateral Asset Type of Security
    @wire(getPicklistValues, { recordTypeId: '$recordTypeId3', fieldApiName: '$apitypeOfSecurityCollAsset' })
    getPicklistValues502({ error, data }) {
        if (data) {
            // Map picklist values
            this.typeOfSecurityCollAssetOptions = data.values.map(plValue => {
                return {
                    label: plValue.label,
                    value: plValue.value
                };
            });

        } else if (error) {
            // Handle error
            console.log('==============Error  ' + error);
        }
    }

    //Fetch movable records of collateral type    
    // @wire(getMovableCollTypeRecords)
    // wiredMovableCollTypeRecords({ data, error }) {
    //     if (data) {
    //         this.movableCollTypeRecords = data;
    //     } else if (error) {
    //         console.log('Error fetching movable collateral types:', JSON.stringify(error));
    //     }
    // }

    //Fetch immovable records of collateral type
    // @wire(getImmovableCollTypeRecords)
    // wiredImmovableCollTypeRecords({ data, error }) {
    //     if (data) {
    //         this.immovableCollTypeRecords = data;
    //     } else if (error) {
    //         console.log('Error fetching immovable collateral types:', JSOn.stringify(error));
    //     }
    // }

    //Called on refresh/onload
    connectedCallback() {
        this.callgetMovableCollTypeRecords(() => {
            this.callgetImmovableCollTypeRecords(() => {
                console.log('CAL getCollateralAssetFunction');
                this.getCollateralAssetFunction();
            });
        });
    }

    callgetMovableCollTypeRecords(callback) {
        //Fetch movable records of collateral type  
        getMovableCollTypeRecords()
            .then(result => {
                console.log('getMovableCollTypeRecords==>', JSON.stringify(result));
                this.movableCollTypeRecords = result;
                callback();
            })
            .catch(error => {
                console.log('Error while fetching data:' + JSON.stringify(error));
            })
    }

    callgetImmovableCollTypeRecords(callback) {
        //Fetch immovable records of collateral type
        getImmovableCollTypeRecords()
            .then(result => {
                console.log('getImmovableCollTypeRecords==>', JSON.stringify(result));
                this.immovableCollTypeRecords = result;
                callback();
            })
            .catch(error => {
                console.log('Error while fetching data:' + JSON.stringify(error));
            })        
    }

    //Method for get Applicant and get List of Asset Records
    getCollateralAssetFunction() {
        //debugger;
        //To get Account Names from Applicant object
        getleadWithApplicantsRecForAsset({ leadGetId: this.leadRecordId })
        .then(result => {
            let options = [];
            let newObj = [];
            for (var gg in result) {
                newObj.push({ value: result[gg].Id, type: result[gg].Type__c })
            }
            for (var key in result) {
                options.push({ label: result[key].Account__r.Name, value: result[key].Account__c, type: result[key].Type__c, leadId: result[key].Lead__r.Id });
            }
            this.TypeOptionsCollateral = options;
        })
        .catch(error => {
            console.log('Error while fetching Account Names from SF:'+JSON.stringify(error));
        });

        //To get the existing asset records for this lead
        getCollateralAssetList({ leadGetId: this.leadRecordId })
        .then(result => {
            if (result) {
                this.listOfCollateralTable = JSON.parse(JSON.stringify(result));

                if (this.listOfCollateralTable.length > 0) {

                    //this.listOfCollateralTable = JSON.parse(JSON.stringify(this.listOfCollateralTable));
                    this.saveButtonShowHide = true;
                    this.SecurityOfferedChecked = true;
                    this.securityOfferedShowHide = true;

                    this.listOfCollateralTable.forEach((collateralAsset) => {
                        try {
                            const selectedCollTypeMovable = this.movableCollTypeRecords.find(record => record.CollateralType__c === collateralAsset.Collateral_Type__c);
                            const selectedCollTypeImmovable = this.immovableCollTypeRecords.find(record => record.CollateralType__c === collateralAsset.Collateral_Type__c);

                            console.log('mov table'+this.movableCollTypeRecords);
                            console.log('immov table'+this.immovableCollTypeRecords)
                            console.log('mavable value'+selectedCollTypeMovable);
                            console.log('immovable value:'+selectedCollTypeImmovable);
                            if (selectedCollTypeMovable || selectedCollTypeImmovable) {
                                console.log('Mavable data');
                                collateralAsset.ShowCollateralFDBankBal = true;
                                console.log('check var1'+collateralAsset.ShowCollateralFDBankBal);
                            } 
                            else {
                                collateralAsset.ShowCollateralFDBankBal = false;
                                console.log('check var2'+collateralAsset.ShowCollateralFDBankBal);
                            }

                            if (selectedCollTypeImmovable) {
                                console.log('ImMavable data');
                                collateralAsset.ShowCollateralResiPlotComm = true;
                                console.log('check var3'+collateralAsset.ShowCollateralResiPlotComm);
                            } 
                            else {
                                collateralAsset.ShowCollateralResiPlotComm = false;
                                console.log('check var4'+collateralAsset.ShowCollateralResiPlotComm);
                            }

                        } 
                        catch (e) {
                            console.log('Exception: '+e)
                        }
                    });
                }

                else {
                    let randomId = Math.random() * 16;
                    let myNewElement = {
                        Id: randomId, AccountId: "", Collateral_Type__c: "", Asset_Value__c: "", Area_Sq_Ft__c: "", Local_Authority__c: "", Building_House_Name__c: "",
                        Building_House_No__c: "", Wing__c: "", Floor__c: "", Survey_Plot_No__c: "", Pin_Code__c: null, City__c: "", Area_Taluka_District_Area_name__c: "", State__c: "", Country__c: "", Landmark__c: ""
                    };
                    this.listOfCollateralTable = [...this.listOfCollateralTable, myNewElement];
                    this.saveButtonShowHide = false;
                    this.SecurityOfferedChecked = false;
                    this.securityOfferedShowHide = false;
                }

                console.log(error);
                this.error = error;
                if (this.listOfCollateralTable.length > 0) {
                    this.listOfCollateralTable.length + 1;
                }
            }
        })
        .catch(error => {
            console.log('Error while getting asset data: '+JSON.stringify(error));
        });
    }
    
    //Handle change for Collateral type
    handleAssetCollType(event) {
        var foundelement = this.listOfCollateralTable.find(ele => ele.Id == event.target.dataset.id);

        //To get the previous record's data
        const prevSelectedCollTypeMovable = this.movableCollTypeRecords.find(record => record.CollateralType__c === foundelement.Collateral_Type__c);
        const prevSelectedCollTypeImmovable = this.immovableCollTypeRecords.find(record => record.CollateralType__c === foundelement.Collateral_Type__c);

        if (event.target.name == 'Collateral_Type__c') {
            foundelement.Collateral_Type__c = event.target.value;

            if (isNaN(foundelement.Id)) {
                console.log('To delete the field value');
                if(prevSelectedCollTypeMovable){
                    foundelement.Asset_Value__c = '';
                }

                if(prevSelectedCollTypeImmovable){
                    foundelement.Asset_Value__c = '';
                    foundelement.Area_Sq_Ft__c = '';
                    foundelement.Local_Authority__c = '';
                    foundelement.Building_House_Name__c = '';
                    foundelement.Building_House_No__c = '';
                    foundelement.Wing__c = '';
                    foundelement.Floor__c = '';
                    foundelement.Survey_Plot_No__c = '';
                    foundelement.Pin_Code__c = null;
                    foundelement.City__c = '';
                    foundelement.Area_Taluka_District_Area_name__c = '';
                    foundelement.State__c = '';
                    foundelement.Country__c = '';
                    foundelement.Landmark__c = '';
                }
            }     
            
            //To get the current record's data
            const currSelectedCollTypeMovable = this.movableCollTypeRecords.find(record => record.CollateralType__c === foundelement.Collateral_Type__c);
            const currSelectedCollTypeImmovable = this.immovableCollTypeRecords.find(record => record.CollateralType__c === foundelement.Collateral_Type__c);  

            if (currSelectedCollTypeMovable || currSelectedCollTypeImmovable) 
                foundelement.ShowCollateralFDBankBal = true;
            else 
                foundelement.ShowCollateralFDBankBal = false;
            
            if(currSelectedCollTypeImmovable) 
                foundelement.ShowCollateralResiPlotComm = true;
            else 
                foundelement.ShowCollateralResiPlotComm = false;     
        }
    }

    //Handle change for fields of collateral
    handlechangeAssetCollateral(event) {
        var foundelement = this.listOfCollateralTable.find(ele => ele.Id == event.target.dataset.id);

        if (event.target.name == 'Asset_Value__c') {
            foundelement.Asset_Value__c = event.target.value;
        }
        else if (event.target.name === 'Area_Sq_Ft__c') {
            foundelement.Area_Sq_Ft__c = event.target.value;
        }
        else if (event.target.name === 'Local_Authority__c') {
            foundelement.Local_Authority__c = event.target.value;
        }
        else if (event.target.name === 'Building_House_Name__c') {
            foundelement.Building_House_Name__c = event.target.value;
        }
        else if (event.target.name === 'Building_House_No__c') {
            foundelement.Building_House_No__c = event.target.value;
        }
        else if (event.target.name === 'Wing__c') {
            foundelement.Wing__c = event.target.value;
        }
        else if (event.target.name === 'Floor__c') {
            foundelement.Floor__c = event.target.value;
        }
        else if (event.target.name === 'Survey_Plot_No__c') {
            foundelement.Survey_Plot_No__c = event.target.value;
        }
        else if (event.target.name === 'City__c') {
            foundelement.City__c = event.target.value;
        }
        else if (event.target.name === 'Area_Taluka_District_Area_name__c') {
            foundelement.Area_Taluka_District_Area_name__c = event.target.value;
        }
        else if (event.target.name === 'State__c') {
            foundelement.State__c = event.target.value;
        }
        else if (event.target.name === 'Country__c') {
            foundelement.Country__c = event.target.value;
        }
        else if (event.target.name === 'Landmark__c') {
            foundelement.Landmark__c = event.target.value;
        }
    }

    //Handle change for pincode and add data from system to other address fields
    handleAssetCollPincode(event) {
        var foundelementAssetColl = this.listOfCollateralTable.find(ele => ele.Id == event.target.dataset.id);

        if (event.target.name == 'PincodeAssetColl') {
            foundelementAssetColl.Pin_Code__c = event.target.value;
            this.AreaPinCodeAssetColl = foundelementAssetColl.Pin_Code__c;
        }
        if (this.AreaPinCodeAssetColl == '') {
            foundelementAssetColl.Pin_Code__c = '';
            foundelementAssetColl.City__c = '';
            foundelementAssetColl.Area_Taluka_District_Area_name__c = '';
            foundelementAssetColl.State__c = '';
            foundelementAssetColl.Country__c = '';
        } else {
            //this parameter is passed to Class-CommunityLeadFormController.getPincodeRecord
            getPincodeRecord({ pincode: this.AreaPinCodeAssetColl }) 
            .then(result => {
                this.AreaPinCodeResultAssetColl = result;

                foundelementAssetColl.Pin_Code__c = this.AreaPinCodeResultAssetColl.Id;
                foundelementAssetColl.City__c = this.AreaPinCodeResultAssetColl.City_Name__c;
                foundelementAssetColl.Area_Taluka_District_Area_name__c = this.AreaPinCodeResultAssetColl.Area_Name_Taluka__c;
                foundelementAssetColl.State__c = this.AreaPinCodeResultAssetColl.State__c;
                foundelementAssetColl.Country__c = this.AreaPinCodeResultAssetColl.Country__c;
            })
            .catch(error => {
                this.errors = error;
                console.log('Error while getting pincode data from system'+ JSON.stringify(this.errors));
            });
        }
    }

    //To open the model to confirm the deletion
    openModal() {
        this.isModalOpen = true;
    }

    //To close the modal after the deletion
    closeModal() {
        this.isModalOpen = false;
        this.saveButtonShowHide = true;
        this.securityOfferedShowHide = true;

        const  element = this.template.querySelector('[data-id="securityOffered"]');
        element.checked = true;   
    }

    //To submit the data after delete selected
    submitDetails() {
        this.isDelete = true;
        this.isModalOpen = false;

        if(this.isDelete == true){
            this.listOfCollateralTable.forEach(element => {
                this.deleteCollateralIds += element.Id+','
            });

            //Calling apex method to delete asset
            deleteCollateral({ids:this.deleteCollateralIds})
            .then(result=>{

            }).catch(error=>{
                console.log('Error while deleting record :'+JSON.stringify(error));
            })

            //Remove the list and add one blank list
            this.listOfCollateralTable = null;
            let randomId = Math.random() * 16;
            let myNewElement = {
                Id: randomId, AccountId: "", Collateral_Type__c: "", Asset_Value__c: "", Area_Sq_Ft__c: "", Local_Authority__c: "", Building_House_Name__c: "",
                Building_House_No__c: "", Wing__c: "", Floor__c: "", Survey_Plot_No__c: "", Pin_Code__c: null, City__c: "", Area_Taluka_District_Area_name__c: "", State__c: "", Country__c: "", Landmark__c: ""
            };
            this.listOfCollateralTable = [myNewElement];
            this.saveButtonShowHide = false;
            this.securityOfferedShowHide = false;

            const  element = this.template.querySelector('[data-id="securityOffered"]');
            element.checked = false;
            this.isDelete = false;
        }
    }

    //Handle change for security offered checkbox
    handleSecurityOffered(event) {
        let securityCheck = event.target.checked;

        if (securityCheck == true) {
            this.SecurityOfferedChecked = securityCheck;
            this.setSecurityOfferedColl = 'Yes';
            this.securityOfferedShowHide = true;
            this.saveButtonShowHide = true;
        } 
        else {
            // Check if listOfCollateralTable has records
            if (this.listOfCollateralTable && this.listOfCollateralTable.length > 0) {
                // Check if any "Property Owned By" field is blank
                const isPropertyOwnedByBlank = this.listOfCollateralTable.some((rec) => rec.AccountId);
                if (isPropertyOwnedByBlank) {   
                    this.openModal();
                    
                } 
                else {
                    this.securityOfferedShowHide = false;
                    this.saveButtonShowHide = false;
                    this.SecurityOfferedChecked = false;
                }
            } else {
                this.securityOfferedShowHide = false;
                this.saveButtonShowHide = false;
            }
        }
    }

    //Handle change for Property Owned by field to fetch lead and account Id
    handleTypeChangeAssetColl(event) {
        var foundelement1 = this.listOfCollateralTable.find(ele => ele.Id == event.target.dataset.id);

        if (event.target.name == 'propertyOwnedBy') {
            foundelement1.AccountId = event.target.value;
        }

        for (var i in this.TypeOptionsCollateral) {
            if (event.target.value === this.TypeOptionsCollateral[i].value) {
                foundelement1.Lead__c = this.TypeOptionsCollateral[i].leadId;
            }
        }
    }

    //Add new row to the Collateral table
    addNewRowCollateral() {
        let randomId = Math.random() * 16;
        let myNewElement = {
            Id: randomId, AccountId: "", Collateral_Type__c: "", Asset_Value__c: "", Area_Sq_Ft__c: "", Local_Authority__c: "", Building_House_Name__c: "",
            Building_House_No__c: "", Wing__c: "", Floor__c: "", Survey_Plot_No__c: "", Pin_Code__c: null, City__c: "", Area_Taluka_District_Area_name__c: "", State__c: "", Country__c: "", Landmark__c: ""
        };
        this.listOfCollateralTable = [...this.listOfCollateralTable, myNewElement];
    }

    //Delete the Collateral Row
    removeTheRowCollateral(event) {
        if (isNaN(event.target.dataset.id)) {
            this.deleteCollateralIds = this.deleteCollateralIds + ',' + event.target.dataset.id;
        }

        if (this.listOfCollateralTable.length > 1) {
            this.listOfCollateralTable.splice(this.listOfCollateralTable.findIndex(row => row.Id === event.target.dataset.id), 1);
        }
    }

    //Handle change method used for Save as draft button
    handleSaveAsDraftCollateral() {
        if (this.SecurityOfferedChecked == false) {
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Error!!',
                    message: 'Please select the "Is Security Offered?"',
                    variant: 'Error',
                }),
            );
            return;
        }

        var error1 = false;
        var error2 = false;
        var error6 = false;
        
        if (this.listOfCollateralTable.length > 0) {
            for (var i = 0; i < this.listOfCollateralTable.length; i++) {

                var record = this.listOfCollateralTable[i];
                let selectedCollTypeMovable = this.movableCollTypeRecords.find(movableRecord => movableRecord.CollateralType__c === record.Collateral_Type__c);
                let selectedCollTypeImmovable = this.immovableCollTypeRecords.find(immovableRecord => immovableRecord.CollateralType__c === record.Collateral_Type__c);
                
                if (record.Collateral_Type__c == '' || record.Collateral_Type__c == undefined || record.AccountId == '' || record.AccountId == undefined) {
                    error1 = true;
                    break;
                }
                else if ((selectedCollTypeMovable || selectedCollTypeImmovable) && (record.Asset_Value__c == '' || record.Asset_Value__c == undefined)) {
                    error2 = true;
                    break;
                }
                else if ((selectedCollTypeMovable || selectedCollTypeImmovable) && (record.Asset_Value__c < 0 || record.Asset_Value__c == 0)) {
                    error6 = true;
                    break;
                }
            }
           
            if (error1 === true) {
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Error!!',
                        message: 'Please fill the mandatory fields',
                        variant: 'Error',
                    }),
                );
            } 
            else if (error2 === true) {
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Error!!',
                        message: 'Please fill the Value field',
                        variant: 'Error',
                    }),
                );
            } 
            else if (error6 === true) {
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Error!!',
                        message: 'Please enter a valid Value (Amount)',
                        variant: 'Error',
                    }),
                );
            } 
            else {
                this.isLoading = true;

                if (this.deleteCollateralIds !== '') {
                    this.deleteCollateralIds = this.deleteCollateralIds.substring(0);
                }

                this.listOfCollateralTable.forEach(res => {
                    if (!isNaN(res.Id)) {
                        res.Id = null;
                        res.Name = res.Collateral_Type__c;
                    }
                });

                //Calls apex method to save the data
                createCollateralSave({
                    collateralRecordList: this.listOfCollateralTable,
                    removeCollateralIds: this.deleteCollateralIds,
                    leadGetId: this.leadRecordId
                })
                .then(result => {
                    this.listOfCollateralTable = JSON.parse(JSON.stringify(result));
                    if (this.listOfCollateralTable.length > 0) {
                        this.SecurityOfferedChecked = true;
                        this.listOfCollateralTable = JSON.parse(JSON.stringify(this.listOfCollateralTable));
                        this.saveButtonShowHide = true;
                        this.listOfCollateralTable.forEach((collateralAsset) => {
                            try {
                                const selectedCollTypeMovable = this.movableCollTypeRecords.find(record => record.CollateralType__c === collateralAsset.Collateral_Type__c);
                                const selectedCollTypeImmovable = this.immovableCollTypeRecords.find(record => record.CollateralType__c === collateralAsset.Collateral_Type__c);

                                if (selectedCollTypeMovable || selectedCollTypeImmovable) {
                                    collateralAsset.ShowCollateralFDBankBal = true;
                                } 
                                else {
                                    collateralAsset.ShowCollateralFDBankBal = false;
                                }

                                if (selectedCollTypeImmovable) {
                                    collateralAsset.ShowCollateralResiPlotComm = true;
                                } 
                                else {
                                    collateralAsset.ShowCollateralResiPlotComm = false;
                                }
                            }    
                            catch(e) { 
                                console.log('Exception: '+e);
                            }
                        });
                    }

                    else {
                        let randomId = Math.random() * 16;
                        let myNewElement = {
                            Id: randomId, AccountId: "", Collateral_Type__c: "", Asset_Value__c: "", Area_Sq_Ft__c: "", Local_Authority__c: "", Building_House_Name__c: "",
                            Building_House_No__c: "", Wing__c: "", Floor__c: "", Survey_Plot_No__c: "", Pin_Code__c: null, City__c: "", Area_Taluka_District_Area_name__c: "", State__c: "", Country__c: "", Landmark__c: ""
                        };
                        this.listOfCollateralTable = [...this.listOfCollateralTable, myNewElement];
                        this.saveButtonShowHide = false;
                        this.SecurityOfferedChecked = true;
                    }

                    this.isLoading = false;
                    //Progress bar data pass
                    
                    // getLeadTotalPercentage({ leadId: this.leadRecordId })
                    //     .then(result => {
                    //         let newPerc = result + 5;
                    //         let ProgrssValueOfLoanSection = { ProgrssValueOfLoanSection: newPerc };
                    //         publish(this.messageContext, progressBar, ProgrssValueOfLoanSection);

                    //         updateLeadTotalPercentage({ leadId: this.leadRecordId, percentage: newPerc })
                    //         .then(result => {
                    //             if (result === 'Success') {
                    //                 console.log('Lead updated successfully');
                    //             } 
                    //             else {
                    //                 console.error('Failed to update Lead');
                    //             }
                    //         })
                    //         .catch(error => {
                    //             console.Log('Error while updating lead form percentage: '+JSON.stringify(error));
                               
                    //         });
                    //     })
                    //     .catch(error => {
                    //         console.error('Error while getting lead form percentage: '+JSON.stringify(error));
                    //     });

                        const evt = new ShowToastEvent({
                            title: 'Collateral',
                            message: 'Successfully Saved',
                            variant: 'Success',
                        });

                        this.dispatchEvent(evt);
                    })
                    .catch(error => {
                        this.isLoading = false;
                        console.log('error while inserting record -->', error);
                    })
            }
        }
    }

    //Handle change method used for Next button 
    handleNextCollateral() {
        if (this.SecurityOfferedChecked == false) {
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Error!!',
                    message: 'Please select the "Is Security Offered?"',
                    variant: 'Error',
                }),
            );
            return;
        }

        var error1 = false;
        var error2 = false;
        var error3 = false;
        var error4 = false;
        var error5 = false;
        var error6 = false;
        var error7 = false;

        if (this.listOfCollateralTable.length > 0) {
            for (var i = 0; i < this.listOfCollateralTable.length; i++) {

                var record = this.listOfCollateralTable[i];
                let selectedCollTypeMovable = this.movableCollTypeRecords.find(movableRecord => movableRecord.CollateralType__c === record.Collateral_Type__c);
                let selectedCollTypeImmovable = this.immovableCollTypeRecords.find(immovableRecord => immovableRecord.CollateralType__c === record.Collateral_Type__c);
                
                if (record.Collateral_Type__c == '' || record.Collateral_Type__c == undefined || record.AccountId == '' || record.AccountId == undefined) {
                    error1 = true;
                    break;
                }
                else if ((selectedCollTypeMovable || selectedCollTypeImmovable) && (record.Asset_Value__c == '' || record.Asset_Value__c == undefined)) {
                    error2 = true;
                    break;
                }
                else if (selectedCollTypeImmovable && (record.Area_Sq_Ft__c == '' || record.Area_Sq_Ft__c == undefined)) {
                    error3 = true;
                    break;
                }
                else if (selectedCollTypeImmovable && (record.Local_Authority__c == '' || record.Local_Authority__c == undefined)) {
                    error4 = true;
                    break;
                }
                else if (selectedCollTypeImmovable && (record.Building_House_Name__c == '' || record.Building_House_Name__c == undefined ||
                record.Building_House_No__c == '' || record.Building_House_No__c == undefined || record.Floor__c == '' || record.Floor__c == undefined ||
                record.Survey_Plot_No__c == '' || record.Survey_Plot_No__c == undefined || record.Pin_Code__c == '' || record.Pin_Code__c == undefined)) {
                    error5 = true;
                    break;
                }
                else if ((selectedCollTypeMovable || selectedCollTypeImmovable) && (record.Asset_Value__c < 0 || record.Asset_Value__c == 0)) {
                    error6 = true;
                    break;
                }
                else if (selectedCollTypeImmovable && (record.Area_Sq_Ft__c < 0 || record.Area_Sq_Ft__c == 0)) {
                    error7 = true;
                    break;
                }
            }

            //Check for proper error and dispatch message accordingly
            if (error1 === true) {
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Error!!',
                        message: 'Please fill the mandatory fields',
                        variant: 'Error',
                    }),
                );
            } 
            else if (error2 === true) {
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Error!!',
                        message: 'Please fill the Value field',
                        variant: 'Error',
                    }),
                );
            } 
            else if (error3 === true) {
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Error!!',
                        message: 'Please fill the Area In SQ.FT field',
                        variant: 'Error',
                    }),
                );
            } 
            else if (error4 === true) {
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Error!!',
                        message: 'Please fill the Local Authority field',
                        variant: 'Error',
                    }),
                );
            } 
            else if (error5 === true) {
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Error!!',
                        message: 'Please fill the Property Details(Address) section',
                        variant: 'Error',
                    }),
                );
            } 
            else if (error6 === true) {
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Error!!',
                        message: 'Please enter a valid Value (Amount)',
                        variant: 'Error',
                    }),
                );
            } 
            else if (error7 === true) {
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Error!!',
                        message: 'Please enter a valid Area In SQ.FT ',
                        variant: 'Error',
                    }),
                );
            } 
            else {
                this.isLoading = true;

                //Get the ids of deleting record
                if (this.deleteCollateralIds !== '') {
                    this.deleteCollateralIds = this.deleteCollateralIds.substring(0);
                }

                //Iterate the table to set random id as null
                this.listOfCollateralTable.forEach(res => {
                    if (!isNaN(res.Id)) {
                        res.Id = null;
                        res.Name = res.Collateral_Type__c;
                    }
                });

                //Calls ape save method to save collateral details of this lead
                createCollateralSave({
                    collateralRecordList: this.listOfCollateralTable,
                    removeCollateralIds: this.deleteCollateralIds,
                    leadGetId: this.leadRecordId
                })
                .then(result => {
                    this.listOfCollateralTable = JSON.parse(JSON.stringify(result));
                    if (this.listOfCollateralTable.length > 0) {
                        this.SecurityOfferedChecked = true;
                        this.listOfCollateralTable = JSON.parse(JSON.stringify(this.listOfCollateralTable));
                        this.saveButtonShowHide = true;
                        this.listOfCollateralTable.forEach((collateralAsset) => {
                            try {
                                const selectedCollTypeMovable = this.movableCollTypeRecords.find(record => record.CollateralType__c === collateralAsset.Collateral_Type__c);
                                const selectedCollTypeImmovable = this.immovableCollTypeRecords.find(record => record.CollateralType__c === collateralAsset.Collateral_Type__c);

                                if (selectedCollTypeMovable || selectedCollTypeImmovable) {
                                    collateralAsset.ShowCollateralFDBankBal = true;
                                } 
                                else {
                                    collateralAsset.ShowCollateralFDBankBal = false;
                                }

                                if (selectedCollTypeImmovable) {
                                    collateralAsset.ShowCollateralResiPlotComm = true;
                                } 
                                else {
                                    collateralAsset.ShowCollateralResiPlotComm = false;
                                }

                            } 
                            catch (e) {
                                console.log('Exception:'+e);
                            }
                        });
                    }

                    else {
                        let randomId = Math.random() * 16;
                        let myNewElement = {
                            Id: randomId, AccountId: "", Collateral_Type__c: "", Asset_Value__c: "", Area_Sq_Ft__c: "", Local_Authority__c: "", Building_House_Name__c: "",
                            Building_House_No__c: "", Wing__c: "", Floor__c: "", Survey_Plot_No__c: "", Pin_Code__c: null, City__c: "", Area_Taluka_District_Area_name__c: "", State__c: "", Country__c: "", Landmark__c: ""
                        };
                        this.listOfCollateralTable = [...this.listOfCollateralTable, myNewElement];
                        this.saveButtonShowHide = false;
                        this.SecurityOfferedChecked = true;
                    }

                    this.isLoading = false;
                    //Progress bar data pass
                        
                    // getLeadTotalPercentage({ leadId: this.leadRecordId })
                    //     .then(result => {
                    //         let newPerc = result + 5;
                    //         let ProgrssValueOfLoanSection = { ProgrssValueOfLoanSection: newPerc };
                    //         console.log('ProgressValueOfLoanSection +++', ProgrssValueOfLoanSection);
                    //         publish(this.messageContext, progressBar, ProgrssValueOfLoanSection);

                    //         //Call method to update the lead form percentage
                    //         updateLeadTotalPercentage({ leadId: this.leadRecordId, percentage: newPerc })
                    //             .then(result => {
                    //                 if (result === 'Success') {
                    //                     console.log('Lead updated successfully');
                    //                 } 
                    //                 else {
                    //                     console.error('Failed to update Lead');
                    //                 }
                    //             })
                    //             .catch(error => {
                    //                 console.error('Error while saving lead form percentage:'+JSON.stringify(error));
                    //             });
                    //         })
                    //     .catch(error => {
                    //         console.error('Error while getting lead form percentage:'+JSON.stringify(error));
                    //     });                        

                    const evt = new ShowToastEvent({
                        title: 'Collateral',
                        message: 'Successfully Saved',
                        variant: 'success',
                    });

                    this.dispatchEvent(evt);

                    //Send success msg to submit button
                    let collateralSection = false;
                    publish(this.messageContext, SUBMITACTION , {
                        collateralSection : collateralSection
                    });
                    
                    /*************/ 
                    //Redirect to next section
                    const onNextEvent = new CustomEvent('next', {
                        detail: {
                            nextValue: '8',
                        },
                    });
                    this.dispatchEvent(onNextEvent);
                    this.nextPage = false;

                    /***************/
                })
                .catch(error => {
                    this.isLoading = false;
                    console.log('Error while inserting record -->', JSON.stringify(error));
                })
            }
        }
    }
}