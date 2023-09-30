import { LightningElement } from 'lwc';
import documentUploadRender from './documentUploadRender.html';
import LightningDatatable from 'lightning/datatable';
import picklistColumn from './picklistColumn.html';
import pickliststatic from './pickliststatic.html'


export default class FileUploadDataTable extends LightningDatatable   {
    static customTypes = {   //it show that we are creating custom type
        fileUpload: {  // type of custom element
            template: documentUploadRender, // Which html will render
            typeAttributes: ['acceptedFileFormats','fileUploaded']  // attribute of that type
        },
        picklistColumn: {
            template: pickliststatic,
            editTemplate: picklistColumn,
            standardCellLayout: true,
            typeAttributes: ['label', 'placeholder', 'options', 'value', 'context', 'variant','name']
        }

    };
}