public without sharing class vertic_SOQLProc extends vertic_AbstractProcessor {

    /**
     * ==============================================================================================================
     *                                              PROCESS
     * ==============================================================================================================
     */

    public override vertic_Response process(vertic_Request request) {
        this.request = request;

        this.retrieveRecords();

        return this.response;
    }


    /**
     * ==============================================================================================================
     *                                             PRIVATE METHODS
     * ==============================================================================================================
     */

    private void retrieveRecords() {
        try{
            String soqlStr = this.request.getString('SOQL');
            List<SObject> records = Database.query(soqlStr);
            this.response.getMapper().mapFromListSObjects('records', records);
        }catch (Exception ex){
            hey.Logger.debug(this.request.getString('SOQL'));
            throw ex;
        }
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