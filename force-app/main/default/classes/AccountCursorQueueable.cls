public with sharing class AccountCursorQueueable implements Queueable{
    private static Integer CHUNK_SIZE = 100;
    private Integer position = 0;
    private Integer MAX_RETRIES = 2;
    private Database.Cursor accountCursor = Database.getCursor('SELECT Id, Name From Account', AccessLevel.USER_MODE);
    public AccountCursorQueueable() { }
    public AccountCursorQueueable(Integer position, Database.Cursor cursor){ 
        accountCursor = cursor;
        this.position = position;
    }

    public void execute(QueueableContext context){
        try{
            Integer remainingRecords = accountCursor.getNumRecords() - position;
            if(remainingRecords <= 0){
                System.debug('No More records to process');
                return;
            }
            Integer scope = Math.min(CHUNK_SIZE, remainingRecords);
            List<Account> accountChunk = accountCursor.fetch(position, scope);
            position += scope;
            System.debug('Fetched Accounts: ' + accountChunk);
            System.debug('Fetched Accounts: ' + accountChunk.size());
            System.debug(' Position: ' + position + 'Remaining Accounts: ' + remainingRecords );

            if(position < accountCursor.getNumRecords()){
                System.enqueueJob(new AccountCursorQueueable(position, accountCursor));
            }
        }
        catch(TransientCursorException e){
            System.debug('TransientCursorException occured: '+ e.getMessage());
            if(MAX_RETRIES > 0){
                MAX_RETRIES--;
                System.enqueueJob(new AccountCursorQueueable(position, accountCursor));
            }
            else{
                System.debug('Max retries reached. Cannot process the cursor.');
            }
        }
        catch(Exception e){
            System.debug('Exception occured: '+ e.getMessage());
        }
        finally{
            System.debug('No of cursor created : '+ Limits.getApexCursors());
            System.debug('Maximum number of cursor that can be created per day : '+ Limits.getLimitApexCursors());
            System.debug('Get number of rows returned by cursor : '+ Limits.getApexCursorRows());
            System.debug('Get maximum number of rows returned by cursor : '+ Limits.getLimitApexCursorRows());

            System.debug('No of pagination cursor created : '+ Limits.getApexPaginationCursors());
        }
    }
}