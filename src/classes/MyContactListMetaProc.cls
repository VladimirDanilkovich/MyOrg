public class MyContactListMetaProc extends vertic_MetadataProcessor {

    public override vertic_Response process(vertic_Request request) {
        this.request = request == null ? new vertic_MetadataProcessor.MetadataRequest() : (vertic_MetadataProcessor.MetadataRequest) request;

        this.request.fields = new Set<SObjectField>{
            // SObject Fields, e.g. Contact.Salutation
        };

        super.process(this.request);

        this.init();

        return this.response;
    }

    private void init() {


        String accountId = this.request.getString('filter.accountIdFilter');
        String emailContact = this.request.getString('filter.emailFilter');


        fflib_QueryFactory queryFactory = new fflib_QueryFactory(Contact.SObjectType);
        queryFactory.selectFields(new Set<String>{
            'Id', 'Account.Name', 'FirstName', 'Email', 'MobilePhone', 'LastName'
        });


        List<String> conditions = new List<String>{
        };
        if (String.isNotBlank(accountId)) {
            conditions.add('AccountId = :accountId');
        }
        if (String.isNotBlank(emailContact)) {
            String emailContactFilter = '%' + emailContact + '%';
            conditions.add('Email LIKE :emailContactFilter');
        }
        System.debug(queryFactory.toSOQL());
        if (conditions != null && !conditions.isEmpty()) {
            queryFactory.setCondition(String.join(conditions, ' OR '));
        }
        System.debug(queryFactory.toSOQL());

        List<Contact> contacts = Database.query(queryFactory.toSOQL());

        this.response.put('contacts', contacts);

    }
}