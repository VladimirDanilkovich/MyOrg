public without sharing class vertic_VAPRetrySubmitProc extends vertic_AbstractProcessor {

    /**
     * ==============================================================================================================
     *                                              PROCESS
     * ==============================================================================================================
     */

    public override vertic_Response process(vertic_Request request) {
        this.request = request;

        this.doSubmit();

        return this.response;
    }


    /**
     * ==============================================================================================================
     *                                             PRIVATE METHODS
     * ==============================================================================================================
     */

    private void doSubmit() {

        String vapId = this.request.getRequiredString('id');

        Vertic_Async_Process__c vapVar = (Vertic_Async_Process__c)vertic_Utils.arrays.firstOrException(
            [SELECT Id, Status__c FROM Vertic_Async_Process__c WHERE Id = :vapId],
            'No Vertic_Async_Process__c with Id: ' + vapId
        );

        if('Completed'.equalsIgnoreCase(vapVar.Status__c)){
            throw new vertic_Structs.ValidationException('The process already successfully processed!');
        }

        vertic_AsyncProcess.process(new Set<String>{vapId}, new Map<String, Object>{
            'forceStatus' => true
        });

        vapVar = (Vertic_Async_Process__c)vertic_Utils.arrays.firstOrException(
        [SELECT Id, Details__c, Payload__c, Status__c FROM Vertic_Async_Process__c WHERE Id = :vapId],
            'No Vertic_Async_Process__c with Id: ' + vapId
        );

        this.response.getMapper().mapFromSObject('vap', vapVar);

    }


    /**
     * ==============================================================================================================
     *                                               STRUCTURES
     * ==============================================================================================================
     */

    // Proposed Live Templates to override Super properties: 
    // vertic_request
    // vertic_response


}