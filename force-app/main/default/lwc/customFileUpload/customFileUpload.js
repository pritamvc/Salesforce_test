import { LightningElement, track, api, wire } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import uploadFile from '@salesforce/apex/FileUploaderClass.uploadFile'
import uploadBankFile from '@salesforce/apex/FileUploaderClass.uploadBankFile'
import savePasswordForBankStatementDoument from '@salesforce/apex/FileUploaderClass.savePasswordForBankStatementDoument'

export default class CustomFileUpload extends LightningElement {
    @api recordId;
    @api acceptedFormats;
    @api fileUploaded;
    @api fileSize;
    @api docType;
    @track myVar;
    @api subDocType;
    BankacceptedFormat = ['.pdf', '.png', '.jpeg', '.jpg'];

    fileData
    passwordChange(event) {
        this.myVar = event.target.value;
        const inp = this.template.querySelectorAll(".inp");
        var code = this.template.querySelectorAll("lightning-input");
        savePasswordForBankStatementDoument({
            documentCheclistId: this.recordId,
            passwordString: this.myVar
        })
    }
    get shouldShowAdditionalTemplate() {
        return this.subDocType === 'Aadhar Card' || this.subDocType === 'PAN Card' || this.subDocType === 'Passport';
    }


    openfileUpload(event) {
        const file = event.detail.files[0]
        const type = file.type;
        const size = file.size;
        const fileSizeInByte = parseInt(this.fileSize) * 1048576;
        const fileTypes = this.acceptedFormats.replace(/image|\/|application/g, ' ')
        if (this.acceptedFormats.includes(type) && size <= fileSizeInByte) {
            var reader = new FileReader();
            reader.onload = () => {
                var base64 = reader.result.split(',')[1];
                //   var passVal = this.myVar;
                this.fileData = {
                    'filename': file.name,
                    'base64': base64,
                    'recordId': this.recordId,
                    'passVal': this.myVar
                }
                if (this.fileData != null) {
                    const { base64, filename, recordId, passVal } = this.fileData
                    uploadFile({ base64, filename, recordId, passVal }).then(result => {
                        this.fileData = null
                        let title = `${filename} uploaded successfully!!`
                        this.toast(title)
                        this.handleChildClick();
                        //  window.location.reload()
                    })
                }

            }
            reader.readAsDataURL(file)

        } else {
            var error = `File type should be ${fileTypes} & Size should be below ${this.fileSize} MB`
            this.toastError(error)
        }
    }

    async openBankfileUpload(event) {
        try {
            const file = event.detail.files[0];
            if (file) {
                const type = file.mimeType;
                const contentVersionId = file.contentVersionId;
                this.fileData = {
                    'filename': file.name,
                    'contentVersionId': contentVersionId,
                    'recordId': this.recordId,
                    'passVal': this.myVar
                };
                if (this.fileData != null) {
                    const { contentVersionId, filename, recordId, passVal } = this.fileData
                    uploadBankFile({ contentVersionId, filename, recordId, passVal }).then(result => {
                        this.fileData = null
                        let title = `${filename} uploaded successfully!!`
                        this.toast(title)
                        this.handleChildClick();
                    })
                }
            }
        } catch (error) {
            console.error("Error in Bank file Upload:", error);
        }
    }

    toast(title) {
        const toastEvent = new ShowToastEvent({
            title,
            variant: "success"
        })
        this.dispatchEvent(toastEvent)
    }

    toastError(title) {
        const toastEvent = new ShowToastEvent({
            title,
            variant: "Error"
        })
        this.dispatchEvent(toastEvent)
    }

    handleChildClick() {
        this.dispatchEvent(new CustomEvent('uploadfinished', {
            composed: true,
            bubbles: true,
            cancelable: true,
            detail: {
                data: { recordId: this.recordId }
            }
        }));
    }

}