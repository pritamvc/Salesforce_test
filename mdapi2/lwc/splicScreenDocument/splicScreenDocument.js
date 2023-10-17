import { LightningElement,api,track } from 'lwc';

export default class SplicScreenDocument extends LightningElement {
    @api fileId;
    @api heightInRem;
    @track scaleFactor = 1; // Initial scale factor
    @track contentStyles = ''; // CSS styles for content
    @track imageStyles = '';
    PublicUrl='https://auxilo--dev.sandbox.my.salesforce.com/sfc/p/Bi0000007KA5/a/Bi0000003Hig/06TilH2oE06dG1TBRdWls7RyeY1l00aoWGZyN928S80';
    get url() {
      return this.PublicUrl;
        // return 'https://auxilo--dev.sandbox.my.salesforce.com/sfc/p/Bi0000007KA5/a/Bi0000003SW2/qiHKPTmr0GtQmbw355MWAShWP4py0eyMuzBErKd8pBQ';
        //return'https://auxilo--dev.sandbox.my.salesforce.com/sfc/p/Bi0000007KA5/a/Bi0000003SXd/pPDmwLBI6XPFXYx2MYpcPKqn19U0hQ7Fr0hu4MK._1Q'
        //return 'https://auxilo--dev.sandbox.my.salesforce.com/sfc/p/Bi0000007KA5/a/Bi0000003Sar/jZAF6O3dfUc4MQ0fXW9ZUhgy50Phxsj01Ooet7btrYM';
        //return'https://auxilo--dev.sandbox.my.salesforce.com/sfc/p/Bi0000007KA5/a/Bi0000003ZNp/u9LSl_Xvqz2umI.CUrUAHEwMxATovnFymDZy.dKV2d4'\
        //return PublicUrl;
        //return'https://auxilo--dev.sandbox.file.force.com/sfc/dist/version/download/?oid=00DBi0000007KA5&ids=068Bi0000013RxZ&d=%2Fa%2FBi0000003Hig%2F06TilH2oE06dG1TBRdWls7RyeY1l00aoWGZyN928S80&asPdf=false';
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
          //this.contentStyles = `transform: scale(${this.scaleFactor});`;
          this.imageStyles = `width: ${this.scaleFactor * 100}%; height: ${this.scaleFactor * 100}%;`;
        }
        get pdfHeight() {
            return 'height:  '+ this.heightInRem + 'rem';
          }

        
}