import { LightningElement, wire } from 'lwc';
import getApplicantData from '@salesforce/apex/ApplicantController.getApplicantData';

export default class ApplicantDataLWC extends LightningElement {
    applicantData;

    @wire(getApplicantData)
    wiredData({ error, data }) {
        if (data) {
            this.applicantData = data;
        } else if (error) {
            console.error('Error retrieving applicant data:', error);
        }
    }
}