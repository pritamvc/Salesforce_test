import { LightningElement, track, wire } from 'lwc';
import fetchDocuments from '@salesforce/apex/DocumentController.fetchDocumentChecklist';
import DOCUMENTCHKLIST_OBJECT from '@salesforce/schema/Document_Checklist__c';
import { getPicklistValuesByRecordType } from 'lightning/uiObjectInfoApi';
import getContentVersion from '@salesforce/apex/DocumentController.getContentVersion';
import createDocument from '@salesforce/apex/DocumentController.createDocument';
import ACCOUNT_OBJECT from '@salesforce/schema/Document_Checklist__c';
import TYPE_FIELD from '@salesforce/schema/Document_Checklist__c.Document_Type__c';
import STATUS_FIELD from '@salesforce/schema/Document_Checklist__c.Status__c';
import SUBDOC_FIELD from '@salesforce/schema/Document_Checklist__c.Doc_Sub_Type__c';
import { updateRecord } from 'lightning/uiRecordApi';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { refreshApex } from '@salesforce/apex';
import { getPicklistValues, getObjectInfo } from 'lightning/uiObjectInfoApi';
import { NavigationMixin } from 'lightning/navigation';
import saveGuest from '@salesforce/apex/DocumentController.createDocument';

const columnList = [
    { label: 'Applicant Name', fieldName: 'Applicant_Name__c', editable: true },
    { label: 'Applicant Type', fieldName: 'Applicant_Type__c', editable: true },
    {
        label: 'Applicant Type', fieldName: 'Applicant_Type__c', type: 'picklistColumn', editable: true, typeAttributes: {
            placeholder: 'Choose Type', options: { fieldName: 'pickListOptions' }, 
            value: { fieldName: 'Applicant_Type__c' }, // default value for picklist,
            context: { fieldName: 'Id' } // binding account Id with context variable to be returned back
        }
    },
    {
        label: 'Document Type', fieldName: 'Document_Type__c', type: 'picklistColumn', editable: true, typeAttributes: {
            placeholder: 'Choose Type', options: { fieldName: 'pickListOptions' }, 
            value: { fieldName: 'Document_Type__c' }, // default value for picklist,
            context: { fieldName: 'Id' } // binding account Id with context variable to be returned back
        }
    },
    {
        label: 'Doc Sub Type', fieldName: 'Doc_Sub_Type__c', type: 'picklistColumn', editable: true, typeAttributes: {
            placeholder: 'Choose Type', options: { fieldName: 'pickListOptions' }, 
            value: { fieldName: 'Doc_Sub_Type__c' }, // default value for picklist,
            context: { fieldName: 'Id' } // binding account Id with context variable to be returned back
        }
    },
    {
        label: 'Status', fieldName: 'Status__c', type: 'picklistColumn', editable: true, typeAttributes: {
            placeholder: 'Choose Type', options: { fieldName: 'pickListOptions' }, 
            value: { fieldName: 'Status__c' }, // default value for picklist,
            context: { fieldName: 'Id' } // binding account Id with context variable to be returned back
        }
    },
    { label: 'Target Date', fieldName: 'Target_Date__c', editable: true },
    { label: 'Received Date', fieldName: 'Received_Date__c', helpText: 'Enter document recieved date.',editable: true },
    { label: 'Remark', fieldName: 'Remarks__c', editable: true },

    { label: 'Documents Upload', 
    type: 'fileUpload', 
    fieldName: 'Id', typeAttributes: { acceptedFileFormats: '.jpg,.jpeg,.pdf,.png',fileUploaded:{fieldName: 'IsDocumentComplete__c'} } },
    {
        
        label: 'Preview',
        type: 'button',
        fieldName: '',
        initialWidth: 135,
        typeAttributes: { label: 'Preview', name: 'file preview', title: 'Click to View Details' }
    },
    
];

export default class PatientDocumentUpload extends NavigationMixin(LightningElement) {
    @track data = [];
    @track columns = columnList;
    showSpinner = false;
    @track accountData;
    @track draftValues = [];
    lastSavedData = [];
    @track pickListOptions;
    @track files;
    @track contentversionId
    @track mapIdTitle
    @track fileIDs
     //Boolean tracked variable to indicate if modal is open or not default value is false as modal is closed when page is loaded 
     @track isModalOpen = false;
     @track ApplicantName;
     @track address;
     @track phone;
     @track email;
     @track recordId;
     @track controllingValues = [];
     @track dependentValues = [];
     @track selectedType;
     @track selecteddocTypePreference;
     @track isEmpty = false;
     @track error;
     controlValues;
     totalDependentValues = [];
     @track data;
     applicantChangeName(event) {
        this.ApplicantName = event.detail.value;
    }
    openModal() {
        // to open modal set isModalOpen tarck value as true
        this.isModalOpen = true;
    }
    closeModal() {
        // to close modal set isModalOpen tarck value as false
        this.isModalOpen = false;
    }
    submitDetails() {
        // to close modal set isModalOpen tarck value as false
        //Add your code to call apex method or do some processing
        this.isModalOpen = false;
    }

    addRow() {
        this.data = [...this.data, { id: this.data.length, Applicant_Name__c: '', Document_Type__c: '', Status__c: '', Target_Date__c: '', Received_Date__c: '', Remarks__c: '', Status__c: '' }];
    }
    /*connectedCallback() {
        getPendingDocuments().then(res => { 
            console.log('res:'+res);
            this.data = res; 
        }
        ).catch(err => console.error('err:'+err));
        console.log('columns => ', columnList);
        
        console.log(this.data);
    }*/
    @wire(getObjectInfo, { objectApiName: ACCOUNT_OBJECT })
    objectInfo;
 
    //fetch picklist options
    @wire(getPicklistValues, {
        recordTypeId: "$objectInfo.data.defaultRecordTypeId",
        fieldApiName: TYPE_FIELD,STATUS_FIELD
    })
 
    wirePickList({ error, data }) {
        if (data) {
            this.pickListOptions = data.values;
        } else if (error) {
            console.log(error);
        }
    }
    @wire(getPicklistValuesByRecordType, { objectApiName: DOCUMENTCHKLIST_OBJECT, recordTypeId: '$objectInfo.data.defaultRecordTypeId'})
        countryPicklistValues({error, data}) {
                            if(data) {
                            this.error = null;
                            
                            let docTypeOptions = [{label:'--None--', value:'--None--'}];
                            
                            
                            data.picklistFieldValues.Document_Type__c.values.forEach(key => {
                            docTypeOptions.push({
                            label : key.label,
                            value: key.value
                            })
        });

        this.controllingValues = docTypeOptions;

        let typeOptions = [{label:'--None--', value:'--None--'}];

        this.controlValues = data.picklistFieldValues.Doc_Sub_Type__c.controllerValues;
        this.totalDependentValues = data.picklistFieldValues.Doc_Sub_Type__c.values;
        this.totalDependentValues.forEach(key => {
            typeOptions.push({
            label : key.label,
            value: key.value
        })
        });

        this.dependentValues = typeOptions;
        }
        else if(error) {
            this.error = JSON.stringify(error);
        }
        }

        handledoctypePreferenceChange(event) {
            // Selected Meal Preference Value
            this.selecteddocTypePreference = event.target.value;
            this.isEmpty = false;
            let dependValues = [];
            
            if(this.selecteddocTypePreference) {
                // if Selected Meal Preference is none returns nothing
                if(this.selecteddocTypePreference === '--None--') {
                    this.isEmpty = true;
                    dependValues = [{label:'--None--', value:'--None--'}];
                    this.selecteddocTypePreference = null;
                    this.selectedType = null;
                    return;
                }
                
                // filter the total dependent values based on selected meal preference value 
                this.totalDependentValues.forEach(conValues => {
                    if(conValues.validFor[0] === this.controlValues[this.selecteddocTypePreference]) {
                    dependValues.push({
                    label: conValues.label,
                    value: conValues.value
                })
            }
        })

        this.dependentValues = dependValues;
        }
        }

        handleSubtypeChange(event) {
            this.selectedType = event.target.value;
        }

        //To Save the Record 
        saveRecord() {
            
            let guestObj = { 'sobjectType': 'Document_Checklist__c' };
            guestObj.Applicant_Name__c = this.ApplicantName;
            guestObj.Document_Type__c = this.selecteddocTypePreference;
            guestObj.Doc_Sub_Type__c = this.selectedType;

            const value = true;
            const valueChangeEvent = new CustomEvent("valuechange", {
            detail: { value }
            });
            
            // Fire the custom event
            this.dispatchEvent(valueChangeEvent);

            saveGuest({newRecord: guestObj})
                .then(result => {
                    this.recordId = result;
                })
                .catch(error => {
                    this.error = error;
                });
                
        }
        
 
    //here I pass picklist option so that this wire method call after above method
    @wire(fetchDocuments, { pickList: '$pickListOptions' })
    accountData(result) {
        this.accountData = result;
        if (result.data) {
            this.data = JSON.parse(JSON.stringify(result.data));
 
            this.data.forEach(ele => {
                ele.pickListOptions = this.pickListOptions;
            })
 
            this.lastSavedData = JSON.parse(JSON.stringify(this.data));
 
        } else if (result.error) {
            this.data = undefined;
        }
    };
 
    updateDataValues(updateItem) {
        let copyData = JSON.parse(JSON.stringify(this.data));
 
        copyData.forEach(item => {
            if (item.Id === updateItem.Id) {
                for (let field in updateItem) {
                    item[field] = updateItem[field];
                }
            }
        });
 
        //write changes back to original data
        this.data = [...copyData];
    }
 
    updateDraftValues(updateItem) {
        let draftValueChanged = false;
        let copyDraftValues = [...this.draftValues];
        //store changed value to do operations
        //on save. This will enable inline editing &
        //show standard cancel & save button
        copyDraftValues.forEach(item => {
            if (item.Id === updateItem.Id) {
                for (let field in updateItem) {
                    item[field] = updateItem[field];
                }
                draftValueChanged = true;
            }
        });
 
        if (draftValueChanged) {
            this.draftValues = [...copyDraftValues];
        } else {
            this.draftValues = [...copyDraftValues, updateItem];
        }
    }
 
    //handler to handle cell changes & update values in draft values
    handleCellChange(event) {
        //this.updateDraftValues(event.detail.draftValues[0]);
        let draftValues = event.detail.draftValues;
        draftValues.forEach(ele=>{
            this.updateDraftValues(ele);
        })
    }
 
    handleSave(event) {
        this.showSpinner = true;
        this.saveDraftValues = this.draftValues;
 
        const recordInputs = this.saveDraftValues.slice().map(draft => {
            const fields = Object.assign({}, draft);
            return { fields };
        });
        recordInputs.forEach(recordInput => {
            createDocument({ account: recordInput.fields })
                .then(() => {
                    this.data = [...this.data, { ...recordInput.fields, id: this.data.length }];
                })
                .catch(error => {
                    console.log(error);
                });
        });

        this.draftValues = [];
 
        // Updating the records using the UiRecordAPi
        const promises = recordInputs.map(recordInput => updateRecord(recordInput));
        Promise.all(promises).then(res => {
            this.showToast('Success', 'Records Updated Successfully!', 'success', 'dismissable');
            this.draftValues = [];
            return this.refresh();
        }).catch(error => {
            console.log(error);
            this.showToast('Error', 'An Error Occured!!', 'error', 'dismissable');
        }).finally(() => {
            this.draftValues = [];
            this.showSpinner = false;
        });
    }
 
    handleCancel(event) {
        //remove draftValues & revert data changes
        this.data = JSON.parse(JSON.stringify(this.lastSavedData));
        this.draftValues = [];
    }
 
    showToast(title, message, variant, mode) {
        const evt = new ShowToastEvent({
            title: title,
            message: message,
            variant: variant,
            mode: mode
        });
        this.dispatchEvent(evt);
    }

    previewHandler(event){
        //console.log(event.target.dataset.id)
       // var row = event.detail.row;
        console.log('dataset',event.target.dataset.id)
        const actionname= event.detail.action.name;
        const row= event.detail.row;

        //const actionname1= event.detail.action.
        console.log('actionname**',actionname)
        console.log('row**',row)

     

        switch (actionname) {
            case 'file preview':
                this.fetchdocumentFile(row.Id);
                console.log('contentversionId******',this.contentversionId)
                this.navigateTofilepreview(this.contentversionId);
                break;
        }
        console.log('before contentversionId******',this.contentversionId)
        this.contentversionId =null;
        console.log('after contentversionId******',this.contentversionId)
    }

    navigateTofilepreview(id) {
        this[NavigationMixin.Navigate]({ 
            type: 'standard__namedPage',
            attributes: {
                pageName: 'filePreview'
            },
            state: {
                selectedRecordId: id
            }
        });
    }

    fetchdocumentFile(id) {
        getContentVersion({ docId: id })
            .then((versionId) => this.contentversionId=versionId) //console.log('versionId => ', versionId))
            .catch((error) => console.error('ERROR => ', error));
    }
    
    // This function is used to refresh the table once data updated
    async refresh() {
        await refreshApex(this.accountData);
    }


    
     
}