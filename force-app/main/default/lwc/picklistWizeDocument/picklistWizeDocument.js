import { LightningElement, api, track } from 'lwc';
import getPicklistValues from '@salesforce/apex/GetPublicUrl.picklistValue';
import getpublicUrl from '@salesforce/apex/GetPublicUrl.getDistributionPublicUrl';
import getapplicant from '@salesforce/apex/GetPublicUrl.applicantname';
// new
// import { subscribe, MessageContext } from 'lightning/messageService';
// import applicantIdNew from '@salesforce/messageChannel/picklistwizeDocument__c';
//new 

export default class PicklistWizeDocument extends LightningElement {
    @api fileId;
    @api heightInRem;
    @track scaleFactor = 1; // Initial scale factor
    @track contentStyles = ''; // CSS styles for content
    @track imageStyles = '';
    @track PublicUrl;
    @api recordId;
    selectedValue = ''; // Initialize the selected value
    picklistOptions = [];
    applicantlist = [];
    selectedapplicant = '';

    @api inputevalue;
    // connectedCallback() {
    //     // This code will run when the component is connected to the DOM
    //     this.handleLoad(); // You can call your handling function here
    // }
    // handleLoad() {
    //     // Your onload logic goes here
    //     console.log('The applicant id is ',this.inputevalue);
    // }

    connectedCallback() {
        // First, call this.applicantpicklist()
        //this.handleSubscribe();
        this.applicantpicklist().then(() => {
            // After this.applicantpicklist() completes, call this.loadPicklistValues()
            this.loadPicklistValues();
        }).catch(error => {
            // Handle any errors here
            console.error('Error:', error);
        });
    }

    applicantpicklist() {
        return new Promise((resolve, reject) => {
            getapplicant({
                Deal: this.recordId,
            })
                .then(result => {
                    this.applicantlist = result.map(option => ({
                        label: option.Name,
                        value: option.Id,
                    }));
                    console.log('loadPicklistValues:');
                    resolve(); // Resolve the promise when this operation is complete
                })
                .catch(error => {
                    // Reject the promise if there's an error
                    reject(error);
                });
        });
    }

    loadPicklistValues() {
        getPicklistValues({
            leadId: this.recordId,
            applicantId: this.selectedapplicant,
        })
            .then(result => {
                this.picklistOptions = result.map(option => ({
                    label: option.Doc_Sub_Type__c,
                    value: option.Id,
                }));
            })
            .catch(error => {
                // Handle any errors here
                console.error('Error:', error);
            });
    }

    handleChange(event) {
        this.selectedValue = event.detail.value;

        // Print the selected value to the console
        console.log('Selected Value: ' + this.selectedValue);
        console.log('Deal id' + this.recordId);
        getpublicUrl({
            Docid: this.selectedValue,
        })
            .then(result => {
                console.log('URL' + result);
                this.PublicUrl = result;
            });
    }

    handleChangenew(event) {
        this.selectedapplicant = event.detail.value;

        // Print the selected value to the console
        console.log('Selected Value: ' + this.selectedapplicant);
        this.loadPicklistValues();
    }

    zoomIn() {
        this.scaleFactor += 0.1;
        this.updateContentStyles();
    }

    zoomOut() {
        this.scaleFactor -= 0.1;
        this.updateContentStyles();
    }

    updateContentStyles() {
        this.imageStyles = `width: ${this.scaleFactor * 100}%; height: ${this.scaleFactor * 100}%;`;
    }

    get pdfHeight() {
        return 'height: ' + this.heightInRem + 'rem';
    }

    // handleSubscribe() {
    //     //debugger
    //     subscribe(this.MessageContext, applicantIdNew , (inputevalue) => {
    //         console.log('$$$$$$$$$Inputevalue##########  ',inputevalue);
    //         this.publisherMessage = inputevalue;
    //     });
    // }
}