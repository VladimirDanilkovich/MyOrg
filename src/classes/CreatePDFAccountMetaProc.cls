public class CreatePDFAccountMetaProc extends vertic_MetadataProcessor {

    private Account account;
    private Contact contact;

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
        String recordId = this.request.getRequiredString('accountId');
        this.account = (Account) vertic_Utils.arrays.firstOrException([
            SELECT
                Id,
                Name,
                Phone
            FROM Account
            WHERE Id = :recordId
        ]);
        List <Contact> contacts = [SELECT
            Id,
            FirstName,
            LastName,
            Email
            FROM Contact WHERE AccountId = :this.account.Id ];
        vertic_DTO dto = new vertic_DTO();


        vertic_AutoMapper autoMapper = new vertic_AutoMapper(dto)
            .getOptions()
            .setIsVisualforce(true)
            .setIsAllFields(true)
            .setDefaultFieldValue(' ')
            .getMapper()
            .mapFromSObject('account', this.account)
            .mapFromListSObjects('contacts', contacts);


        List<Object> components = new List<Object>();
        components.add(new Component.GenerationPdfForAccount(
            dto = dto.getMap()
        ));
        System.debug('CCCC '+components);
        this.response.dto.put('components', components);

    }

}