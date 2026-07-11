public with sharing class AccountCursor {
    
    private static Integer CHUNK_SIZE = 10; // Number of records to fetch in each chunk

    public static void getAccountCursor() {
        Integer position = 0;
        //create a cursor instance to fetch records in chunks. Use Database.getCursor() method to create a cursor for the Account object.
        // Maximum number of rows per cursor is 50 million, regardless of the operation being synchronuous or asynchronuous.
        
        Database.Cursor accountCursor = Database.getCursor(
            'SELECT Id, Name, Type, Industry, AnnualRevenue FROM Account'
        );

        Integer remainingRecords = accountCursor.getNumRecords() - position;
        System.debug('Total no of Accounts: ' +  accountCursor.getNumRecords());
        if(remainingRecords > 0){
            Integer scope = Math.min(CHUNK_SIZE, remainingRecords);

            //Calling the fetch method counts against the SOQL query limit, and the rows fetched count against the SOQL row limit. 
            // You can make the 100 Cursor.fetch() calls per transaction sameas soql limit.

            List<Account> accountChunk = accountCursor.fetch(position, scope);
            position += scope;

            // Process the chunk (e.g., log or perform actions)
            System.debug('Fetched Accounts: ' + accountChunk);
            System.debug('Fetched Accounts: ' + accountChunk.size());
        }
        /*
        Overview of the cursor limits and usage:
        -Maximun number of rows per cursor is 50 million, regardless of the operation being synchronuous or asynchronuous.
        -Limit of 100 fetch() calls per transaction, which counts against the SOQL query limit.
        -Cursor remains valid for 48 hours.
        -100 million aggreagetd rows can be fetched through cursors per day ( which includes pagination cursor)
        - 50 cursors can be created per transaction. This limit is same for apex as well pagination cursor.
        - 10000 cursors can be created per org per day.
        - 100000 rows can be fetched through pagination cursor in a transaction.
        - 200000 pagination cursor instances can be created per org per day.

        -To not run into cursor instance limits, it is better to create platform cache or custom setting or custom metadata to store cursor id 
        by serialze the cursor using JSON.seralize() method. And then reterive the curson using JSON.deserialize() method.

        - If there are records created after the cursor insance is created, those records will not be fetched by the cursor.
        - If the records  are deleted after the cursor is created, then -
            - deleted record will be skipped by the pagination cursor and next set of records will be fetched.
            - no dataset will be fetched if it is apex cusor.
        - Cursor can move forward and backward.


        */




        System.debug('No of cursor created : '+ Limits.getApexCursors());
        System.debug('Maximum number of cursor that can be created per day : '+ Limits.getLimitApexCursors());
        System.debug('Get number of rows returned by cursor : '+ Limits.getApexCursorRows());
        System.debug('Get maximum number of rows returned by cursor : '+ Limits.getLimitApexCursorRows());

        System.debug('No of pagination cursor created : '+ Limits.getApexPaginationCursors());
        System.debug('Maximum number of pagination cursor that can be created per day : '+ Limits.getLimitApexPaginationCursors());
        System.debug('Get number of rows returned by pagination cursor : '+ Limits.getApexPaginationCursorRows());
        System.debug('Get maximum number of rows returned by pagination cursor : '+ Limits.getLimitApexPaginationCursorRows());

        System.debug('Get number of  fetch calls : '+ Limits.getFetchCallsOnApexCursor());
        System.debug('Get maximum number of fetch calls : '+ Limits.getLimitFetchCallsOnApexCursor());

    }
}