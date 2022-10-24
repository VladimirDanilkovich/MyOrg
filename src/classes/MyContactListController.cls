public class MyContactListController extends vertic_MetadataProcessor {


    public override vertic_Response process(vertic_Request request) {
        this.request = request == null ? new vertic_MetadataProcessor.MetadataRequest() : (vertic_MetadataProcessor.MetadataRequest) request;

        this.request.fields = new Set<SObjectField>{
                Account.Name
        };

        super.process(this.request);

        return this.response;

    }
    @AuraEnabled
    public static List<Account> getAccounts(String accountName ){

        return [SELECT Id FROM Account Where Name = :accountName];


    }
        @AuraEnabled
    public static List<Contact> getContacts(Id recordId,String contactEmail ){



        if(String.isNotBlank(contactEmail)){
            contactEmail = '%' + contactEmail + '%';
            return [SELECT Id, FirstName, LastName, Email, Phone FROM Contact WHERE AccountId = :recordId AND Email LIKE :contactEmail];

           /* List<SObject> sObjects = Database.query('SELECT Id, FirstName, LastName, Email, Phone FROM Contact WHERE AccountId = :recordId AND Email LIKE :contactEmail');
            return sObjects;*/
        }
        return [SELECT Id, FirstName, LastName, Email, Phone From Contact Where AccountId = :recordId];

    }
}