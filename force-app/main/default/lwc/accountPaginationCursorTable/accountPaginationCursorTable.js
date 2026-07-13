import { LightningElement,track } from 'lwc';
import getAccounts from '@salesforce/apex/AccountPaginationController.getAccounts';
export default class AccountPaginationCursorTable extends LightningElement {
    
    @track accounts = [];
    @track columns = [
        { label: 'Name', fieldName: 'Name' },
        { label: 'Industry', fieldName: 'Industry' },
        { label: 'Annual Revenue', fieldName: 'AnnualRevenue', type: 'currency' },
    ];

    totalRecords = 0;
    hasNext = false;
    position = 0;
    pageSize = 10;

    connectedCallback() {
        this.loadAccounts();
    }

    loadAccounts() {
        // TODO: call Apex method to fetch accounts and update state
        getAccounts({ position: this.position, pageSize: this.pageSize })
            .then(result =>{
                this.accounts = result.records;
                this.totalRecords = result.totalRecords;
                this.hasNext = result.hasNext;
            })
            .catch(error =>{
                console.error('Error fetching accounts:', error);
            })
    }

    handleNext(){
        if(this.hasNext){
            this.position += this.pageSize;
            this.loadAccounts();
        }
    }

    handlePrevious(){
        if(this.position > 0){
            this.position -= this.pageSize;
            if(this.position < 0) {
                this.position = 0;
            }
            this.loadAccounts();
        }
    }

    get isPreviousDisabled(){
        return this.position === 0;
    }
    
    get isNextDisabled(){
        return !this.hasNext;
    }
}