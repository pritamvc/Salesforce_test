import { LightningElement, wire } from 'lwc';
import getFieldMappings from '@salesforce/apex/FieldMappingController.getFieldMappings';

export default class DynamicFieldMappings extends LightningElement {
  fieldMappings;

  @wire(getFieldMappings)
  wiredFieldMappings({ data, error }) {
    if (data) {
      this.fieldMappings = data;
    } else if (error) {
      console.error(error);
    }
  }
}