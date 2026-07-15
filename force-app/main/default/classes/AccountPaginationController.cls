public with sharing class AccountPaginationController {
       // private static final String CACHE_KEY = 'cache.PaginationCache.accountCursor';
    public class PaginationWrapper{
            @AuraEnabled
            public List<Account> records;
            @AuraEnabled
            public Integer totalRecords;
            @AuraEnabled
            public Boolean hasNext;            
    }

    @AuraEnabled
    public static PaginationWrapper getAccounts(Integer position, Integer pageSize){

        PaginationWrapper wrapper = new PaginationWrapper();
        Database.Cursor accountCursor ;
        Cache.SessionPartition sessionPart = Cache.Session.getPartition('local.PaginationCache');

        if (sessionPart.contains('accountCursor')) { 
            accountCursor = (Database.Cursor) sessionPart.get('accountCursor'); 
        } else {
           
            accountCursor = Database.getCursor('SELECT Id, Name, Industry, AnnualRevenue FROM Account ORDER BY Name ASC'); 
            sessionPart.put('accountCursor', accountCursor);
        }

        Integer remainingRecords = accountCursor.getNumRecords() - position;
        System.debug('Total no of Accounts: ' +  accountCursor.getNumRecords());
        if(remainingRecords > 0){
            Integer scope = Math.min(pageSize, remainingRecords);
            List<Account> accountChunk = accountCursor.fetch(position, scope);
            position += scope;

            wrapper.records = accountChunk;
            wrapper.totalRecords = accountCursor.getNumRecords();
            wrapper.hasNext = (position < accountCursor.getNumRecords());
        } else {
            wrapper.records = new List<Account>();
            wrapper.totalRecords = accountCursor.getNumRecords();
            wrapper.hasNext = false;
        }

        return wrapper;
    }
}