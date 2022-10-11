public class vertic_AsyncProcess {

    private List<Vertic_Async_Process__c> asyncProcesses = new List<Vertic_Async_Process__c>();

    public List<Vertic_Async_Process__c> enqueue(){
        insert this.asyncProcesses;
        return  asyncProcesses;
    }

    public Id enqueueAndRun(){
        for (Vertic_Async_Process__c verticAsyncProcess : asyncProcesses) {
            verticAsyncProcess.Autorun__c = false;
        }
        return run(this.enqueue());
    }

    public vertic_AsyncProcess add(Vertic_Async_Process__c asyncProcessVar){
        this.asyncProcesses.add(asyncProcessVar);
        return this;
    }

    public vertic_AsyncProcess add(String processor, Map<String, Object> payload){
        return this.add(create(processor, payload, null));
    }

    public vertic_AsyncProcess add(String processor, Map<String, Object> payload, Datetime runAfter){
        return this.add(create(processor, payload, runAfter));
    }

    public vertic_AsyncProcess add(Type processorType, Map<String, Object> payload){
        return add(create(processorType, payload, (Datetime)null));
    }

    public vertic_AsyncProcess add(Type processorType, Map<String, Object> payload, Time atTime){
        return add(create(processorType, payload, atTime));
    }

    public vertic_AsyncProcess add(Type processorType, Map<String, Object> payload, Integer daysAfter, Time atTime){
        return add(create(processorType, payload, daysAfter, atTime));
    }


    public static Id run(List<Vertic_Async_Process__c> asyncProcesses){
        List<Id> ids = new List<Id>();
        for (Vertic_Async_Process__c verticAsyncProcess : asyncProcesses) {
            vertic_Utils.objects.throwIfNull(verticAsyncProcess.Id, 'Async Process should be created before the run');
            ids.add(verticAsyncProcess.Id);
        }
        return vertic_AsyncProcessBatch.run(ids);
    }


    public static Vertic_Async_Process__c create(String processor, Map<String, Object> payload, Datetime runAfter){
        return new Vertic_Async_Process__c(
            Processor__c = processor,
            Payload__c = JSON.serialize(payload),
            Run_After__c = runAfter
        );
    }

    public static Vertic_Async_Process__c create(Type processorType, Map<String, Object> payload, Datetime runAfter){
        return create('' + processorType, payload, runAfter);
    }

    public static Vertic_Async_Process__c create(Type processorType, Map<String, Object> payload){
        return create(processorType, payload, (Datetime)null);
    }

    public static Vertic_Async_Process__c create(Type processorType, Map<String, Object> payload, Integer daysAfter, Time atTime){
        Datetime runAfter = Datetime.newInstance(Date.today().addDays(daysAfter), atTime);
        if(daysAfter == 0 && runAfter < Datetime.now()){
            runAfter = runAfter.addDays(1);
        }

        return create(processorType, payload, runAfter);
    }

    public static Vertic_Async_Process__c create(Type processorType, Map<String, Object> payload, Time atTime){
        return create(processorType, payload, 0, atTime);
    }

    public static void process(Set<String> verticAsyncProcessIds){
        process(verticAsyncProcessIds, null);
    }

    public static void process(Set<String> verticAsyncProcessIds, Map<String, Object> options){

        try {

            List<Vertic_Async_Process__c> asyncProcesses = [
                SELECT Id, Status__c, Processor__c, Payload__c, Details__c, Is_Queueable__c, Attempts__c, Allowed_Attempts__c
                FROM Vertic_Async_Process__c
                WHERE Id IN :verticAsyncProcessIds
                FOR UPDATE
            ];

            List<Vertic_Async_Process__c> asyncProcessesToUpdate = new List<Vertic_Async_Process__c>();

            vertic_DTO optionsDTO = new vertic_DTO(options == null ? new Map<String, Object>() : options);

            for (Vertic_Async_Process__c asyncProcessVar : asyncProcesses) {

                Boolean isProcessed = new Set<String>{'Pending', 'Retrying', 'Queued'}.contains(asyncProcessVar.Status__c) == false;
                Boolean forceStatus = optionsDTO.getBoolean('forceStatus');

                if (isProcessed && forceStatus != true) {
                    continue;
                }

                if(asyncProcessVar.Is_Queueable__c && !System.isQueueable() && !Test.isRunningTest()){
                    System.enqueueJob(new QueueableProc(asyncProcessVar.Id));
                    asyncProcessVar.Status__c = 'Queued';
                    asyncProcessesToUpdate.add(asyncProcessVar);
                    continue;
                }

                Boolean isValidationException = false;
                Savepoint savepointVar;
                try {

                    vertic_AbstractProcessor processorVar = vertic_ProcessorFactory.getInstance(asyncProcessVar.Processor__c);
                    if(processorVar instanceof vertic_Structs.IRollbackable){
                        savepointVar = Database.setSavepoint();
                    }

                    vertic_Request requestVar = processorVar.getRequestInstance(asyncProcessVar.Payload__c);
                    vertic_Response responseVar = processorVar.process(requestVar);

                    asyncProcessVar.Details__c = JSON.serialize(responseVar.getMap());

                    if (responseVar.isValid == true){
                        asyncProcessVar.Status__c = 'Completed';
                    } else {
                        asyncProcessVar.Status__c = 'Failed';

                        if (!requestVar.has('logger') || requestVar.getBoolean('logger') == true) {
                            hey.Logger.error('Async Process Failed');
                            hey.Logger.debug(asyncProcessVar);
                            hey.Logger.debug(responseVar);
                        }
                    }

                    if (processorVar instanceof vertic_Structs.IAsyncPostProcessing) {
                        asyncProcessVar = ((vertic_Structs.IAsyncPostProcessing) processorVar).postProcess(asyncProcessVar);
                    }

                } catch (Exception ex) {

                    if(savepointVar != null){
                        Database.rollback(savepointVar);
                    }

                    asyncProcessVar.Status__c = 'Failed';
                    asyncProcessVar.Details__c = ex.getMessage() + ' ' + ex.getStackTraceString();

                    isValidationException = ex instanceof vertic_Structs.ValidationException;

                    hey.Logger.exception(ex);
                    hey.Logger.debug(asyncProcessVar);
                } finally {

                    asyncProcessVar.Attempts__c = vertic_Utils.objects.defaultIfNull(asyncProcessVar.Attempts__c, 0) + 1;

                    Boolean isFailed = 'Failed'.equalsIgnoreCase(asyncProcessVar.Status__c);
                    Boolean canBeRetried = isFailed &&
                        isValidationException != true &&
                        asyncProcessVar.Allowed_Attempts__c != null &&
                        asyncProcessVar.Allowed_Attempts__c > asyncProcessVar.Attempts__c;

                    if(canBeRetried){
                        asyncProcessVar.Status__c = 'Retrying';

                        vertic_Request requestVar = new vertic_Request(asyncProcessVar.Payload__c);

                        if (!requestVar.has('logger') || requestVar.getBoolean('logger') == true) {
                            hey.Logger.debug('Retrying. Attempt: ' + asyncProcessVar.Attempts__c + '. Allowed Attempts: ' + asyncProcessVar.Allowed_Attempts__c);
                        }

                        Boolean isManyAttempts = asyncProcessVar.Attempts__c > 2 && asyncProcessVar.Allowed_Attempts__c > asyncProcessVar.Attempts__c;

                        Boolean isConcurrentRecordUpdateError = asyncProcessVar.Details__c != null &&
                            (asyncProcessVar.Details__c.contains('UNABLE_TO_LOCK_ROW') || asyncProcessVar.Details__c.contains('Record Currently Unavailable'));

                        Boolean isDisableQueueable = isManyAttempts &&
                            isConcurrentRecordUpdateError &&
                            asyncProcessVar.Is_Queueable__c;

                        Boolean isSetRunAfter = isManyAttempts &&
                            isConcurrentRecordUpdateError &&
                            asyncProcessVar.Run_After__c == null;


                        if(isDisableQueueable){
                            asyncProcessVar.Is_Queueable__c = false;
                        } else if(isSetRunAfter){
                            asyncProcessVar.Run_After__c = Datetime.now().addMinutes((Math.random() * 15).intValue());
                        }
                    }

                    asyncProcessesToUpdate.add(asyncProcessVar);
                }

            }

            Database.DMLOptions dmlOptions = new Database.DMLOptions();
            dmlOptions.allowFieldTruncation = true;
            Database.update(asyncProcessesToUpdate, dmlOptions);

        } catch (Exception ex) {
            hey.Logger.exception(ex);
            hey.Logger.debug(verticAsyncProcessIds);
        } finally {
            hey.Logger.publish();
        }

    }

    public class QueueableProc implements Queueable, Database.AllowsCallouts{

        private String verticAsyncProId;

        public QueueableProc(String verticAsyncProId){
            this.verticAsyncProId = verticAsyncProId;
        }

        public void execute(QueueableContext param1) {
            vertic_AsyncProcess.process(new Set<String>{this.verticAsyncProId});
        }
    }
}