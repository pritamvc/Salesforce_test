import { LightningElement, api, track } from 'lwc';
import getBranch from '@salesforce/apex/LoanApplicationFormHelper.getBranch';

export default class BranchCustomLookup extends LightningElement {
    @api objectApiName;
    @api iconName;
    @api label;
    @api bankId;
    @api placeholder;
    @track selectedId;
    @api comboboxClass;
    @api objectFields;
    @api recordTypeId;
    @api value;
    @track clearList;
    
    picklistOrdered;
    searchResults;
    selectedSearchResult;
    options = [];
    
    connectedCallback() {
        getBranch({bankId:this.bankId})
            .then(result=>{
                let option=[];
                for (var key in result) {
                    option.push({ label: result[key].Name, value: result[key].Id});   
                }
                this.options = option;

                if (this.value !== '') {
                    const selectedName = this.options.find(option => option.value === this.value)?.label || '';
                    this.selectedValue = selectedName;
                    const inputField = this.template.querySelector('lightning-input');
                    if (inputField) {
                        inputField.value = selectedName;
                    }
                }
            })
            .catch(error=>{
                console.log('Error while getting bank branches'+JSON.stringify(error));
            })              
    }

    search(event) {
        const input = event.detail.value.toLowerCase();
        const result = this.options.filter((picklistOption) =>
            picklistOption.label.toLowerCase().includes(input)
            );
        this.searchResults = result;
        
        if(input == ''){

            this.selectedValue = input;
            const selectEvent = new CustomEvent('select', { detail: { selectedId: '', selectedName: '' } });
            this.dispatchEvent(selectEvent);
        }  
    }
    
    selectSearchResult(event) {
        const selectedValue = event.currentTarget.dataset.value;
        const selectedName = this.options.find(option => option.value === selectedValue)?.label || '';
        this.selectedValue = selectedName;
        const selectEvent = new CustomEvent('select', { detail: { selectedId: selectedValue, selectedName: selectedName } });
        this.dispatchEvent(selectEvent);
        this.clearSearchResults();   
    }
    
    clearSearchResults() {
        this.searchResults = null;
    }
    
    showPicklistOptions() {
        this.searchResults = this.options;
    }

    handleBranchSelection(event) {
        this.selectedId = event.detail.value;
        const selectedName = this.options.find(option => option.value === this.selectedId)?.label || '';
        const selectEvent = new CustomEvent('select', { detail: { selectedId: this.selectedId, selectedName: selectedName } });
        this.dispatchEvent(selectEvent);
    }

    clearTheList(){
        this.clearSearchResults();
    }
}