public class CreateCasePostProc extends vertic_AbstractProcessor {

    private Contact contactVar;
    private vertic_UnitOfWork uow = new vertic_UnitOfWork(new List<SObjectType>{
        Contact.SObjectType,
        Case.SObjectType
    });

    public override vertic_Response process(vertic_Request request) {
        this.request = (vertic_RestService.Request) request;
        this.response = (vertic_RestService.Response) super.response;

        this.doSubmit();

        this.uow.commitWork();

        return this.response;

    }

    private void doSubmit() {
        String contactLastName = request.getRequiredString('LastName');
        String contactLastNameFilter = '%' + contactLastName + '%';
        String contactFirstName = request.getString('FirstName');
        String contactFirstNameFilter = '%' + contactFirstName + '%';
        String contactName = contactLastName + ' ' + contactFirstName;

        this.contactVar = (Contact) vertic_Utils.arrays.firstOrDefault([SELECT Id FROM Contact WHERE LastName LIKE :contactLastNameFilter AND FirstName LIKE :contactFirstNameFilter], new Contact());
        System.debug([SELECT Id FROM Contact WHERE LastName LIKE :contactLastNameFilter AND FirstName LIKE :contactFirstNameFilter]);
        System.debug(contactLastName);
        System.debug(contactFirstName);
        this.contactVar.FirstName =  contactFirstName;
        this.contactVar.LastName = contactLastName;

        if (this.contactVar.Id == null) {
            vertic_Utils.sObjects.deduplicate(this.contactVar);
        }
        this.uow.registerUpsert(this.contactVar);

        Case caseVar = new Case();
        caseVar.Status = request.getString('Status');
        caseVar.Origin = request.getString('Origin');

        this.uow.registerNew(caseVar, Case.ContactId, this.contactVar);

    }

    protected override vertic_Response getResponseInstance() {
        return new vertic_RestService.Response();
    }

    /** ============================================================================================================= */

    private vertic_RestService.Request request;

    public override Type getRequestType() {
        return vertic_RestService.Request.class;
    }

    public override vertic_Request getRequestInstance(String requestJSON) {
        return (vertic_RestService.Request) JSON.deserialize(requestJSON, this.getRequestType());
    }

}