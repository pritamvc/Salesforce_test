import { LightningElement } from 'lwc';
import LightningDatatable from 'lightning/datatable';
import fileUpload from './fileUpload.html';

export default class CustomFileUploadDatatable extends LightningDatatable {
    static customTypes = {
        fileUpload: {
            template: fileUpload,
            typeAttributes: ['acceptedFormats','fileUploaded','fileSize','docType','subDocType'],
        }
    };

//    handleParentMethod(){
//     console.log('testtttttttttttttttttt')
//    }
}