import { LightningElement,api,track,wire } from 'lwc';
import GetResourceURL from '@salesforce/apex/DisplayImageController.getResourceURL'
export default class Displayimage extends LightningElement {
  
    @api image ='';  
    @api Height;
    @api Width;
        @track imgURL= false;
        @track imgStyle;
    @wire(GetResourceURL,{resourceName : '$image'}) weire({data,error}){
        if (data) {
            this.imgURL = data;
            this.imgStyle = 'width : ' + this.Width + ';' + 'height:' + this.Height + ';';
            console.log(data);
        } 
        else if (error) {
            console.log(error);
        }
    }
}