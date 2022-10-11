public class vertic_DMLProc extends vertic_AbstractProcessor implements vertic_Structs.IRollbackable {

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

        String sObjectTypeStr = this.request.getString('sObjectType');
        vertic_Utils.objects.throwIfNull(sObjectTypeStr, 'No sObjectType param.');

        SObjectType sObjectTypeVar = vertic_Utils.sObjects.stringToSObjectType(sObjectTypeStr);

        vertic_UnitOfWork uow = new vertic_UnitOfWork(
            new List<SObjectType>{
                sObjectTypeVar
            },
            new vertic_UnitOfWork.DatabaseDMLIml()
        );

        List<SObject> recordsToUpsert = this.request.getMapper().mapToListSObjects('upsert', sObjectTypeVar, true, null);
        List<SObject> recordsToDelete = this.request.getMapper().mapToListSObjects('delete', sObjectTypeVar, true, null);

        if(recordsToUpsert != null){
            uow.registerUpsert(recordsToUpsert);
        }

        if(recordsToDelete != null){
            uow.registerDeleted(recordsToDelete);
        }

        uow.commitWork();

        this.response.getMapper().mapFromListSObjects('upsert', recordsToUpsert);
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