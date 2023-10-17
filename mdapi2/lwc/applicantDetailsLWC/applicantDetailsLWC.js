import { LightningElement, api, wire } from 'lwc';
import { loadStyle } from 'lightning/platformResourceLoader';
import Auxilologo from '@salesforce/resourceUrl/Auxilologo';

export default class ApplicantDetailsLWC extends LightningElement {
    @api applicantData;
    logoUrl;

    connectedCallback() {
        // Load the logo resource
        this.logoUrl = Auxilologo;
        loadStyle(this, this.logoUrl + '/Auxilologo.css');
    }
}