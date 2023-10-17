import { LightningElement,track, api,wire } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import uploadFile from '@salesforce/apex/FileUploaderClass.uploadFile'
import uploadFileChunk from '@salesforce/apex/FileUploaderClassClone.uploadFileChunk'
import uploadChunkedFile from '@salesforce/apex/FileUploaderClassClone.uploadChunkedFile'
//const chunkSize = 2097152; // 2 MB (max size for a chunk)
const chunkSize = 750000;
export default class CustomFileUploadCloned extends LightningElement {
    @api recordId;
    @api acceptedFormats ;
    acceptedFormatssss =['.png'] ;
    @api fileUploaded;
    @api fileSize;
    @api docType;
    @track myVar;
    
    filesize = 0;
    fileData
    async openfileUpload(event) {
        debugger;
        console.log('###openfileUpload inside');
        const file = event.target.files[0]
        const type = file.type;
        const size = file.size;
        const fileSizeInByte = parseInt(this.fileSize) * 1048576;
        const fileTypes = this.acceptedFormats.replace(/image|\/|application/g,' ')
        console.log('fileTypes==>'+fileTypes);

        if(this.acceptedFormats.includes(type) && size <= fileSizeInByte){
        var reader = new FileReader()
        var self = this;

        reader.onload = function () {
            console.log('###Onloader inside');

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
            console.log('###fileContents '+fileContents);
            var base64Mark = 'base64,';
            var dataStart = fileContents.indexOf(base64Mark) + base64Mark.length;
            console.log('###dataStart '+dataStart);
            fileContents = fileContents.substring(dataStart);
            console.log('###fileContents '+fileContents);
            console.log('###file '+file);
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
        console.log('####chunk  '+chunk);
        console.log('####file.name  '+file.name);
        console.log('####chunk2  '+encodeURIComponent(chunk));
        console.log('####this.recordId  '+this.recordId);
        console.log('####cvId  '+cvId);
        console.log('####fromIndex  '+fromIndex);
        console.log('####toIndex  '+toIndex);
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
                console.log('###File Name:'+file.Name);
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