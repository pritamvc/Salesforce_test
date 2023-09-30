import { LightningElement,api } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import updateStatus from '@salesforce/apex/GetDocumentChecklistRecords.updateStatusOnDocChecklist' 

export default class FileUpload extends LightningElement {
    @api recordId;
    @api acceptedFileFormats;
    @api fileUploaded;

    handleUploadFinished() {
        this.updateStatusPending(this.recordId);       
        this.dispatchEvent(new CustomEvent('uploadfinished', {
            composed: true,
            bubbles: true,
            cancelable: true,
            detail: {
                data: { recordId: this.recordId }
            }
        }));
        this.dispatchEvent(new ShowToastEvent({
            title: 'Completed',
            message: 'File has been uploaded',
        }));
        
    }

    updateStatusPending(recordId){
            updateStatus({recordId : recordId})
            .then((result) => {
                console.log(result);
            })
            .catch((error) => {
                console.log(error);
            })
        }
}