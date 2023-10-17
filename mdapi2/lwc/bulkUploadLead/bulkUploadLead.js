import { LightningElement, api, track, wire } from 'lwc';
import getHeaderFieldMappings from '@salesforce/apex/BulkUploadLeadLWCController.getImportLineHeaderFieldMappings';
import saveUpdatedLineItems from '@salesforce/apex/BulkUploadLeadLWCController.saveLineItems';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { loadScript, loadStyle } from 'lightning/platformResourceLoader';
import jQuery from '@salesforce/resourceUrl/JQuery';
import sheetJS from '@salesforce/resourceUrl/SheetJS';



export default class BulkUploadLeadLWC extends LightningElement {
    @api recordId = '701Bi000005ABfJIAW';
    @track loading = false;
    @track loadingProgress = 0;
    librariesLoaded = false;
    @track error;
    @track success;

    get acceptedCSVFormats() {
        return ['.csv'];
    }

    renderedCallback() {
        if (!this.JQueryLoaded) {
            this.JQueryLoaded = true;
            loadScript(this, jQuery)
                .then(() => {
                })
                .catch(error => {
                    this.JQueryLoaded = false;
                });


        }
        if (!this.xlsxLoaded) {
            this.xlsxLoaded = true;
            loadScript(this, sheetJS)
                .then(() => {
                })
                .catch(error => {
                    this.xlsxLoaded = false;
                });
        }


    }

    headerFieldMappings;
    @track headerFieldMappingsResult;
    @wire(getHeaderFieldMappings, {})
    wiredHeaderFieldMappings(result) {
        this.headerFieldMappingsResult = result;

        const { data, error } = result;
        if (data) {
            this.headerFieldMappings = data;

        }
        if (error) {
        }
    }


    async download() {
        let _self = this;
        // When passing `objects` and `schema`.
        await writeXlsxFile(_self.objectsData, {
            schema: _self.schemaObj,
            fileName: 'file.xlsx'
        })
    }

    stopInfiniteLoadingInterval() {
        clearInterval(this._interval);
    }

    startInfiniteLoadingInterval() {
        this.loading = true;
        this.loadingProgress = 0;
        this._interval = setInterval(() => {
            this.loadingProgress = this.loadingProgress === 100 ? 0 : this.loadingProgress + 1;
        }, 10);
    }




    handleImportLines(event) {
        console.log('handleImportLines:2');

        const uploadedFiles = event.detail.files;
        console.log('uploadedFiles==> ' + JSON.stringify(uploadedFiles));
        if (uploadedFiles.length > 0) {
            this.processExcelFile(uploadedFiles[0]);
        }
    }

    @track errorMessagesToDisplay = '';

    processExcelFile(file) {
        console.log('processExcelFile====> ' + this.processExcelFile);
        var reader = new FileReader();
        reader.onload = event => {

            var data = event.target.result;
            console.log('data====:', data);
            var workbook = XLSX.read(data, {
                type: 'binary',
                raw: false
            });
            console.log('workbook===>: ', workbook);
            console.log('workbook.SheetNames:', workbook.SheetNames);

            let sheetsList = workbook.SheetNames;
            var excelData = XLSX.utils.sheet_to_json(
                workbook.Sheets[sheetsList[0]],
                {
                    raw: false
                });
            console.log('excelData==>', excelData);
            console.log('processExcelFile:2', excelData.length);

            if (excelData.length === 0) {
                console.log('recordsToUpdate:1');

                showNotification('Error while reading the file', 'test', 'error', 'pester');
            } else {
                console.log('recordId=====> ' + this.recordId);
                console.log('recordsToUpdate:2');

                var idFieldName = '';
                var headerFieldsMap = new Map();
                console.log('headerFieldsMap==>', headerFieldsMap);
                for (const [key, value] of Object.entries(this.headerFieldMappings)) {
                    headerFieldsMap.set(key, value);
                }
                console.log('headerFieldsMap  1  ====>', headerFieldsMap);
                var newLineItems = [];
                console.log('newLineItems==>', newLineItems);
                for (let rec of excelData) {
                    newLineItems.push(rec);
                }


                var recordsToInsert = this.executeLineItemsImportCreation(newLineItems, headerFieldsMap);
                console.log('recordsToInsert==>', recordsToInsert);
                this.saveLinesInBulk(recordsToInsert);

            }
        };
        reader.onerror = function (ex) {
            showNotification('Error while reading the file', ex.message, 'error', 'pester');
        };
        reader.readAsBinaryString(file);
    }

    chunkArray(myArray, chunk_size) {
        var results = [];
        while (myArray.length) {
            results.push(myArray.splice(0, chunk_size));
        }
        return results;
    }


    executeLineItemsImportCreation(newLineItems, headerFieldsMap) {

        var recordsToInsert = [];
        for (var rec of newLineItems) {
            var lineItem = { Campaign__c: '701Bi000005ABfJIAW', };
            for (const [key, value] of Object.entries(rec)) {
                if (headerFieldsMap.has(key)) {

                    var headerField = headerFieldsMap.get(key);
                    console.log(headerFieldsMap.get(key).Field_API_Name__c)
                    lineItem[headerFieldsMap.get(key).Field_API_Name__c] = this.getFormattedValueFromExcelField(headerField, value);
                }
            }
            recordsToInsert.push(lineItem);
        }
        return recordsToInsert;
    }

    saveLinesInBulk(recordsToUpdate) {
        console.log('saveLinesInBulk:', recordsToUpdate)
        if (recordsToUpdate.length > 0) {
            this.loading = true;
            this.loadingProgress = 0;

            var chunks = this.chunkArray(recordsToUpdate, 100);
            var chunkIndex = 0;
            var chunkSaveInProgress = false;

            if (chunks.length == 1) {
                this.startInfiniteLoadingInterval();
            }

            this._chunkSaveInterval = setInterval(() => {

                if (chunkSaveInProgress == false) {
                    chunkSaveInProgress = true;
                    var chunk = chunks[chunkIndex];
                    saveUpdatedLineItems({
                        jsonString: JSON.stringify(chunk), CampaignId: this.recordId
                    }).then(result => {

                        var responseWrapper = result;

                        chunkSaveInProgress = false;
                        chunkIndex++;

                        this.loadingProgress = (chunkIndex / chunks.length) * 100;

                        if (chunkIndex >= chunks.length) {
                            clearInterval(this._chunkSaveInterval);
                            if (chunks.length == 1) {
                                this.stopInfiniteLoadingInterval();
                            }
                            this.loading = false;
                        }
                        this.success = result;
                        if(this.success.startsWith("All Leads are Duplicate")){
                            this.dispatchEvent(
                                new ShowToastEvent({
                                    title: 'Error!!',
                                    message: this.success,
                                    variant: 'Error',
                                }),
                            );
                        }
                        else if(this.success.startsWith("Please ensure that you are inserting lead data only")){
                            this.dispatchEvent(
                                new ShowToastEvent({
                                    title: 'Error!!',
                                    message: this.success,
                                    variant: 'Error',
                                }),
                            );
                        }else{
                        this.dispatchEvent(
                            new ShowToastEvent({
                                title: 'Success!!',
                                message: this.success,
                                variant: 'Success',
                            }),
                        );
                    }

                    }).catch(error => {
                        console.log('Inside Catch');
                        chunkSaveInProgress = false;
                        chunkIndex++;

                        this.loadingProgress = (chunkIndex / chunks.length) * 100;

                        this.stopInfiniteLoadingInterval();
                        this.loading = false;
                        if (chunkIndex >= chunks.length) {
                            clearInterval(this._chunkSaveInterval);
                            if (chunks.length == 1) {
                                this.stopInfiniteLoadingInterval();
                            }
                            this.loading = false;

                        }
                        this.error = error;
                        console.log("this.error==== >" +  JSON.stringify(this.error));
                        this.dispatchEvent(
                            new ShowToastEvent({
                                title: 'Error!!',
                                message: 'Please ensure that you are inserting lead data only.',
                                variant: 'error',
                            }),
                        );  

                    })
                }
            }, 10);
        }
    }
    getFormattedValueFromExcelField(headerField, excelValue) {
        console.log('test getFormattedValueFromExcelField:');
        excelValue = excelValue.trim();
        var formattedValue;
        switch (headerField.Field_DataType__c) {
            case 'DATE':
                try {
                    let date = new Date(excelValue);
                    const tzOffsetMin = Math.abs(date.getTimezoneOffset()) // the minutes of the offset timezone
                    const tzOffsetHour = tzOffsetMin / 60; // timezone offset in hour
                    date.setHours(date.getHours() + tzOffsetHour);
                    formattedValue = date.toISOString().substr(0, 10);
                } catch (err) {
                    formattedValue = null;
                } finally {
                    break;
                }
            case 'PERCENT':
                formattedValue = parseFloat(excelValue);
                break;
            case 'CURRENCY':
                formattedValue = Number(excelValue.replace(/[^0-9.-]+/g, ""));
                break;
            case 'NUMBER':
                formattedValue = Number(excelValue.replace(/[^0-9.-]+/g, ""));
                break;
            default:
                formattedValue = excelValue;
                break;
        }
        console.log('test getFormattedValueFromExcelField:', formattedValue);

        return formattedValue;
    }

    showNotification(title, message, variant, mode) {
        const evt = new ShowToastEvent({
            title: title,
            message: message,
            variant: variant,
            mode: mode
        });
        dispatchEvent(evt);
    }

}