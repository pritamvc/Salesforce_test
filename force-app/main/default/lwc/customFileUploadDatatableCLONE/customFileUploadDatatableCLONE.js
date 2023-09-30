import { LightningElement } from 'lwc';
import LightningDatatable from 'lightning/datatable';
import fileUpload from './fileuploadClone.html';

export default class CustomFileUploadDatatableCLONE extends LightningDatatable {
    static customTypes = {
        fileUpload: {
            template: fileUpload,
            typeAttributes: ['acceptedFormats','fileUploaded','fileSize','docType','subDocType'],
        }
    };

}