public virtual class vertic_MetadataCtrl extends vertic_CommonCtrl {

    public vertic_Response response {get; private set;}

    public virtual void onInit() {

        try {
            String componentName = ApexPages.currentPage().getUrl().substringAfterLast('/apex/').substringBefore('?');
            if (ApexPages.currentPage().getParameters().containsKey('proc')) {
                componentName = ApexPages.currentPage().getParameters().get('proc');
            } else if(ApexPages.currentPage().getParameters().containsKey('cmp')){
                componentName = ApexPages.currentPage().getParameters().get('cmp');
            }
            this.response = vertic_ProcessorFactory.getInstance(componentName + 'MetaProc').process(this.initRequest());
        } catch (Exception ex) {
            hey.Logger.exception(ex);
            throw ex;
        } finally {
            hey.Logger.publish();
        }
    }

    protected virtual vertic_Request initRequest(){
        return new vertic_MetadataProcessor.MetadataRequest();
    }
}