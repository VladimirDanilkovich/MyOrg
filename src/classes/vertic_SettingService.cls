public class vertic_SettingService {

//    @TestVisible
//    private static vertic_Setting__mdt appSetting;
//
//    public static vertic_Setting__mdt getAppSetting() {
//
//        if(appSetting == null){
//            appSetting = (vertic_Setting__mdt) getMetadataType(
//                vertic_Setting__mdt.SObjectType,
//                vertic_Utils.orgs.isSandbox() ? 'Sandbox' : 'Production'
//            );
//        }
//
//        return appSetting;
//    }

    public static String getValue(String name, String defaultValue) {
        Setting__c o = Setting__c.getValues(name);
        return o == null ? defaultValue : o.Value__c;
    }

    public static String getValue(String name) {
        return getValue(name, null);
    }

    public static Decimal getNumberValue(String name, Decimal defaultValue) {
        Setting__c o = Setting__c.getValues(name);
        return o == null ? defaultValue : o.Number__c;
    }

    public static Decimal getNumberValue(String name) {
        return getNumberValue(name, null);
    }

    public static SObject getMetadataType(SObjectType sObjType, String name) {
        fflib_QueryFactory queryFactory = new fflib_QueryFactory(sObjType);
        for (SObjectField field : sObjType.getDescribe().fields.getMap().values()) {
            if (field.getDescribe().getType() == DisplayType.REFERENCE) {
                for (String parentField : field.getDescribe().getReferenceTo()[0].getDescribe().fields.getMap().keySet()) {
                    queryFactory.selectField(field.getDescribe().getRelationshipName() + '.' + parentField);
                }
            } else {
                queryFactory.selectField(field + '');
            }
        }
        queryFactory.setCondition('DeveloperName = :name');
        return (SObject) vertic_Utils.arrays.firstOrException(
            Database.query(queryFactory.toSOQL()),
            'Custom Metadata Type with name \'' + name + '\' not found.'
        );
    }

    public static void setValues(Map<String, String> settingsMap) {
        List<Setting__c> settings = new List<Setting__c>();

        for(String key : settingsMap.keySet()){
            Setting__c setting = Setting__c.getValues(key);
            settings.add(new Setting__c(
                Id = setting == null ? null : setting.Id,
                Name = key,
                Value__c = settingsMap.get(key)
            ));
        }

        upsert settings;
    }

    public static void setValuesAsync(Map<String, String> settingsMap) {
        System.enqueueJob(new SetValuesAsyncProcessor(settingsMap));
    }

    public static Id setMetadataTypeAsync(SObjectType customMetadataType, String name, String label, Map<String, Object> fieldValuesMap) {
        return System.enqueueJob(new SetMetadataTypesAsyncProcessor(customMetadataType, name, label, fieldValuesMap));
    }

    public static Id setMetadataTypeAsync(SObjectType customMetadataType, List<String> names, Map<String, String> labelsByName, Map<String, Object> fieldValuesByName) {
        return System.enqueueJob(new SetMetadataTypesAsyncProcessor(customMetadataType, names, labelsByName, fieldValuesByName));
    }

    public static Id setMetadataType(SObjectType customMetadataType, String name, String label, Map<String, Object> fieldValues) {
        return setMetadataType(
            customMetadataType,
            new List<String>{name},
            new Map<String, String>{
                name => label
            },
            new Map<String, Object>{
                name => fieldValues
            }
        );
    }

    public static Id setMetadataType(SObjectType customMetadataType, List<String> names, Map<String, String> labelsByName, Map<String, Object> fieldValuesByName) {
        Metadata.DeployContainer mdContainer = new Metadata.DeployContainer();
        setDeployContainer(mdContainer, customMetadataType, names, labelsByName, fieldValuesByName);
        return doDeployment(mdContainer);
    }

    private static void setDeployContainer(Metadata.DeployContainer mdContainer,SObjectType customMetadataType, List<String> names, Map<String, String> labelsByName, Map<String, Object> fieldValuesByName) {

        for (String name : names) {
            // Set up custom metadata to be created in the subscriber org.
            Metadata.CustomMetadata customMetadata = new Metadata.CustomMetadata();
            customMetadata.fullName = String.format(
                '{0}.{1}',
                new List<String>{
                    ('' + customMetadataType).removeEndIgnoreCase('__mdt'),
                    name
                }
            );
            if (labelsByName != null) {
                customMetadata.label = labelsByName.get(name);

                if (fieldValuesByName != null) {
                    for (String field : ((Map<String, Object>) fieldValuesByName.get(name)).keySet()) {
                        Object val = ((Map<String, Object>) fieldValuesByName.get(name)).get(field);

                        Metadata.CustomMetadataValue customField = new Metadata.CustomMetadataValue();
                        customField.field = field;
                        customField.value = val;

                        customMetadata.values.add(customField);
                    }
                }

                mdContainer.addMetadata(customMetadata);
            }
        }
    }

    private static Id doDeployment(Metadata.DeployContainer mdContainer) {
        // Setup deploy callback, MyDeployCallback implements
        // the Metadata.DeployCallback interface (code for
        // this class not shown in this example)
        CustomMetadataCallback callback = new CustomMetadataCallback();
        // Enqueue custom metadata deployment
        // jobId is the deployment ID
        Id jobId = Metadata.Operations.enqueueDeployment(mdContainer, callback);

        return jobId;
    }

    /**
     * ==============================================================================================================
     *                                          STRUCTURES AND OVERRIDES
     * ==============================================================================================================
     */

    public class CustomMetadataCallback implements Metadata.DeployCallback {
        public void handleResult(Metadata.DeployResult result, Metadata.DeployCallbackContext context) {

            try {

                if (result.status != Metadata.DeployStatus.Succeeded) {
                    // Deployment was not successful
                    hey.Logger.error('fail: ' + result);
                    System.debug('fail: ' + result);
                }

            } catch (Exception ex) {
                hey.Logger.exception(ex);
                throw ex;
            } finally {
                hey.Logger.publish();
            }

        }
    }

    private class SetValuesAsyncProcessor implements Queueable {

        private Map<String, String> settingsMap;

        public SetValuesAsyncProcessor(Map<String, String> settingsMap){
            this.settingsMap = settingsMap;
        }

        public void execute(QueueableContext context){
            vertic_SettingService.setValues(this.settingsMap);
        }
    }

    private class SetMetadataTypesAsyncProcessor implements Queueable {

        private SObjectType sObjType;
        private List<String> names;
        private Map<String, String> labelsByName;
        private Map<String, Object> fieldValuesByName;

        public SetMetadataTypesAsyncProcessor(SObjectType sObjType, String name, String label, Map<String, Object> fieldValuesByName){
            this.sObjType = sObjType;
            this.names = new List<String> {name};
            this.labelsByName = new Map<String, String> {
                name => label
            };
            this.fieldValuesByName = new Map<String, Object> {
                name => fieldValuesByName
            };
        }

        public SetMetadataTypesAsyncProcessor(SObjectType sObjType, List<String> names, Map<String, String> labelsByName, Map<String, Object> fieldValuesByName){
            this.sObjType = sObjType;
            this.names = names;
            this.labelsByName = labelsByName;
            this.fieldValuesByName = fieldValuesByName;
        }

        public void execute(QueueableContext context){
            vertic_SettingService.setMetadataType(this.sObjType, names, labelsByName, fieldValuesByName);
        }
    }

}