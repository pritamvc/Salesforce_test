import { LightningElement, api, track } from 'lwc';

export default class TestCourseSecRecEditForm extends LightningElement {

    @api recordId;
    @track countryOfStudy;
    @track universityName;
    @track instituteName;
    //1
    // connectedCallback() {
    //     console.log('this.template 1',this.template);
    //     // Get a reference to the University Name Lookup field input element
    //     const universityInput = this.template.querySelector('lightning-input-field[data-field-name="University_Name__c"]');
    //     console.log('universityInput', universityInput);
    //     console.log('this.template 2',this.template);
    //     // Set the Lookup filter on the University Name field
    //     if (universityInput) {
    //         universityInput.setLookupFilter({
    //             // Specify the API name of the object
    //             objectApiName: 'Lead',

    //             // Specify the filter criteria based on the record type
    //             filters: [
    //                 {
    //                     fieldName: 'Country_of_Study__c',
    //                     operator: 'equals',
    //                     value: '$Record.Country_of_Study__c'
    //                 }
    //             ]
    //         });
    //     }
    // }

    //2
    connectedCallback() {
        // Get a reference to the University Name field input element
        console.log('recordId', this.recordId);
        console.log('template.querySelectorAll 1', this.template.querySelectorAll('lightning-input-field'));
        const universityInput = this.template.querySelector('lightning-input-field[data-field-name="University_Name__c"]');
        console.log('universityInput 5', universityInput);
    
        // Get a reference to the Country of Study field input element
        const countryInput = this.template.querySelector('lightning-input-field[data-field-name="Country_of_Study__c"]');
        console.log('countryInput 5', countryInput);
    
        // Set the Lookup filter on the University Name field
        // universityInput.setLookupFilter({
        //     objectApiName: 'Lead',
        //     filters: [
        //         {
        //             fieldName: 'Country_of_Study__c',
        //             operator: 'equals',
        //             value: countryInput.value
        //         }
        //     ]
        // });
    }

    //3
    // connectedCallback() {
    //     console.log('this.recordId', this.recordId);
    //     if (this.recordId) {
    //         // Get a reference to the Account Lookup field input element
    //         const universityInput = this.template.querySelector('lightning-input-field[data-field-name="University_Name__c"]');
    //         console.log('universityInput', universityInput);
           
    //         // Set the Lookup filter on the Account field
    //         universityInput.setLookupFilter({
    //             // Specify the API name of the Account object
    //             objectApiName: 'Lead',
    
    //             // Specify the filter criteria based on the Account record type
    //             // For example, this filter only shows Accounts with the record type "Customer"
    //             filters: [
    //                 {
    //                     fieldName: 'Country_of_Study__c',
    //                     operator: 'equals',
    //                     value: 'University_Name__r.Country_Name__c'
    //                 }
    //             ]
    //         });
    //     }
    // }
    
    

    handleInputChange(event) {
        // Handle the field value change event
        if (event.target.name == "Country_of_Study__c" && event.target.value != "") {
           this.countryOfStudy = event.target.value;
            console.log(" this.countryOfStudy 5====  " + this.countryOfStudy);
        }
        if (event.target.name == "University_Name__c" && event.target.value != "") {
            this.universityName = event.target.value;
             console.log(" this.universityName 5====  " + this.universityName);
         }
         if (event.target.name == "Institute_Name__c" && event.target.value != "") {
            this.instituteName = event.target.value;
             console.log(" this.instituteName 5====  " + this.instituteName);
         }
    }

}