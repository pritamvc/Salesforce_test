import { LightningElement, track, wire, api } from "lwc";
import getDocCheclistForApplicant from '@salesforce/apex/GetDocumentChecklistRecords.fetchChecklistRecordsForApplicant'
import fetchChecklistRecordsForApplicantUpdated from '@salesforce/apex/GetDocumentChecklistRecords.fetchChecklistRecordsForApplicantUpdated'
import getCoApplicantDetails from '@salesforce/apex/GetDocumentChecklistRecords.getCoApplicant'
import getCoApplicantUpdated from '@salesforce/apex/GetDocumentChecklistRecords.getCoApplicantUpdated'
import getGuarantorDetails from '@salesforce/apex/GetDocumentChecklistRecords.getGuarantor'
import getGuarantorUpdated from '@salesforce/apex/GetDocumentChecklistRecords.getGuarantorUpdated'
import getContentVersion from '@salesforce/apex/GetDocumentChecklistRecords.getContentDocument'
import updateDockChecklist from '@salesforce/apex/GetDocumentChecklistRecords.updateDockChecklist'
import getSalesProfile from '@salesforce/apex/GetDocumentChecklistRecords.getSalesProfile'
import getProfileLoginDesk from '@salesforce/apex/GetDocumentChecklistRecords.getProfileLoginDesk'
import sendDocumentStatusViaEmailNotification from '@salesforce/apex/GetDocumentChecklistRecords.sendDocumentStatusViaEmailNotification'
import { NavigationMixin } from 'lightning/navigation';
import { refreshApex } from '@salesforce/apex';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { updateRecord } from 'lightning/uiRecordApi';
import { loadStyle } from 'lightning/platformResourceLoader'
import COLORS from '@salesforce/resourceUrl/datatablecolors'
import FORM_FACTOR from "@salesforce/client/formFactor";

const actions = [
    { label: 'call flow', name: 'call flow' },
];
export default class DocumentDataTableTab extends NavigationMixin(LightningElement) {
    //debugger;
    @api recordId;
    @api ApplicntName;
    @track contentversionId;
    @track coapplicantWithCor;
    @track coapplicantList;
    @track coapplicantMap;
    @track coApplicantMapData = [];
    @track checklistApiName;
    activeSectionMessage = '';
    activeSections = [];
    @track isModalOpen = false;
    @track isDocumentAccepted = false;
    @track guarantorWithCor;
    @track guarantorList;
    @track guarantorMap;
    @track status;
    @track guarantorMapData = [];
    activeSectionsGuarantor = [];
    flowVariable = [];
    @track isRemarkUpdated = false;
    @track isBankStatement = false;
    isCssLoaded = false
    @track userSalesUseProfile = false;
    @track userLoginDesk = false;

    section='';

    handleToggleSection(event) {
        this.activeSectionMessage =
            'Open section name:  ' + event.detail.openSections;
            this.section=event.detail.openSections;

    }

    connectedCallback() {
        debugger;
        this.getSalesProfileCallBack();
        this.getProfileLoginDeskCallBack();
    }
    getSalesProfileCallBack() {
        getSalesProfile()
            .then(result => {
                this.userSalesUseProfile = result;
                this.setupDataAndColumnsApplicant();
                this.setupDataAndColumnsCoApplicant();
                this.setupDataAndColumnsGuarantor();
            })
            .catch(error => {
            });
    }

    getProfileLoginDeskCallBack() {
        getProfileLoginDesk()
            .then(result => {
                this.userLoginDesk = result;
            })
            .catch(error => {
            });

    }
    @track dataForApplicant;
    @track columnsForApplicant
    setupDataAndColumnsApplicant() {
        this.columnsForApplicant = [
            { label: 'Document Type', fieldName: 'Document_Type__c', type: 'text', wrapText: true },
            {
                label: 'Document Sub-type', fieldName: 'Doc_Sub_Type__c', type: 'text', wrapText: true,
                cellAttributes: { class: { fieldName: 'mandatoryColor' } }
            },
            {
                label: 'Documents Upload',
                type: 'fileUpload',
                wrapText: true,
                fieldName: 'Id', typeAttributes: { acceptedFormats: { fieldName: 'docFileType' }, 
                                                   fileUploaded: { fieldName: 'IsDocumentComplete__c' }, 
                                                   fileSize: { fieldName: 'docFileSize' }, 
                                                   docType: { fieldName: 'dockType' }, 
                                                   subDocType: { fieldName: 'Doc_Sub_Type__c' } }
            },
            {
                label: 'Preview',
                type: 'button',
                fieldName: '',
                typeAttributes: { rowActions: actions, label: 'Preview', name: 'call flow', title: 'Click to View Details' }
            },
            { label: 'Status', fieldName: 'Status__c', type: 'text', wrapText: true, editable: this.userSalesUseProfile },
            { label: 'Remark', fieldName: 'Remarks__c', type: 'text', wrapText: true, editable: this.userSalesUseProfile }


        ];
    }

    handleUploadFinished(event) {

        this.refreshDataAfterSaveApplicant();
        this.refreshDataAfterSaveCoApplicant();
        this.refreshDataAfterSaveGuarantor();
        this.activeSections=this.section;
        this.activeSectionsGuarantor=this.section;

    }

    @wire(getDocCheclistForApplicant, { recordId: '$recordId' })
    applicantsRecord({ error, data }) {
        if (data) {
            data = JSON.parse(JSON.stringify(data));
           // console.log('#####CheckApplicantData',data.Document_Checklist_Master__r.Id);
            data.forEach(record => {
                record.docFileType = record.Document_Checklist_Master__r.File_Types__c;
                record.docFileSize = record.Document_Checklist_Master__r.File_Size__c;
                record.dcLink = '/' + record.Id;
                if (record.Doc_Sub_Type__c == 'Bank Statement') {
                    this.isBankStatement = true;
                    record.dockType = this.isBankStatement;
                }
            });
            
            this.dataForApplicant = data.map(item => {
                let mandatoryColor;
                if (item.Applicant__r.Is_Income_Considered_Financial__c == "Yes") {
                    this.ApplicntName = item.Applicant__r.Account__r.Name	 + ' - Financial';
                }
                else if (item.Applicant__r.Is_Income_Considered_Financial__c == "No" || item.Applicant__r.Is_Income_Considered_Financial__c == " " || item.Applicant__r.Is_Income_Considered_Financial__c == null) {
                    this.ApplicntName = item.Applicant__r.Account__r.Name	 + ' - Non-Financial';
                }
                if (item.Document_Checklist_Master__r.IsMandetory__c == "Yes") {
                    mandatoryColor = "datatble-orange"
                } else if (item.Document_Checklist_Master__r.IsMandetory__c == "No" || item.Document_Checklist_Master__r.IsMandetory__c == " ") {
                    mandatoryColor = "datatble-Yellow"
                } else if (item.Document_Checklist_Master__r.IsMandetory__c == "Conditional") {
                    mandatoryColor = "datatble-blue"
                }

                return {
                    ...item,
                    "mandatoryColor": mandatoryColor
                }
            });
            this.checklistApiName = data.Name;
        } else if (error) {
            this.error = undefined;
        }

    }

    @track dataForCoApplicant;
    @track columnsForCoApplicant
    setupDataAndColumnsCoApplicant() {
        console.log('test inside line 150');
        this.columnsForCoApplicant = [
            { label: 'Document Type', fieldName: 'Document_Type__c', type: 'text', wrapText: true },
            {
                label: 'Document Sub-type', fieldName: 'Doc_Sub_Type__c', type: 'text', wrapText: true,
                cellAttributes: { class: { fieldName: 'mandatoryColor' } }
            },
            {
                label: 'Documents Upload',
                type: 'fileUpload',
                wrapText: true,
                fieldName: 'Id', typeAttributes: { acceptedFormats: { fieldName: 'docFileType' },
                                                   fileUploaded: { fieldName: 'IsDocumentComplete__c' }, 
                                                   fileSize: { fieldName: 'docFileSize' }, 
                                                   docType: { fieldName: 'dockType' }, 
                                                   subDocType: { fieldName: 'Doc_Sub_Type__c' } }
            },
            {
                label: 'Preview',
                type: 'button',
                fieldName: '',
                typeAttributes: { rowActions: actions, label: 'Preview', name: 'call flow', title: 'Click to View Details' }
            },
            /*{
            
                    label: 'Preview',
                    type: 'button',
                    fieldName: '',
                    typeAttributes: { label: 'Preview', name: 'file preview', title: 'Click to View Details' }
                },*/
            { label: 'Status', fieldName: 'Status__c', type: 'text', wrapText: true, editable: this.userSalesUseProfile },
            { label: 'Remark', fieldName: 'Remarks__c', type: 'text', wrapText: true, editable: this.userSalesUseProfile }
        ];
        console.log('columnsForCoApplicant====== method line 182', this.columnsForCoApplicant);
    }
    columnsForCoApplicantmethod() {
        console.log('columnsForCoApplicant====== method line 182', this.columnsForCoApplicant);
    }

    @track dataForGuarantor;
    @track columnsForGuarantor
    setupDataAndColumnsGuarantor() {
        this.columnsForGuarantor = [
            /* {
                    label: 'Document Checklist',
                    type: 'button',
                    fieldName: '',
                    typeAttributes: { rowActions: actions, variant: 'base', label:{fieldName: 'Name'}, name: 'call flow', title: 'Click to View Details' }
                },*/
            { label: 'Document Type', fieldName: 'Document_Type__c', type: 'text', wrapText: true },
            {
                label: 'Document Sub-type', fieldName: 'Doc_Sub_Type__c', type: 'text', wrapText: true,
                cellAttributes: { class: { fieldName: 'mandatoryColor' } }
            },
            //  { label: 'Instructions', fieldName: 'Document_Instruction__c', type:'text', wrapText: true },
            {
                label: 'Documents Upload',
                type: 'fileUpload',
                wrapText: true,
                fieldName: 'Id', typeAttributes: { acceptedFormats: { fieldName: 'docFileType' }, 
                                                   fileUploaded: { fieldName: 'IsDocumentComplete__c' }, 
                                                   fileSize: { fieldName: 'docFileSize' }, 
                                                   docType: { fieldName: 'dockType' }, 
                                                   subDocType: { fieldName: 'Doc_Sub_Type__c' } }
            },
            {
                label: 'Preview',
                type: 'button',
                fieldName: '',
                typeAttributes: { rowActions: actions, label: 'Preview', name: 'call flow', title: 'Click to View Details' }
            },
            /*{
        
                label: 'Preview',
                type: 'button',
                fieldName: '',
                typeAttributes: { label: 'Preview', name: 'file preview', title: 'Click to View Details' }
            },*/
            { label: 'Status', fieldName: 'Status__c', type: 'text', wrapText: true, editable: this.userSalesUseProfile },
            { label: 'Remark', fieldName: 'Remarks__c', type: 'text', wrapText: true, editable: this.userSalesUseProfile }
        ];
    }

    previewDoc(event) {
        const actionName = event.detail.action.name;
        const row = event.detail.row;
        if (actionName == 'call flow') {
            this.isModalOpen = true;
        }
        switch (actionName) {
            case 'file preview':
                this.fetchdocumentFile(row.Id);
                break;
            case 'call flow':
                this.isModalOpen = true;
                this.flowVariable = [
                    {
                        name: "RecordId",
                        type: "String",
                        value: row.Id
                    }
                ];
                this.isFlowRunning = true;
                window.scrollTo(0, 0);
                break;
        }
        const docCheckListStatus = event.detail.row.Status__c;
        this.status = docCheckListStatus;
        if (this.status == 'Accepted' && actionName == 'call flow') {
            this.isModalOpen = true;
            this.isDocumentAccepted = false;
            window.scrollTo(0, 0);
            this.isFlowRunning = true;

        }

    }

    handleStatusChange(event) {
        if (event.detail.status?.toLowerCase() == 'finished') {
            this.isModalOpen = false;
            //  this.navigateToRecordPage(this.recordId);            
        }

    }

    navigateTofilepreview(rowId) {
        this[NavigationMixin.Navigate]({
            type: 'standard__namedPage',
            attributes: {
                pageName: 'filePreview'
            },
            state: {
                selectedRecordId: rowId
            }
        });
    }

    navigateToRecordPage(recordId) {
        this[NavigationMixin.Navigate]({
            type: 'standard__recordPage',
            attributes: {
                recordId: recordId,
                objectApiName: 'Lead',
                actionName: 'view'
            }

        });
        this.updateRecordView();
    }

    updateRecordView() {
        //  window.location.reload()
        setTimeout(() => {
            eval("$A.get('e.force:refreshView').fire();");
        }, 1000);
    }

    fetchdocumentFile(rowId) {
        getContentVersion({ docId: rowId })
            .then((versionId) => {
                this.contentversionId = versionId
                this.navigateTofilepreview(this.contentversionId)
            })
            .catch((error) => console.error('ERROR => ', error));
    }
    async refresh() {
        //   await refreshApex(this.accountData);
    }

    closeModal() {
        this.isModalOpen = false;
        this.isDocumentAccepted = false;
    }

    @wire(getCoApplicantDetails, { recordId: '$recordId' })
    coAppWithCordion({ error, data }) {
        if (data) {
            this.coapplicantWithCor = data;
            this.coapplicantList = data.accList;
            this.coapplicantMap = data.appNameVsDocCheclistMap;
            var conts = this.coapplicantMap;
            for (var key in conts) {
                var listOfCoapplicantLink = (conts[key]);
                listOfCoapplicantLink = JSON.parse(JSON.stringify(listOfCoapplicantLink));
                this.activeSections.push(key);
                listOfCoapplicantLink.forEach(record => {
                    record.dcLink = '/' + record.Id;
                    record.docFileType = record.Document_Checklist_Master__r.File_Types__c;
                    record.docFileSize = record.Document_Checklist_Master__r.File_Size__c;
                    if (record.Doc_Sub_Type__c == 'Bank Statement') {
                        this.isBankStatement = true;
                        record.dockType = this.isBankStatement;
                    }
                    if (record.Applicant__r.Is_Income_Considered_Financial__c == "Yes") {
                        key = record.Applicant__r.Account__r.Name	 + ' - Financial';
                    }
                    else if (record.Applicant__r.Is_Income_Considered_Financial__c == "No" || record.Applicant__r.Is_Income_Considered_Financial__c == " " || record.Applicant__r.Is_Income_Considered_Financial__c == null) {
                        key = record.Applicant__r.Account__r.Name	 + ' - Non-Financial';
                    }
                    if (record.Document_Checklist_Master__r.IsMandetory__c == "Yes") {
                        record.mandatoryColor = "datatble-orange"
                    } else if (record.Document_Checklist_Master__r.IsMandetory__c == "No") {
                        record.mandatoryColor = "datatble-Yellow"
                    } else if (record.Document_Checklist_Master__r.IsMandetory__c == "Conditional") {
                        record.mandatoryColor = "datatble-blue"
                    }
                });
                this.coApplicantMapData.push({ key: key, value: listOfCoapplicantLink });
            }
        } else if (error) {
            this.error = undefined;
        }
    }


    @wire(getGuarantorDetails, { recordId: '$recordId' })
    guarantorWithCordion({ error, data }) {
        if (data) {
            this.guarantorWithCor = data;
            this.guarantorList = data.accList;
            this.guarantorMap = data.guarantorNameVsDocCheclistMap;
            var conts = this.guarantorMap;
            var guarantorLink;
            for (var key in conts) {
                guarantorLink = (conts[key]);
                guarantorLink = JSON.parse(JSON.stringify(guarantorLink));
                this.activeSectionsGuarantor.push(key);
                guarantorLink.forEach(record => {
                    record.dcLink = '/' + record.Id;
                    record.docFileType = record.Document_Checklist_Master__r.File_Types__c;
                    record.docFileSize = record.Document_Checklist_Master__r.File_Size__c;
                    if (record.Doc_Sub_Type__c == 'Bank Statement') {
                        this.isBankStatement = true;
                        record.dockType = this.isBankStatement;
                    }
                    if (record.Applicant__r.Is_Income_Considered_Financial__c == "Yes") {
                        key = record.Applicant__r.Account__r.Name	 + ' - Financial';
                    }
                    else if (record.Applicant__r.Is_Income_Considered_Financial__c == "No" || record.Applicant__r.Is_Income_Considered_Financial__c == " " || record.Applicant__r.Is_Income_Considered_Financial__c == null) {
                        key = record.Applicant__r.Account__r.Name	 + ' - Non-Financial';
                    }
                    if (record.Document_Checklist_Master__r.IsMandetory__c == "Yes") {
                        record.mandatoryColor = "datatble-orange"
                    } else if (record.Document_Checklist_Master__r.IsMandetory__c == "No") {
                        record.mandatoryColor = "datatble-Yellow"
                    } else if (record.Document_Checklist_Master__r.IsMandetory__c == "Conditional") {
                        record.mandatoryColor = "datatble-blue"
                    }
                });
                this.guarantorMapData.push({ value: guarantorLink, key: key });
            }
        } else if (error) {
            this.error = undefined;
        }
    }
    fldsItemValues = [];
    draftValue = [];
    @track dockId = [];

    saveHandleAction(event) {
        this.fldsItemValues = event.detail.draftValues;
        const draftValues = event.detail.draftValues;
        let columnNamefirstValueUpdated;
        let columnNameSecondValueUpdated;
        if (draftValues.length > 0) {
            columnNamefirstValueUpdated = Object.keys(draftValues[0])[0];
            columnNameSecondValueUpdated = Object.keys(draftValues[0])[1];
        }
        if (!(columnNamefirstValueUpdated == 'Remarks__c' && columnNameSecondValueUpdated == 'Id')) {
            for (let i = 0; i < this.fldsItemValues.length; i++) {
                this.dockId.push(this.fldsItemValues[i].Id);
                let statusToLowerCase = this.fldsItemValues[i].Status__c.toLowerCase();
                if (statusToLowerCase == 'rejected') {
                    if (statusToLowerCase == 'rejected' && this.fldsItemValues[i].Remarks__c != null) {
                        this.isRemarkUpdated = true;
                    } else if (statusToLowerCase == 'rejected' && this.fldsItemValues[i].Remarks__c == null) {
                        this.isRemarkUpdated = false;
                        break;
                    }
                } else if (statusToLowerCase != 'rejected') {
                    if (this.fldsItemValues[i].Status__c == 'Pending' || this.fldsItemValues[i].Status__c == 'Accepted') {
                        this.isRemarkUpdated = true;
                    } else {
                        this.isRemarkUpdated = true;
                    }
                }
            }

            const inputsItems = this.fldsItemValues.slice().map(draft => {
                const fields = Object.assign({}, draft);
                return { fields };
            });
            if (this.isRemarkUpdated === true) {
                const promises = inputsItems.map(recordInput => updateRecord(recordInput));
                Promise.all(promises).then(res => {
                    this.dispatchEvent(
                        new ShowToastEvent({
                            title: 'Success',
                            message: 'Records Updated Successfully!!',
                            variant: 'success'
                        })
                    );
                    this.fldsItemValues = [];
                    this.updateChecklist(this.dockId);
                    this.refreshDataAfterSaveApplicant();
                    this.refreshDataAfterSaveCoApplicant();
                    this.refreshDataAfterSaveGuarantor();

                }).catch(error => {
                    this.dispatchEvent(
                        new ShowToastEvent({
                            title: 'Error',
                            message: error.body.output.fieldErrors.Status__c[0].message,
                            variant: 'error'
                        })
                    );
                }).finally(() => {
                    this.fldsItemValues = [];
                });
            } else {
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Error',
                        message: 'Please enter rejected remarks!!',
                        variant: 'error'
                    })
                );
            }
        } else {
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Error',
                    message: 'Please make sure you are updating Remark along with status!!',
                    variant: 'error'
                })
            );
        }
    }
    async refresh() {
        await refreshApex(this.dataForApplicant);
    }

    updateChecklist(docList) {
        updateDockChecklist({ docIdList: docList }).then(result => {
        })
            .catch((error) => console.error('ERROR => ', error));
    }

    renderedCallback() {
        if (this.isCssLoaded) return
        this.isCssLoaded = true
        loadStyle(this, COLORS).then(() => {
        }).catch(error => {
            console.error("Error in loading the colors")
        })
    }
   
    refreshDataAfterSaveApplicant() {
        this.dataForApplicant = [];
        fetchChecklistRecordsForApplicantUpdated({ recordId: this.recordId })
            .then(result => {
                result = JSON.parse(JSON.stringify(result));
                result.forEach(record => {
                    record.docFileType = record.Document_Checklist_Master__r.File_Types__c;
                    record.docFileSize = record.Document_Checklist_Master__r.File_Size__c;
                    record.dcLink = '/' + record.Id;
                    if (record.Doc_Sub_Type__c == 'Bank Statement') {
                        this.isBankStatement = true;
                        record.dockType = this.isBankStatement;
                    }

                });
                this.dataForApplicant = result.map(item => {
                    let mandatoryColor;
                    if (item.Document_Checklist_Master__r.IsMandetory__c == "Yes") {
                        mandatoryColor = "datatble-orange"
                    } else if (item.Document_Checklist_Master__r.IsMandetory__c == "No") {
                        mandatoryColor = "datatble-Yellow"
                    } else if (item.Document_Checklist_Master__r.IsMandetory__c == "Conditional") {
                        mandatoryColor = "datatble-blue"
                    }
                    return {
                        ...item,
                        "mandatoryColor": mandatoryColor
                    }
                });
                this.checklistApiName = result.Name;
            })
            .catch(error => {
                // Handle the error
                console.error('Error:', error);
            });
    }

    refreshDataAfterSaveCoApplicant() {
        this.coApplicantMapData = [];
        getCoApplicantUpdated({ recordId: this.recordId })
            .then(result => {
                this.coapplicantWithCor = result;
                this.coapplicantList = result.accList;
                this.coapplicantMap = result.appNameVsDocCheclistMap;
                var conts = this.coapplicantMap;
                for (var key in conts) {
                    var listOfCoapplicantLink = (conts[key]);
                    listOfCoapplicantLink = JSON.parse(JSON.stringify(listOfCoapplicantLink));
                    this.activeSections.push(key);
                    listOfCoapplicantLink.forEach(record => {
                        record.dcLink = '/' + record.Id;
                        record.docFileType = record.Document_Checklist_Master__r.File_Types__c;
                        record.docFileSize = record.Document_Checklist_Master__r.File_Size__c;
                        if (record.Doc_Sub_Type__c == 'Bank Statement') {
                            this.isBankStatement = true;
                            record.dockType = this.isBankStatement;
                        }
                        if (record.Applicant__r.Is_Income_Considered_Financial__c == "Yes") {
                            key = record.Applicant__r.Account__r.Name	 + ' - Financial';
                        }
                        else if (record.Applicant__r.Is_Income_Considered_Financial__c == "No" || record.Applicant__r.Is_Income_Considered_Financial__c == " " || record.Applicant__r.Is_Income_Considered_Financial__c == null) {
                            key = record.Applicant__r.Account__r.Name	 + ' - Non-Financial';
                        }
                        if (record.Document_Checklist_Master__r.IsMandetory__c == "Yes") {
                            record.mandatoryColor = "datatble-orange"
                        } else if (record.Document_Checklist_Master__r.IsMandetory__c == "No") {
                            record.mandatoryColor = "datatble-Yellow"
                        } else if (record.Document_Checklist_Master__r.IsMandetory__c == "Conditional") {
                            record.mandatoryColor = "datatble-blue"
                        }
                    });
                    this.coApplicantMapData.push({ key: key, value: listOfCoapplicantLink });
                }
            })
            .catch(error => {
                // Handle the error
                console.error('Error:', error);
            });
    }

    refreshDataAfterSaveGuarantor() {
        this.guarantorMapData = [];
        getGuarantorUpdated({ recordId: this.recordId })
            .then(result => {
                this.guarantorWithCor = result;
                this.guarantorList = result.accList;
                this.guarantorMap = result.guarantorNameVsDocCheclistMap;
                var conts = this.guarantorMap;
                var guarantorLink;
                for (var key in conts) {
                    guarantorLink = (conts[key]);
                    guarantorLink = JSON.parse(JSON.stringify(guarantorLink));
                    this.activeSectionsGuarantor.push(key);
                    guarantorLink.forEach(record => {
                        record.dcLink = '/' + record.Id;
                        record.docFileType = record.Document_Checklist_Master__r.File_Types__c;
                        record.docFileSize = record.Document_Checklist_Master__r.File_Size__c;
                        if (record.Doc_Sub_Type__c == 'Bank Statement') {
                            this.isBankStatement = true;
                            record.dockType = this.isBankStatement;
                        }
                        if (record.Applicant__r.Is_Income_Considered_Financial__c == "Yes") {
                            key = record.Applicant__r.Account__r.Name	 + ' - Financial';
                        }
                        else if (record.Applicant__r.Is_Income_Considered_Financial__c == "No" || record.Applicant__r.Is_Income_Considered_Financial__c == " " || record.Applicant__r.Is_Income_Considered_Financial__c == null) {
                            key = record.Applicant__r.Account__r.Name	 + ' - Non-Financial';
                        }
                        if (record.Document_Checklist_Master__r.IsMandetory__c == "Yes") {
                            record.mandatoryColor = "datatble-orange"
                        } else if (record.Document_Checklist_Master__r.IsMandetory__c == "No") {
                            record.mandatoryColor = "datatble-Yellow"
                        } else if (record.Document_Checklist_Master__r.IsMandetory__c == "Conditional") {
                            record.mandatoryColor = "datatble-blue"
                        }
                    });
                    this.guarantorMapData.push({ value: guarantorLink, key: key });
                }
            })
            .catch(error => {
                // Handle the error
                console.error('Error:', error);
            });
    }
    @track returnMessage;
    handleClickSendEmail() {
        sendDocumentStatusViaEmailNotification({ recordId: this.recordId })
            .then(result => {
                this.returnMessage = result;
                if (this.returnMessage.startsWith('Success')) {
                    this.dispatchEvent(
                        new ShowToastEvent({
                            title: 'Success',
                            message: this.returnMessage,
                            variant: 'success'
                        })
                    );
                } else {
                    this.dispatchEvent(
                        new ShowToastEvent({
                            title: 'Error',
                            message: this.returnMessage,
                            variant: 'error'
                        })
                    );

                }

            })
            .catch(error => {
                // Handle the error
                console.error('Error:', error);
            });
    }

}