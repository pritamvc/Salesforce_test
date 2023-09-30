import { LightningElement, wire, api, track } from 'lwc';
import { getObjectInfo } from 'lightning/uiObjectInfoApi';
import LEAD_OBJECT from '@salesforce/schema/Lead';
import { getPicklistValues } from 'lightning/uiObjectInfoApi';
import COURSE_SUB_STREAM from '@salesforce/schema/Lead.Course_Sub_Stream__c';
import COURSE_STREAM from '@salesforce/schema/Lead.Course_Stream__c';

import { getPicklistValuesByRecordType } from 'lightning/uiObjectInfoApi';

export default class TestCourseStreamPicklist extends LightningElement {

    @track courseSubStreamOptions;
    @track courseStreamOptions;
    @track CSubStreamFieldData;
    @wire(getObjectInfo, { objectApiName: LEAD_OBJECT })
    leadInfo;

    @wire(getPicklistValues, { recordTypeId: '$leadInfo.data.defaultRecordTypeId', fieldApiName: COURSE_SUB_STREAM })
    slaFieldInfo({ data, error }) {
        if (data) {
            console.log('DATA SUB STREAM 1:', data);
            this.CSubStreamFieldData = data.values;
            console.log('this.CSubStreamFieldData SUB STREAM 1:', this.CSubStreamFieldData);

        } else {
            console.log('Error fetching Course Sub Stream picklist values:', error);
        }
    }

    @wire(getPicklistValues, { recordTypeId: '$leadInfo.data.defaultRecordTypeId', fieldApiName: COURSE_STREAM })
    upsellFieldInfo({ data, error }) {
        if (data) {
            console.log('DATA STREAM 1:', data);
            this.courseStreamOptions = data.values;
            console.log('this.courseStreamOptions STREAM:', this.courseStreamOptions);
        } else {
            console.log('Error fetching Course Stream picklist values 1:', error);
        }
    }

    handleCourseStreamChange(event) {
        let key = this.CSubStreamFieldData.controllerValues[event.target.value];
        console.log(' let key==>', key);
        console.log('handle 1 this.courseSubStreamOptions==>', this.courseSubStreamOptions);
        this.courseSubStreamOptions = this.CSubStreamFieldData.values.filter(opt => opt.validFor.includes(key));
        console.log('handle 2 this.courseSubStreamOptions==>', this.courseSubStreamOptions);
    }

    //DIFFERENT CODE
    courseSubStreamValues; //carValues;
   courStreamValue; //carColorValues;
   selectedCourSubStreamValue = '';  //selectedCarValue = '';
   picklistValuesObj;
   selectedCourStreamValue = '';  //selectedCarColorValue = '';
   // method to get Picklist values based on record type and dependant values too
   @wire(getPicklistValuesByRecordType, { objectApiName: 'Lead', recordTypeId: '012Bi00000017XJIAY' })
   newPicklistValues({ error, data }) {
       if (data) {
           this.error = null;
           this.picklistValuesObj = data.picklistFieldValues;
           console.log('data returned' + JSON.stringify(data.picklistFieldValues));
           //let carValueslist = data.picklistFieldValues.Car_Name__c.values;
           let courseSubStreamList = data.picklistFieldValues.Course_Sub_Stream__c.values;
           //let carValues = [];
           let courseSubStreamValues = [];
           //Iterate the picklist values for the car name field
           for (let i = 0; i < courseSubStreamList.length; i++) {
            courseSubStreamValues.push({
                   label: courseSubStreamList[i].label,
                   value: courseSubStreamList[i].value
               });
           }
           this.courseSubStreamValues = courseSubStreamValues;
           console.log('data courseSubStreamValues' + JSON.stringify(this.courseSubStreamValues));
       }
       else if (error) {
           this.error = JSON.stringify(error);
           console.log(JSON.stringify(error));
       }
   }
   
   handleCarChange(event) {
      // this.selectedCarValue = event.detail.value;
      this.selectedCourSubStreamValue = event.detail.value;
       if (this.selectedCourSubStreamValue) {
           let data = this.picklistValuesObj; 
           //let totalCarColorValues = data.Car_Color__c;
           let totalCourseStreamValues = data.Course_Stream__c;
           //Getting the index of the controlling value as the single value can be dependant on multiple controller value
           
           //let controllerValueIndex = totalCarColorValues.controllerValues[this.selectedCarValue];
           let controllerValueIndex = totalCourseStreamValues.controllerValues[this.selectedCourSubStreamValue];
           //let colorPicklistValues = data.Car_Color__c.values;
           let courseStreamPicklistValues = data.Course_Stream__c.values;
           //let carColorPicklists = [];
           let courseStreamPicklists = [];
           //Iterate the picklist values for the car name field
           courseStreamPicklistValues.forEach(key => {
               for (let i = 0; i < key.validFor.length; i++) {
                   if (controllerValueIndex == key.validFor[i]) {
                    courseStreamPicklists.push({
                           label: key.label,
                           value: key.value
                       });
                   }
               }
           })
           console.log(' data courseStreamPicklists' + JSON.stringify(courseStreamPicklists));
           if (courseStreamPicklists && courseStreamPicklists.length > 0) {
               this.courStreamValue = courseStreamPicklists;
           }
       }
   }
   handleCarColorChange(event){
       //this.selectedCarColorValue = event.detail.value;
       this.selectedCourStreamValue = event.detail.value;
   }
}