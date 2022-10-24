public class CaseCreateSubmitProc extends vertic_AbstractProcessor implements vertic_Structs.IRollbackable {

    private List<Case> caseList = new List<Case>();
    public override vertic_Response process(vertic_Request request) {
        this.request = request;

        this.init();

        return this.response;
    }

    private void init() {
        System.debug('kkk');
        this.caseList = this.request.getMapper().mapToListSObjects('caseList', Case.SObjectType);
        System.debug(caseList);
        upsert caseList;
    }

}