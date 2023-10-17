import { LightningElement, track, api, wire } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import uploadFile from '@salesforce/apex/FileUploaderClass.uploadFile'
export default class PocCustomComp extends LightningElement {

    @api recordId;
    @api acceptedFormats;
    @api fileUploaded;
    @api fileSize;
    fileData
    openfileUpload(event) {
        console.log('recordId'+this.recordId);
        console.log('recordId'+this.acceptedFormats);
        const file = event.target.files[0]
        const type = file.type;
        const size = file.size;
        if(this.acceptedFormats.includes(type) && size <= this.fileSize){
        var reader = new FileReader()
        reader.onload = () => {
            var base64 = reader.result.split(',')[1]
            this.fileData = {
                'filename': file.name,
                'base64': base64,
                'recordId': this.recordId
            }
            if(this.fileData != null){
            const {base64, filename, recordId} = this.fileData
            uploadFile({ base64, filename, recordId }).then(result=>{
            this.fileData = null
            let title = `${filename} uploaded successfully!!`
            this.toast(title)
        })
        }  
           // console.log(this.fileData)          
        }
        reader.readAsDataURL(file)        
             
    }else{
        var error = "File type should be(PDF, JPEG, JPG, PNG) & Size should be below 1 MB"
        this.toastError(error)
    }    
    }
    
  /*  handleClick(){
        const {base64, filename, recordId} = this.fileData
        uploadFile({ base64, filename, recordId }).then(result=>{
            this.fileData = null
            let title = `${filename} uploaded successfully!!`
            this.toast(title)
        })
    }*/

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
    

    
  /*  @api recordId;
    @api acceptedFormats;
    handleUploadFinished() {
        this.dispatchEvent(new CustomEvent('uploadfinished', {
            composed: true,
            bubbles: true,
            cancelable: true,
            detail: {
                data: { name: 'some data', recordId: this.recordId }
            }
        }));
        this.dispatchEvent(new ShowToastEvent({
            title: 'Completed',
            message: 'File has been uploaded',
        }));
    }*/
}