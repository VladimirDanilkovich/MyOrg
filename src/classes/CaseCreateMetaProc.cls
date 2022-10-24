 public class CaseCreateMetaProc extends vertic_MetadataProcessor {

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


    }
}