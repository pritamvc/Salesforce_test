import { LightningElement, track, api } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import csvFileRead from '@salesforce/apex/BulkUploadCampaignController.csvFileRead';

const columnsCampaign = [
    { label: 'Campaign Name', fieldName: 'Name' },
    { label: 'Status', fieldName: 'Status' },
    { label: 'Start Date', fieldName: 'StartDate', type: 'datetime' },
    { label: 'End Date', fieldName: 'EndDate', type: 'datetime' },
    { label: 'Type', fieldName: 'Type' },
    { label: 'Budgeted Cost in Campaign', fieldName: 'BudgetedCost' }
];

console.log('columnsCampaign========= ' + columnsCampaign);

export default class BulkUploadCampaign extends LightningElement {
    @api recordId;
    @track error;
    @track columnsCampaign = columnsCampaign;
    @track data;

    // accepted parameters
    get acceptedCSVFormats() {
        return ['.csv'];
    }

    uploadFileHandler(event) {
        // Get the list of records from the uploaded files
        const uploadedFiles = event.detail.files;
        console.log('event.detail.files===> ' + event.detail.files);

        // calling apex class csvFileread method
        csvFileRead({ contentDocumentId: uploadedFiles[0].documentId })
            .then(result => {
                 window.console.log('result ===> ' + result);
                this.data = result;
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Success!!',
                        message: 'Accounts are created according to the CSV file upload!!!',
                        variant: 'Success',
                    }),
                );
            })
            .catch(error => {
                console.log("Inside the error line 42");
                this.error = error;
                console.log("this.error==== >" + JSON.stringify(this.error));
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Error!!',
                        message: JSON.stringify(error),
                        variant: 'error',
                    }),
                );
            })

    }
}