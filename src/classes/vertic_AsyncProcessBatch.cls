public class vertic_AsyncProcessBatch implements Database.Batchable<sObject>, Database.AllowsCallouts, Database.Stateful, Schedulable, vertic_Structs.ISchedulable{
    /**
    * ==============================================================================================================
    *                                             VARIABLES
    * ==============================================================================================================
    */
    private final static String RE_RUNNER_JOB_NAME = 'Vertic Async Processes ReRunner';
    private final static String ASYNC_JOB_NAME = 'Vertic Async Processes';
    private static String CRON_EXP = '0 55 23 * * ? *'; // Every Day at 11 : 55pm
    private Boolean isManualRun = false;
    private List<Id> processIds;
    private static final Set<String> processStatuses = new Set<String>{
        'Pending',
        'Retrying'
    };

    /**
    * ==============================================================================================================
    *                                             CONSTRUCTORS
    * ==============================================================================================================
    */

    public vertic_AsyncProcessBatch() {
    }

    private vertic_AsyncProcessBatch(List<Id> processIds){
        this.isManualRun = true;
        this.processIds = processIds;
    }
    /**
    * ==============================================================================================================
    *                                             STATIC METHODS
    * ==============================================================================================================
    */

    public static Id run(){
        return run(1);
    }

    public static Id run(Integer delayInMinutes){
        return System.scheduleBatch(
            new vertic_AsyncProcessBatch(),
            Test.isRunningTest() ? 'Vertic Async Processes' + Datetime.now().getTime() : 'Vertic Async Processes',
            delayInMinutes,
            1
        );
    }

    public static Id run(List<Id> processIds){
        return Database.executeBatch(new vertic_AsyncProcessBatch(processIds), 1);
    }

    /**
    * ==============================================================================================================
    *                                              METHODS
    * ==============================================================================================================
    */

    public static void reRun() {
        vertic_AsyncProcessBatch.stop();
        vertic_AsyncProcessBatch.start();
    }

    /**
   * ==============================================================================================================
   *                                             Database.Batchable<sObject>
   * ==============================================================================================================
   */

    public Database.QueryLocator start(Database.BatchableContext param1) {
        fflib_QueryFactory queryFactory = new fflib_QueryFactory(Vertic_Async_Process__c.SObjectType);

        List<String> conditions = new List<String>();

        final Datetime now = Datetime.now();

        if(this.isManualRun == true){
            conditions.add('Id IN :processIds');
        } else {
            conditions.addAll(new List<String>{
                'Status__c IN :processStatuses',
                'Autorun__c = true',
                '(Run_After__c = NULL OR Run_After__c < :now)'
            });
            queryFactory.addOrdering(Vertic_Async_Process__c.Priority__c, fflib_QueryFactory.SortOrder.ASCENDING, true);
            queryFactory.addOrdering(Vertic_Async_Process__c.Attempts__c, fflib_QueryFactory.SortOrder.ASCENDING, false);

            queryFactory.setLimit(50000);
        }

        queryFactory.setCondition(String.join(conditions, ' AND '));
        queryFactory.addOrdering(Vertic_Async_Process__c.CreatedDate, fflib_QueryFactory.SortOrder.ASCENDING);

        return Database.getQueryLocator(queryFactory.toSOQL());
    }

    // Should not be bulkified. Scope = 1.
    public void execute(Database.BatchableContext batchableContext, List<sObject> scopeRecords) {
        vertic_AsyncProcess.process(new Map<String, SObject>(scopeRecords).keySet());
    }

    public void finish(Database.BatchableContext param1) {

        Database.delete([SELECT Id FROM Vertic_Async_Process__c WHERE Remove__c = true ORDER BY LastModifiedDate ASC LIMIT 1000], false);

        if (this.isManualRun != true && !Test.isRunningTest()) {
            Boolean isAnyPendingJob = [
                SELECT COUNT()
                FROM Vertic_Async_Process__c
                WHERE Status__c IN :processStatuses AND (Run_After__c = null OR Run_After__c < :Datetime.now()) AND Autorun__c  = true
                LIMIT 1
            ] > 0;
            if(isAnyPendingJob){
                vertic_AsyncProcessBatch.run(0); // No delay.
            } else{
                vertic_AsyncProcessBatch.run(1); // 1 minute delay.
            }

        }
    }
    /**
         * ==============================================================================================================
         *                                            vertic_Structs.ISchedulable
         * ==============================================================================================================
         */

    public static void start() {
        System.schedule(RE_RUNNER_JOB_NAME, CRON_EXP, new vertic_AsyncProcessBatch());
        vertic_AsyncProcessBatch.run();

    }
    public void execute(SchedulableContext param1) {

        Boolean isProcessing = [
            SELECT COUNT()
            FROM AsyncApexJob
            WHERE ApexClass.Name = :('' + vertic_AsyncProcessBatch.class) AND Status = 'Processing' AND JobType = 'BatchApex'
            LIMIT 1
        ] > 0;
        if(isProcessing == true){
            return; // Do not re-run if vertic_AsyncProcessBatch is running now.
        }

        vertic_AsyncProcessBatch.reRun();
    }

    public static void stop() {
        abort(RE_RUNNER_JOB_NAME);
        abort(ASYNC_JOB_NAME);
    }

    /**
     * ==============================================================================================================
     *                                            PRIVATE METHODS
     * ==============================================================================================================
     */

    private static void abort(String jobName) {
        for (CronTrigger delCron : [
            SELECT Id
            FROM CronTrigger
            WHERE
                CronJobDetail.Name = :jobName
        ]) {
            System.abortJob(delCron.Id);
        }
    }


}