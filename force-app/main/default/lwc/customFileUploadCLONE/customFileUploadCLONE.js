import { LightningElement,track, api,wire } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import uploadFile from '@salesforce/apex/FileUploaderClass.uploadFile'
import uploadFileChunk from '@salesforce/apex/FileUploaderClassClone.uploadFileChunk'
import uploadChunkedFile from '@salesforce/apex/FileUploaderClassClone.uploadChunkedFile'
const chunkSize = 2097152; // 2 MB (max size for a chunk)
export default class CustomFileUploadCLONE extends LightningElement {
    @api recordId;
    @api acceptedFormats;
    @api fileUploaded;
    @api fileSize;
    @api docType;
    @track myVar;
    
    filesize = 0;
    fileData
    passwordChange(event){
        this.myVar = event.target.value;
        const inp = this.template.querySelectorAll(".inp");
        var code = this.template.querySelectorAll("lightning-input");        
        console.log('myVar'+this.myVar);
    }
    openfileUpload(event) {
        debugger;
        const file = event.target.files[0]
        const type = file.type;
        const size = file.size;
        const fileSizeInByte = parseInt(this.fileSize) * 1048576;
        const fileTypes = this.acceptedFormats.replace(/image|\/|application/g,' ')
        console.log('fileTypes==>'+fileTypes);

        if(this.acceptedFormats.includes(type) && size <= fileSizeInByte){
        var reader = new FileReader()
        var self = this;

        reader.onload = async () => {

           // const base64 = reader.result.split(',')[1];
           // const totalChunks = Math.ceil(base64.length / chunkSize);

            // for (let chunkNumber = 1; chunkNumber <= totalChunks; chunkNumber++) {
            //     const start = (chunkNumber - 1) * chunkSize;
            //     const end = start + chunkSize;
            //     const chunk = base64.slice(start, end);

            //     this.fileData = {
            //         filename: file.name,
            //         base64: chunk,
            //         recordId: this.recordId,
            //         passVal: this.myVar,
            //         chunkNumber: chunkNumber,
            //         totalChunks: totalChunks
            //     };

            //     await uploadFileChunk(this.fileData)
            //         .then((result) => {
            //             if (chunkNumber === totalChunks) {
            //                 const title = `${filename} uploaded successfully!!`;
            //                 this.toast(title);
            //                 this.handleChildClick();
            //             }
            //         })
            //         .catch((error) => {
            //             this.toastError(error.body.message);
            //         });
            // }
            var fileContents = reader.result;
            var base64Mark = 'base64,';
            var dataStart = fileContents.indexOf(base64Mark) + base64Mark.length;
            fileContents = fileContents.substring(dataStart);
            self.upload(file, fileContents);
                    
        };
        reader.readAsDataURL(file)        
             
    }else{
        var error = `File type should be ${fileTypes} & Size should be below ${this.fileSize} MB`
        this.toastError(error)
    }    
    }
    upload(file, fileContents){
        var fromIndex = 0;
        var toIndex = Math.min(fileContents.length, fromIndex + chunkSize);
        this.uploadChunk(file, fileContents, fromIndex, toIndex, '');
    }
    uploadChunk(file, fileContents, fromIndex, toIndex, cvId){
        var chunk = fileContents.substring(fromIndex, toIndex);
        uploadChunkedFile({ 
            recordId: this.recordId,
            fileName: file.name,
            fileContent: encodeURIComponent(chunk),
            contentVersionId: cvId
        }).then(result => {
            cvId = result;
            fromIndex = toIndex;
            toIndex = Math.min(fileContents.length, fromIndex + chunkSize);
            this.uploadedsize = toIndex;
            if (fromIndex < toIndex) {
                this.uploadChunk(file, fileContents, fromIndex, toIndex, cvId);  
            } else {
                let title = `${filename} uploaded successfully!!`
                this.toast(title)
                this.handleChildClick();
               // this.fileContent = '';
              //  this.fileName = '';
            }
        }).catch(error => {
            console.log('Error occured while uploading files: '+ error);
            this.toastError(error.body.message);
        });
    }

    
        toast(title){
            const toastEvent = new ShowToastEvent({
                title, 
                variant:"success"
            })
            this.dispatchEvent(toastEvent)
        }

        toastError(title){
            const toastEvent = new ShowToastEvent({
                title, 
                variant:"Error"
            })
            this.dispatchEvent(toastEvent)
        }
}