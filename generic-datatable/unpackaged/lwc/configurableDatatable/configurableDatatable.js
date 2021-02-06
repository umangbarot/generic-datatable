import { api, LightningElement, track } from 'lwc';
import getTableDetails from '@salesforce/apex/DatatableController.getTableDetails';
import { subscribe, unsubscribe, onError, setDebugFlag, isEmpEnabled } from 'lightning/empApi';
let i=0;

export default class ConfigurableDatatable extends LightningElement {
    @track showspinner = false;
    @track page = 1; //this is initialize for 1st page
    @track items = []; //it contains all the records.
    @track data = []; //data to be display in the table
    @track columns; //holds column info.
    @track startingRecord = 1; //start record position per page
    @track endingRecord = 0; //end record position per page
    @track pageSize = 10; //default value we are assigning
    @track totalRecountCount = 0; //total record count received from all retrieved records
    @track totalPage = 0; //total number of page is needed to display all records
    @api DataTableSettingId;
    @api FilterString;
    @api SortString;
    @track settinglink;
    
    channelName = '/event/Datatable_Column_Update__e';
    subscription = {};

    connectedCallback() {
        // initialize component
        this.showspinner = true;
        this.settinglink = '/' + this.DataTableSettingId;
        this.showTableData();

        // Callback invoked whenever a new event message is received
        const messageCallback = (response) => {
            var messageId = response.data.payload.Datatable_Object_Setting_Id__c;
            if(messageId == this.DataTableSettingId.substr(0, 15)){
                this.showTableData();
            }
        };

        // Invoke subscribe method of empApi. Pass reference to messageCallback
        subscribe(this.channelName, -1, messageCallback).then(response => {
            // Response contains the subscription information on successful subscribe call
            console.log('Successfully subscribed to : ', JSON.stringify(response.channel));
            this.subscription = response;
        });
    }

    showTableData(){
        getTableDetails({'DataTableSettingId' : this.DataTableSettingId, 'FilterString' : this.FilterString, 'SortString' : this.SortString}).then(result => {
            var response = JSON.parse(JSON.stringify(result));
            this.items = JSON.parse(response.data);
            this.totalRecountCount = this.items.length;
            this.totalPage = Math.ceil(this.totalRecountCount / this.pageSize);
            
            //initital data to be displayed ----------->
            //slice will take 0th element and ends with 10, but it doesn't include 10th element
            //so 0 to 10th rows will be display in the table
            this.data = this.items.slice(0,this.pageSize); 
            this.endingRecord = this.pageSize;

            this.columns = JSON.parse(response.columns);
            this.showspinner = false;
        }).catch(error => {
            console.log(error);
            //this.error = error;
        });
    }

    //clicking on previous button this method will be called
    previousHandler() {
        if (this.page > 1) {
            this.page = this.page - 1; //decrease page by 1
            this.displayRecordPerPage(this.page);
        }
    }

    //clicking on next button this method will be called
    nextHandler() {
        if((this.page<this.totalPage) && this.page !== this.totalPage){
            this.page = this.page + 1; //increase page by 1
            this.displayRecordPerPage(this.page);            
        }             
    }

    //this method displays records page by page
    displayRecordPerPage(page){

        /*let's say for 2nd page, it will be => "Displaying 6 to 10 of 23 records. Page 2 of 5"
        page = 2; pageSize = 5; startingRecord = 5, endingRecord = 10
        so, slice(5,10) will give 5th to 9th records.
        */
        this.startingRecord = ((page -1) * this.pageSize) ;
        this.endingRecord = (this.pageSize * page);

        this.endingRecord = (this.endingRecord > this.totalRecountCount) 
                            ? this.totalRecountCount : this.endingRecord; 

        this.data = this.items.slice(this.startingRecord, this.endingRecord);

        //increment by 1 to display the startingRecord count, 
        //so for 2nd page, it will show "Displaying 6 to 10 of 23 records. Page 2 of 5"
        this.startingRecord = this.startingRecord + 1;
    }
}