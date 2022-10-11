public abstract class vertic_MetadataProcessor extends vertic_AbstractProcessor {

    protected vertic_MetadataProcessor.MetadataRequest request;
    protected vertic_MetadataProcessor.MetadataResponse response;

    /**
     * ==============================================================================================================
     *                                              PROCESS
     * ==============================================================================================================
     */

    public virtual override vertic_Response process(vertic_Request request) {
        this.request = (vertic_MetadataProcessor.MetadataRequest) request;
        this.response = (vertic_MetadataProcessor.MetadataResponse) super.response;

        this.p_initSelectOptions();

        return this.response;
    }

    public virtual override vertic_Response process(Map<String, Object> requestMap){
        return this.process(new vertic_MetadataProcessor.MetadataRequest(requestMap));
    }

    /**
     * ==============================================================================================================
     *                                             PRIVATE METHODS
     * ==============================================================================================================
     */

    private void p_initSelectOptions() {
        if (this.request.fields != null && !this.request.fields.isEmpty()) {
            this.response.selectOptions = vertic_Utils.picklists.getPicklistOptionsMap(this.request.fields);
        }

        if (this.request.dependentFieldsBySObjectType != null && !this.request.dependentFieldsBySObjectType.isEmpty()) {
            this.response.dependentOptions = vertic_Utils.picklists.getDependentPicklistOptionsMap(this.request.dependentFieldsBySObjectType);
        }

        if (this.request.sObjectTypes != null && !this.request.sObjectTypes.isEmpty()) {
            this.response.sObjects = vertic_Utils.sObjects.getSObjectDescribe(this.request.sObjectTypes);
        }
    }


    /**
     * ==============================================================================================================
     *                                          STRUCTURES AND OVERRIDES
     * ==============================================================================================================
     */

    public virtual class MetadataRequest extends vertic_Request {
        public Set<SObjectField> fields = new Set<SObjectField>();
        public Map<SObjectType, Map<SObjectField, SObjectField>> dependentFieldsBySObjectType = new Map<SObjectType, Map<SObjectField, SObjectField>>();
        public List<SObjectType> sObjectTypes = new List<SObjectType>();

        public MetadataRequest() {}

        public MetadataRequest(String requestJSON) {
            super(requestJSON);
        }

        public MetadataRequest(Map<String, Object> requestMap) {
            super(requestMap);
        }

        public MetadataRequest(Set<SObjectField> fields) {
            this.fields = fields;
        }

        public MetadataRequest(Set<SObjectField> fields, Map<SObjectType, Map<SObjectField, SObjectField>> dependentFieldsBySObjectType) {
            this(fields);
            this.dependentFieldsBySObjectType = dependentFieldsBySObjectType;
        }
    }

    public virtual class MetadataResponse extends vertic_Response {
        public Map<String, List<vertic_Structs.SelectOption>> selectOptions = new Map<String, List<vertic_Structs.SelectOption>>();
        public Map<String, Map<String, List<vertic_Structs.SelectOption>>> dependentOptions = new Map<String, Map<String, List<vertic_Structs.SelectOption>>>();
        public Map<String, Object> sObjects = new Map<String, Object>();

        public void addSelectOption(String key, vertic_Structs.SelectOption selectOption, Integer index) {
            vertic_Utils.arrays.addToListOrCreateNew(
                this.selectOptions,
                List<vertic_Structs.SelectOption>.class,
                key,
                selectOption,
                index
            );
        }

        public void addSelectOption(String key, vertic_Structs.SelectOption selectOption) {
            this.addSelectOption(key, selectOption, null);
        }

        public void addSelectOptions(String key, List<vertic_Structs.SelectOption> selectOptions, Integer index) {
            for (vertic_Structs.SelectOption selectOption : selectOptions) {
                this.addSelectOption(key, selectOption, index);
            }
        }

        public void addSelectOptions(String key, List<vertic_Structs.SelectOption> selectOptions) {
            this.addSelectOptions(key, selectOptions, null);
        }

        public Boolean removeDependentOption(String picklistOptionsName, String parentOptionValue, String dependentOptionValueToRemove){
            Map<String, List<vertic_Structs.SelectOption>> optionsMap = this.dependentOptions.get(picklistOptionsName);
            if(optionsMap != null){
                List<vertic_Structs.SelectOption> dependentOptions = optionsMap.get(parentOptionValue);
                if(dependentOptions != null){
                    for (Integer index = 0; index < dependentOptions.size(); index++) {
                        vertic_Structs.SelectOption selectOptionVar = dependentOptions.get(index);
                        if(selectOptionVar.value == dependentOptionValueToRemove){
                            dependentOptions.remove(index);
                            return true;
                        }
                    }
                }
            }
            return false;
        }
    }

    public virtual override Type getRequestType() {
        return MetadataRequest.class;
    }

    public override vertic_Request getRequestInstance(String requestJSON) {
        return new MetadataRequest(requestJSON);
    }


    protected virtual override vertic_Response getResponseInstance() {
        return new MetadataResponse();
    }

}