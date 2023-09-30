import { LightningElement, api, track, wire } from 'lwc';
import getHeaderFieldMappings from '@salesforce/apex/BulkUploadLeadsForPartners.getImportLineHeaderFieldMappings';
import createBulkLeads from '@salesforce/apex/BulkUploadLeadsForPartners.createBulkLeads';
import dynamicBulkUploadLeadsCSVTemplate from '@salesforce/apex/Utility.dynamicBulkUploadLeadsCSVTemplate';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { loadScript, loadStyle } from 'lightning/platformResourceLoader';
import jQuery from '@salesforce/resourceUrl/JQuery';
import sheetJS from '@salesforce/resourceUrl/SheetJS';
import LeadExcelFormatCSV from '@salesforce/resourceUrl/Bulk_Upload_Leads_CSV_TemplateNew';
import { NavigationMixin } from 'lightning/navigation';
import BulkLeadUploadConsentHelpText from '@salesforce/label/c.Bulk_Lead_Upload_Consent_HelpText';
export default class BulkUploadLeadsForPartners extends NavigationMixin(LightningElement) {
    @api recordId
    @track loading = false;
    @track loadingProgress = 0;
    librariesLoaded = false;
    @track error;
    @track success;
    @track csvHeader;
    @track consentVeriable = false;
    @track stageVeriable = 'Fresh';
    @track executeClass = true;
    @track MetadataUnmatchedValue;
    staticResourcecsv = LeadExcelFormatCSV;
    @track csvFileTittle;
    @track resultHeader;
    @track errorHeader;
    @track errorCountInDateFormate = 0;
    @track BulkLeadUploadConsentHelpText = BulkLeadUploadConsentHelpText;
    
    get acceptedCSVFormats() {
        return ['.csv'];
    }

    handleInstituteSelection(event) {
        if (event.target.name == "AccountPartner") {
            this.recordId = event.target.value;
        }
        if (event.target.name == "Consent") {
            this.consentVeriable = event.target.checked;
        }
        if (event.target.name == "Stage") {
            this.stageVeriable = event.target.value;
        }
    }

    get AppliCategoryOptions() {
        return [
            { label: 'Fresh', value: 'Fresh' },
            { label: 'Sales Processing', value: 'Sales Processing' },
        ];
    }

    downloadTemplate() {
        dynamicBulkUploadLeadsCSVTemplate()
            .then(result => {
                let csvString = '';
                this.resultHeader = result;
                csvString = this.resultHeader;

                let downloadElement = document.createElement('a');

                // This  encodeURI encodes special characters, except: , / ? : @ & = + $ # (Use encodeURIComponent() to encode these characters).
                downloadElement.href = 'data:text/csv;charset=utf-8,' + encodeURI(csvString);
                downloadElement.target = '_self';
                // CSV File Name
                downloadElement.download = 'Bulk Upload Leads Template.csv';
                // below statement is required if you are using firefox browser
                document.body.appendChild(downloadElement);
                // click() Javascript function to download CSV file
                downloadElement.click();
            })
            .catch(error => {
                this.errorHeader = error;
                // handle any errors
                console.log(this.errorHeader);
            });
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

        if (this.librariesLoaded) return;
        this.librariesLoaded = true;
        loadScript(this, LeadExcelFormatCSV)
            .then(data => {
            })
            .catch(error => {
            });

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
            this.loadingProgress = this.loadingProgress === 5001 ? 0 : this.loadingProgress + 1;
        }, 100);
    }




    handleImportLines(event) {
        const uploadedFiles = event.detail.files;
        if (uploadedFiles.length > 0) {
            this.processExcelFile(uploadedFiles[0]);
        }
    }

    @track errorMessagesToDisplay = '';

    processExcelFile(file) {
        this.fileUpload = file;
        let csvFileName = this.fileUpload.name;
        if (!this.fileUpload.name.endsWith('.csv') || csvFileName.endsWith('.docx')) {
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Error!!',
                    message: 'Please upload CSV file only.',
                    variant: 'Error',
                }),
            );
        } else {
            var reader = new FileReader();
            reader.onload = event => {
                var data = event.target.result;
                var header = data.split(/[\r\n]+/)[0];
                this.csvHeader = header;
                var arrayHeader = header.split(',');

                var workbook = XLSX.read(data, {
                    type: 'binary',
                    raw: false
                });
                let sheetsList = workbook.SheetNames;
                var excelData = XLSX.utils.sheet_to_json(
                    workbook.Sheets[sheetsList[0]],
                    {
                        raw: false
                    });
                if (excelData.length === 0) {
                    this.dispatchEvent(
                        new ShowToastEvent({
                            title: 'Error!!',
                            message: 'Please ensure the csv file should not be blank.',
                            variant: 'Error',
                        }),
                    );

                } else {
                    var headerFieldsMapFieldValue = new Map();
                    for (const [key, value] of Object.entries(this.headerFieldMappings)) {
                        headerFieldsMapFieldValue.set(key, value);
                    }
                    const Metadatafield = headerFieldsMapFieldValue.keys();

                    var MatadataFieldarray = Array.from(Metadatafield);
                    var setInvalidValue = new Set();
                    arrayHeader.forEach(function (arrayHeader) {
                        if (!MatadataFieldarray.includes(arrayHeader)) {
                            setInvalidValue.add(arrayHeader);
                        }
                    });
                    const str1 = Array.from(setInvalidValue).join(',');;
                    if (((!arrayHeader.includes("First Name") && !arrayHeader.includes("Last Name")) ||
                        !arrayHeader.includes("Name")) && !arrayHeader.includes("Email") && !arrayHeader.includes("Mobile Number")) {
                        this.dispatchEvent(
                            new ShowToastEvent({
                                title: 'Error!!',
                                message: 'Please make sure you are uplodading Only csv format with Proper field Name.',
                                variant: 'Error',
                            }),
                        );
                        this.executeClass = false;
                    } else if (setInvalidValue.size > 0) {


                        this.MetadataUnmatchedValue = arrayHeader;
                        var errorforMetadata = 'CSV contains invalid field(s) in header : ' + ' ' + str1
                        this.dispatchEvent(
                            new ShowToastEvent({
                                title: 'Error!!',
                                message: errorforMetadata,
                                variant: 'Error',
                            }),
                        );
                        this.executeClass = false;
                    } else if (!arrayHeader.includes("First Name")) {
                        this.dispatchEvent(
                            new ShowToastEvent({
                                title: 'Error!!',
                                message: 'Please make sure the csv include "First Name" column csv.',
                                variant: 'Error',
                            }),
                        );
                        this.executeClass = false;
                    } else if (!arrayHeader.includes("Last Name") && !arrayHeader.includes("Name")) {
                        this.dispatchEvent(
                            new ShowToastEvent({
                                title: 'Error!!',
                                message: 'Please make sure the csv include "Last Name" Or "Name" column in csv.',
                                variant: 'Error',
                            }),
                        );
                        this.executeClass = false;
                    } else if (!arrayHeader.includes("Email")) {
                        this.dispatchEvent(
                            new ShowToastEvent({
                                title: 'Error!!',
                                message: 'Please make sure the csv include "Email" column csv.',
                                variant: 'Error',
                            }),
                        );
                        this.executeClass = false;
                    } else if (this.csvHeader.startsWith('PK')) {
                        this.dispatchEvent(
                            new ShowToastEvent({
                                title: 'Error!!',
                                message: 'Please make sure you are Uploading csv format only.',
                                variant: 'Error',
                            }),
                        );
                        this.executeClass = false;
                    } else if (!arrayHeader.includes("Mobile Number")) {
                        this.dispatchEvent(
                            new ShowToastEvent({
                                title: 'Error!!',
                                message: 'Please make sure the csv include "Mobile Number" column csv.',
                                variant: 'Error',
                            }),
                        );
                        this.executeClass = false;
                    } else if ((!arrayHeader.includes("User Name")) && this.stageVeriable == 'Sales Processing') {
                        this.dispatchEvent(
                            new ShowToastEvent({
                                title: 'Error!!',
                                message: 'Please make sure the csv include "User Name" column csv.',
                                variant: 'Error',
                            }),
                        );
                        this.executeClass = false;
                    } else {
                        this.executeClass = true;
                    }

                    this.csvFileTittle = csvFileName.replace(".csv", "");
                    var idFieldName = '';
                    var headerFieldsMap = new Map();
                    for (const [key, value] of Object.entries(this.headerFieldMappings)) {
                        headerFieldsMap.set(key, value);
                    }
                    var newLineItems = [];
                    for (let rec of excelData) {
                        newLineItems.push(rec);
                    }

                    if (this.executeClass == true) {
                        var recordsToInsert = this.executeLineItemsImportCreation(newLineItems, headerFieldsMap);
                        if (this.errorCountInDateFormate == 0) {
                            this.saveLinesInBulk(recordsToInsert);
                        } else {
                            this.dispatchEvent(
                                new ShowToastEvent({
                                    title: 'Error!!',
                                    message: 'Invalid date in ' + ' " ' + this.errorCountInDateFormate + ' " ' + ' places. Please enter dates in DD/MM/YYYY format.',
                                    variant: 'Error',
                                    mode: 'sticky',
                                }),
                            );
                        }
                    }

                }
            };
            reader.onerror = function (ex) {
                showNotification('Error while reading the file', ex.message, 'error', 'pester');
            };
            reader.readAsBinaryString(file);
        }
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
            var lineItem = { ErrorMessage__c: '', KYC_Consent__c: this.consentVeriable, Status: this.stageVeriable, };
            for (const [key, value] of Object.entries(rec)) {
                if (headerFieldsMap.has(key)) {

                    var headerField = headerFieldsMap.get(key);
                    lineItem[headerFieldsMap.get(key).Field_API_Name__c] = this.getFormattedValueFromExcelField(headerField, value);
                }
            }
            recordsToInsert.push(lineItem);
        }
        return recordsToInsert;
    }

    saveLinesInBulk(recordsToUpdate) {
        if (recordsToUpdate.length > 0) {
            this.loading = true;
            this.loadingProgress = 0;

            var chunks = this.chunkArray(recordsToUpdate, 5001);
            var chunkIndex = 0;
            var chunkSaveInProgress = false;

            if (chunks.length == 1) {
                this.startInfiniteLoadingInterval();
            }

            this._chunkSaveInterval = setInterval(() => {

                if (chunkSaveInProgress == false) {
                    chunkSaveInProgress = true;
                    var chunk = chunks[chunkIndex];
                    createBulkLeads({
                        jsonString: JSON.stringify(chunk), accountId: this.recordId,
                        headerFromCSV: this.csvHeader, csvFileTittle: this.csvFileTittle
                    }).then(result => {

                        var responseWrapper = result;

                        chunkSaveInProgress = false;
                        chunkIndex++;

                        this.loadingProgress = (chunkIndex / chunks.length) * 5001;

                        if (chunkIndex >= chunks.length) {
                            clearInterval(this._chunkSaveInterval);
                            if (chunks.length == 1) {
                                this.stopInfiniteLoadingInterval();
                            }
                            this.loading = false;
                        }
                        this.success = result;
                        if (this.success.startsWith('All the leads have error')) {
                            this.dispatchEvent(
                                new ShowToastEvent({
                                    title: 'Error!!',
                                    message: this.success,
                                    variant: 'Error',
                                }),
                            );
                        }
                        else if (this.success.startsWith("Error :")) {
                            this.dispatchEvent(
                                new ShowToastEvent({
                                    title: 'Error!!',
                                    message: this.success,
                                    variant: 'Error',
                                }),
                            );
                        } else {
                            this.dispatchEvent(
                                new ShowToastEvent({
                                    title: 'Success!!',
                                    message: this.success,
                                    variant: 'Success',
                                }),
                            );

                        }
                        this.navigateToObjectHome();
                    }).catch(error => {
                        chunkSaveInProgress = false;
                        chunkIndex++;

                        this.loadingProgress = (chunkIndex / chunks.length) * 5001;

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

                    })
                }
            }, 10);
        }

    }

    getFormattedValueFromExcelField(headerField, excelValue) {

        excelValue = excelValue.trim();

        var formattedValue;
        var formattedDate;

        switch (headerField.Field_Data_Type__c) {

            case 'DATE':
                if (excelValue.includes("/")) {
                    formattedDate = this.formatDate(excelValue);
                    if (formattedDate.startsWith("Invalid date")) {
                        this.errorCountInDateFormate = this.errorCountInDateFormate + 1;
                        this.dateFormatCorrect = false;
                        this.updateRecordView();

                    } else {
                        formattedValue = formattedDate;
                    }
                } else {
                    this.errorCountInDateFormate = this.errorCountInDateFormate + 1;
                    this.dateFormatCorrect = false;
                    this.updateRecordView();

                }

                break;
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

        return formattedValue;
    }

    formatDate(dateStr) {
        var formattedValue;
        const parts = dateStr.split('/');
        const day = parts[0];
        const month = parts[1];
        let year = parts[2];

        if (year.length === 2) {
            year = "20" + year;
        }
        var dateString = year + '-' + month + '-' + day;
        formattedValue = this.handleValidations(dateString);
        return formattedValue;
    }

    handleValidations(dateStr) {
        var formattedValue;
        let inputDate = dateStr;
        let dateArray = inputDate.split('-');

        if (dateArray.length !== 3) {
            formattedValue = 'Invalid date. Please enter a valid date in DD/MM/YYY format.';
        } else {
            formattedValue = dateStr;
        }

        let year = parseInt(dateArray[0]);
        let month = parseInt(dateArray[1]);
        let day = parseInt(dateArray[2]);

        var originalDateInput = 'Invalid date. Please enter a valid date in DD/MM/YYY format ' + ': ' + day + '/' + month + '/' + year;

        switch (month) {
            case 1: // January
            case 3: // March
            case 5: // May
            case 7: // July
            case 8: // August
            case 10: // October
            case 12: // December
                if (day < 1 || day > 31) {
                    formattedValue = originalDateInput;
                } else {
                    formattedValue = dateStr;
                }
                break;
            case 4: // April
            case 6: // June
            case 9: // September
            case 11: // November
                if (day < 1 || day > 30) {
                    formattedValue = originalDateInput;
                } else {
                    formattedValue = dateStr;
                }
                break;
            case 2: // February
                let isLeapYear = ((year % 4 === 0) && (year % 100 !== 0)) || (year % 400 === 0);
                if (isLeapYear && (day < 1 || day > 29)) {
                    formattedValue = originalDateInput;
                } else if (!isLeapYear && (day < 1 || day > 28)) {
                    formattedValue = originalDateInput;
                } else {
                    formattedValue = dateStr;
                }
                break;
            default:
                formattedValue = originalDateInput;
        }
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

    updateRecordView() {
        setTimeout(() => {
            eval("$A.get('e.force:refreshView').fire();");
        }, 1000);
    }

    navigateToObjectHome() {
        // Navigate to the Account home page
        this[NavigationMixin.Navigate]({
            type: 'standard__recordPage',
            attributes: {
                recordId: this.recordId,
                objectApiName: 'Account',
                actionName: 'view',
            },
        });
    }

}