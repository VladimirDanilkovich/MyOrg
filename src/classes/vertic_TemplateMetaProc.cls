public abstract class vertic_TemplateMetaProc extends vertic_MetadataProcessor {

    /**
     * ==============================================================================================================
     *                                              PROCESS
     * ==============================================================================================================
     */

    public virtual override vertic_Response process(vertic_Request request) {
        this.request = request == null ? new MetadataRequest() : (MetadataRequest) request;

        this.beforeProcess();

        super.process(this.request);

        this.p_initMetadata();

        this.response.put('font-family', 'blank');
        this.response.put('font-size', 'blank');

        this.afterProcess();

        return this.response;
    }


    /**
     * ==============================================================================================================
     *                                             PRIVATE METHODS
     * ==============================================================================================================
     */

    private void p_initMetadata() {
        List<Object> components = new List<Object>();

        for (String componentId : this.getIds()) {
            vertic_DTO dto = new vertic_DTO();

            this.initMetadata(componentId, dto);

            Component.Apex.OutputPanel panel = new Component.Apex.OutputPanel();

            String htmlTemplate = this.getTemplate(componentId, dto);
            if (String.isNotBlank(htmlTemplate)) {

                for (vertic_Structs.TemplateSection sectionVar : vertic_Utils.templates.getSections(htmlTemplate)) {
                    if (sectionVar.type == vertic_Structs.TemplateType.HTML) {
                        panel.childComponents.add(new Component.Apex.OutputText(
                            escape = false,
                            value = vertic_Utils.templates.compose(sectionVar.value, dto)
                        ));
                    } else if (sectionVar.type == vertic_Structs.TemplateType.COMPONENT) {
                        ApexPages.Component cmp = this.getComponentInstance(sectionVar.value, dto);
                        if (cmp != null) {
                            panel.childComponents.add(cmp);
                        }
                    }
                }

                dto.put('component', panel);
            }

            components.add(new Component.vertic_DynamicComponent(
                component = panel
            ));
        }

        this.response.put('components', components);
    }


    /**
     * ==============================================================================================================
     *                                             METHODS TO OVERRIDE
     * ==============================================================================================================
     */

    protected abstract void initMetadata(String componentId, vertic_DTO dto);

    protected virtual void beforeProcess() {}
    protected virtual void afterProcess() {}

    protected virtual List<String> getIds() {
        List<String> ids = new List<String>();
        if (this.request.has('ids')) {
            ids = this.request.getString('ids').split(',');
        }
        return ids;
    }

    protected virtual String getTemplate(String componentId, vertic_DTO dto) {
        return null;
    }

    protected virtual ApexPages.Component getComponentInstance(String name, vertic_DTO dto) {
        return null;
    }

    protected void setFileName(String fileName){
        if(ApexPages.currentPage() != null){
            ApexPages.currentPage()
                .getHeaders()
                .put('content-disposition', 'filename=' + fileName);
        }
    }

    protected Set<String> getFormulaFields(SObjectType sObjType, String prefix) {
        Set<String> additionalFields = new Set<String>();
        Map<String, SObjectField> fieldsMap = sObjType.getDescribe().fields.getMap();
        for (String fieldToken : fieldsMap.keySet()) {
            SObjectField sObjectFieldVar = fieldsMap.get(fieldToken);
            DescribeFieldResult fieldVarDescribe = sObjectFieldVar.getDescribe();
            if (fieldVarDescribe.isCalculated()) {
                additionalFields.add((String.isNotBlank(prefix) ? prefix : '') + fieldVarDescribe.getName());
            }
        }
        return additionalFields;
    }

    public vertic_TemplateMetaProc.Field getSObjectFieldByPath(SObjectType sObjectTypeVar, String path){
        Schema.SObjectField token;
        Schema.sObjectType lastSObjectType = sObjectTypeVar;

        if(!path.contains('.')){ //single field
            token = fflib_SObjectDescribe.getDescribe(sObjectTypeVar).getField(path.toLowerCase());
            if(token == null)
                throw new vertic_Structs.NotFoundException(path + ' ' + sObjectTypeVar);
        }

        //traversing FK relationship(s)
        List<String> fieldPath = new List<String>();
        Iterator<String> i = path.split('\\.').iterator();
        while(i.hasNext()){
            String field = i.next();
            token = fflib_SObjectDescribe.getDescribe(lastSObjectType).getField(field.toLowerCase());
            DescribeFieldResult tokenDescribe = token != null ? token.getDescribe() : null;

            if(token != null && i.hasNext() && tokenDescribe.getSOAPType() == Schema.SOAPType.ID){
                lastSObjectType = tokenDescribe.getReferenceTo()[0]; //if it's polymorphic doesn't matter which one we get
                fieldPath.add(tokenDescribe.getRelationshipName());
            }else if(token != null && !i.hasNext()){
                fieldPath.add(tokenDescribe.getName());
            }else{
                if(token == null)
                    throw new vertic_Structs.NotFoundException(field + ' ' + lastSObjectType);
                else
                    throw new vertic_Structs.NotFoundException(lastSObjectType+'.'+field+' is not a lookup or master-detail field but is used in a cross-object query field.');
            }
        }

        vertic_TemplateMetaProc.Field fieldVar = new vertic_TemplateMetaProc.Field();
        fieldVar.sObjectTypeVar = lastSObjectType;
        fieldVar.sObjectFieldVar = token;
        fieldVar.describeSObjectResult = lastSObjectType.getDescribe();
        fieldVar.describeFieldResultVar = token.getDescribe();

        return fieldVar;
    }

    public class Field{
        public SObjectType sObjectTypeVar;
        public DescribeSObjectResult describeSObjectResult;

        public SObjectField sObjectFieldVar;
        public DescribeFieldResult describeFieldResultVar;
    }

    public class MergeFieldsSet{
        public String name;
        public String label;

        public List<MergeFieldsItem> items = new List<MergeFieldsItem>();
    }

    public class MergeFieldsItem{
        public String expression;
        public String label;
        public String helpText;
        public Boolean isHtml = false;

        public MergeFieldsItem(){}

        public MergeFieldsItem(String expression, String label){
            this.expression = '{!' + expression + '}';
            this.label = label;
        }
    }

    public virtual List<MergeFieldsSet> getMergeFieldSets(){
        return new List<MergeFieldsSet>();
    }

    protected virtual MergeFieldsSet getMergeFieldSet(List<String> fields, SObjectType sourceSObjectType, SObjectType targetSObjectType, String mergePrefix, String fieldPrefix){
        MergeFieldsSet fieldsSetVar = new MergeFieldsSet();
        fieldsSetVar.name = targetSObjectType.getDescribe().getName();
        fieldsSetVar.label = targetSObjectType.getDescribe().getLabel();

        for (String fieldPath : fields) {

            if(String.isBlank(fieldPrefix) && fieldPath.contains('.')){
                continue;
            }

            if(String.isNotBlank(fieldPrefix) && !fieldPath.startsWithIgnoreCase(fieldPrefix)){
                continue;
            }

            vertic_TemplateMetaProc.Field fieldVar = this.getSObjectFieldByPath(sourceSObjectType, fieldPath);

            MergeFieldsItem item = new MergeFieldsItem();
            item.expression = '{!' + mergePrefix + (String.isNotBlank(fieldPrefix) ? fieldPath.removeStartIgnoreCase(fieldPrefix) : fieldPath) + '}';
            item.label = fieldVar.describeFieldResultVar.getLabel();
            item.helpText = fieldVar.describeFieldResultVar.getInlineHelpText();

            fieldsSetVar.items.add(item);
        }

        return fieldsSetVar;
    }

    public virtual SObjectType getSObjectType(){
        return null;
    }

    /**
     * ==============================================================================================================
     *                                         STRUCTURES AND OVERRIDES
     * ==============================================================================================================
     */

    // Proposed Live Templates to override Super properties:
    // vertic_meta_request
    // vertic_meta_response

}