public class vertic_UnitOfWork extends fflib_SObjectUnitOfWork {

    private Map<String, SObject> alreadyRegisteredRecords = new Map<String, SObject>();

    private DoHierarchyWork doHierarchyWork;
    private DoAsyncProcessWork asyncProcessDoWork;

    public vertic_UnitOfWork(List<SObjectType> types) {
        this(types, new DatabaseDMLIml());
    }

    public vertic_UnitOfWork(List<SObjectType> types, fflib_SObjectUnitOfWork.IDML dmlImpl) {
        super(types, dmlImpl);

        this.doHierarchyWork = new DoHierarchyWork(this);
        this.asyncProcessDoWork = new DoAsyncProcessWork(this);
    }

    public SObject getRegisteredRecord(SObject record) {
        String recordInJSON = JSON.serialize(record);
        String recordHashCode = System.hashCode(record).format();

        if (this.alreadyRegisteredRecords.containsKey(recordInJSON)) {
            return this.alreadyRegisteredRecords.get(recordInJSON);
        } else if (this.alreadyRegisteredRecords.containsKey(recordHashCode)) {
            return this.alreadyRegisteredRecords.get(recordHashCode);
        }

        return record;
    }

    public Boolean registerUpsert(SObject record) {
        return this.registerUpsert(record, false, null);
    }

    public Boolean registerUpsert(SObject record, Set<SObjectField> preserveFields) {
        return this.registerUpsert(record, false, preserveFields);
    }

    public Boolean registerUpsert(SObject record, Boolean uniqueness) {
        return registerUpsert(record, uniqueness, null);
    }

    public Boolean registerUpsert(SObject record, Boolean uniqueness, Set<SObjectField> preserveFields) {

        if(preserveFields != null){
            if(this.m_dml instanceof DeduplicableDMLIml){
                ((DeduplicableDMLIml)this.m_dml).preserveFields(record, preserveFields);
            } else {
                throw new UnitOfWorkException('Using of the preserveFields argument requires DeduplicableDMLIml');
            }
        }

        if (record.Id == null) {
            if (uniqueness == true) {
                String recordInJSON = JSON.serialize(record);
                String recordHashCode = System.hashCode(record).format();
                if (!this.alreadyRegisteredRecords.containsKey(recordInJSON) && !this.alreadyRegisteredRecords.containsKey(recordHashCode)) {
                    super.registerNew(record);
                    this.alreadyRegisteredRecords.put(recordInJSON, record);
                    this.alreadyRegisteredRecords.put(recordHashCode, record);
                    return true;
                }
            } else {
                super.registerNew(record);
                return true;
            }
        } else {
            if (!this.alreadyRegisteredRecords.containsKey(record.Id)) {
                super.registerDirty(record);
                this.alreadyRegisteredRecords.put(record.Id, record);
                return true;
            }
        }
        return false;
    }

    public void registerUpsert(List<SObject> records, Set<SObjectField> preserveFields) {
        this.registerUpsert(records, false, preserveFields);
    }

    public void registerUpsert(List<SObject> records) {
        this.registerUpsert(records, false, null);
    }

    public void registerUpsert(List<SObject> records, Boolean uniqueness) {
        for (SObject record : records) {
            this.registerUpsert(record, uniqueness, null);
        }
    }

    public void registerUpsert(List<SObject> records, Boolean uniqueness, Set<SObjectField> preserveFields) {
        for (SObject record : records) {
            this.registerUpsert(record, uniqueness, preserveFields);
        }
    }

    public void registerRelationship(List<SObject> records, Schema.sObjectField relatedToField, SObject relatedTo) {
        for (SObject record : records) {
            super.registerRelationship(record, relatedToField, relatedTo);
        }
    }

    public void registerHierarchy(SObject child, SObjectField field, SObject parent) {
        if (child.getSObjectType() == parent.getSObjectType()) {
            doHierarchyWork.registerRelationship(child, field, parent);
        } else {
            throw new vertic_Structs.InvalidDataException('Couldn\'t create hierarchy relationship for different SObject Types.');
        }
    }

    public DoAsyncProcessWork asyncProcessWork() {
        return this.asyncProcessDoWork;
    }

    private class DoHierarchyWork implements fflib_SObjectUnitOfWork.IDoWork {

        public DoHierarchyWork(fflib_ISObjectUnitOfWork uow) {
            uow.registerWork(this);
        }

        private List<HierarchyReference> references = new List<HierarchyReference>();

        public void registerRelationship(SObject child, SObjectField field, SObject parent) {
            this.registerRelationship(new HierarchyReference(child, field, parent));
        }

        public void registerRelationship(HierarchyReference parentChildReference) {
            this.references.add(parentChildReference);
        }

        public void doWork() {

            Map<SObjectType, List<SObject>> recordsToUpdateMap = new Map<SObjectType, List<SObject>>();

            for (HierarchyReference referenceVar : references) {

                referenceVar.child.put(referenceVar.field, referenceVar.parent.Id);

                List<SObject> records = recordsToUpdateMap.get(referenceVar.child.getSObjectType());
                if (records == null) {
                    records = new List<SObject>();
                    recordsToUpdateMap.put(referenceVar.child.getSObjectType(), records);
                }

                if (new Map<Id, SObject>(records).containsKey(referenceVar.child.Id) == false) {
                    records.add(referenceVar.child);
                }

            }

            for (SObjectType sObjectTypeVar : recordsToUpdateMap.keySet()) {
                update recordsToUpdateMap.get(sObjectTypeVar);
            }

        }

    }

    public static vertic_UnitOfWork getDeduplicable(List<SObjectType> objectTypes){
        return new vertic_UnitOfWork(
            objectTypes,
            new DeduplicableDMLIml()
        );
    }

    private class HierarchyReference {
        public SObject child;
        public SObjectField field;
        public SObject parent;

        public HierarchyReference(SObject child, SObjectField field, SObject parent) {
            this.child = child;
            this.field = field;
            this.parent = parent;
        }
    }

    public class DoAsyncProcessWork implements fflib_SObjectUnitOfWork.IDoWork {

        private vertic_AsyncProcess asyncProcess;
        private List<AsyncProcessRelationship> asyncProcessRelationships = new List<AsyncProcessRelationship>();
        private Boolean autoEnqueue = true;

        private DoAsyncProcessWork(fflib_ISObjectUnitOfWork uow) {
            this();
            uow.registerWork(this);
        }

        private DoAsyncProcessWork() {
            this(new vertic_AsyncProcess());
        }

        private DoAsyncProcessWork(vertic_AsyncProcess asyncProcess) {
            this.asyncProcess = asyncProcess;
        }

        public vertic_AsyncProcess get() {
            return this.asyncProcess;
        }

        public void set(vertic_AsyncProcess asyncProcess) {
            this.asyncProcess = asyncProcess;
        }

        public void setAutoEnqueue(Boolean autoEnqueue) {
            this.autoEnqueue = autoEnqueue;
        }

        public Vertic_Async_Process__c register(Vertic_Async_Process__c verticAsyncProcessVar, Map<String, SObject> mapping) {
            this.asyncProcessRelationships.add(new AsyncProcessRelationship(
                verticAsyncProcessVar,
                mapping
            ));
            return verticAsyncProcessVar;
        }

        public Vertic_Async_Process__c register(Type processor, SObject sObjectVar) {
            Vertic_Async_Process__c verticAsyncProcessVar = vertic_AsyncProcess.create(
                processor,
                new Map<String, Object>{
                }
            );
            this.asyncProcessRelationships.add(new AsyncProcessRelationship(
                verticAsyncProcessVar,
                new Map<String, SObject>{
                    'recordId' => sObjectVar
                }
            ));
            return verticAsyncProcessVar;
        }

        public void doWork() {
            for (AsyncProcessRelationship asyncProcessRelationship : asyncProcessRelationships) {
                this.asyncProcess.add(asyncProcessRelationship.resolve());
            }

            if (this.autoEnqueue == true) {
                this.asyncProcess.enqueue();
            }
        }
    }

    private class AsyncProcessRelationship {
        private Vertic_Async_Process__c asyncProcessVar;
        private Map<String, SObject> mapping;

        private AsyncProcessRelationship(Vertic_Async_Process__c asyncProcessVar, Map<String, SObject> mapping) {
            this.asyncProcessVar = asyncProcessVar;
            this.mapping = mapping;
        }

        private Vertic_Async_Process__c resolve() {
            String payloadStr = vertic_Utils.objects.defaultIfNull(asyncProcessVar.Payload__c, '');
            Map<String, Object> payloadMap = (Map<String, Object>) JSON.deserializeUntyped(payloadStr);
            for (String key : this.mapping.keySet()) {
                payloadMap.put(key, this.mapping.get(key).Id);
            }
            asyncProcessVar.Payload__c = JSON.serialize(payloadMap);
            return this.asyncProcessVar;
        }
    }

    public virtual class DatabaseDMLIml implements fflib_SObjectUnitOfWork.IDML {

        protected Database.DMLOptions dmlOptions;
        protected Boolean isLogEnabled = true;

        public DatabaseDMLIml() {
            this(new Database.DMLOptions());
            this.dmlOptions.OptAllOrNone = true;
            this.dmlOptions.AllowFieldTruncation = true;
        }

        public DatabaseDMLIml(Database.DMLOptions dmlOptions) {
            this.dmlOptions = dmlOptions;
        }

        public DatabaseDMLIml(Database.DMLOptions dmlOptions, Boolean isLogEnabled) {
            this(dmlOptions);
            this.isLogEnabled = isLogEnabled;
        }

        public virtual void dmlInsert(List<SObject> objList) {
            try {
                List<Database.SaveResult> saveResults = Database.insert(objList, this.dmlOptions);
                if(this.isLogEnabled == true){
                    for (Database.SaveResult saveResult : saveResults) {
                        if (!saveResult.isSuccess()) {
                            System.debug(saveResult);
                            hey.Logger.debug(saveResult);
                        }
                    }
                }
            } catch (Exception ex) {
                if (this.isLogEnabled == true) {
                    System.debug(objList);
                    hey.Logger.exception(ex);
                    hey.Logger.debug(objList);
                }
                throw ex;
            }
        }
        public virtual void dmlUpdate(List<SObject> objList) {
            try {
                List<Database.SaveResult> saveResults = Database.update(objList, this.dmlOptions);
                if(this.isLogEnabled == true){
                    for (Database.SaveResult saveResult : saveResults) {
                        if (!saveResult.isSuccess()) {
                            System.debug(saveResult);
                            hey.Logger.debug(saveResult);
                        }
                    }
                }
            } catch (Exception ex) {
                if (this.isLogEnabled == true) {
                    System.debug(objList);
                    hey.Logger.exception(ex);
                    hey.Logger.debug(objList);
                }
                throw ex;
            }
        }
        public virtual void dmlDelete(List<SObject> objList) {
            try {
                List<Database.DeleteResult> deleteResults = Database.delete(objList);
                if(this.isLogEnabled == true){
                    for (Database.DeleteResult deleteResult : deleteResults) {
                        if (!deleteResult.isSuccess()) {
                            System.debug(deleteResult);
                            hey.Logger.debug(deleteResult);
                        }
                    }
                }
            } catch (Exception ex) {
                if (this.isLogEnabled == true) {
                    System.debug(objList);
                    hey.Logger.exception(ex);
                    hey.Logger.debug(objList);
                }
                throw ex;
            }
        }

        public virtual void eventPublish(List<SObject> objList){
            EventBus.publish(objList);
        }
    }

    public virtual class DeduplicableDMLIml extends DatabaseDMLIml {

        //protected Set<SObjectField> preserveFields;
        protected Map<SObjectType, Set<SObjectField>> preserveFieldsMap = new Map<SObjectType, Set<SObjectField>>();
        protected List<PreserveRecordFields> preserveRecordFields = new List<PreserveRecordFields>();

        public DeduplicableDMLIml() {
            super();
        }

        public DeduplicableDMLIml(Map<SObjectType, Set<SObjectField>> preserveFieldsMap) {
            super();
            this.preserveFieldsMap = preserveFieldsMap;
        }

        public DeduplicableDMLIml(Database.DMLOptions dmlOptions) {
            super(dmlOptions);
        }

        public DeduplicableDMLIml(Database.DMLOptions dmlOptions, Boolean isLogEnabled, Map<SObjectType, Set<SObjectField>> preserveFieldsMap) {
            super(dmlOptions, isLogEnabled);
            this.preserveFieldsMap = preserveFieldsMap;
        }

        public virtual override void dmlInsert(List<SObject> objList) {
            try {
                Set<SObjectField> preserveFields = this.getPreserveFields(objList);
                vertic_Utils.sObjects.insertDeduplicable(objList, preserveFields);
            } catch (Exception ex) {
                if (this.isLogEnabled == true) {
                    System.debug(objList);
                    System.debug(ex);
                    hey.Logger.exception(ex);
                    hey.Logger.debug(objList);
                }
                throw ex;
            }
        }

        public virtual void preserveFields(SObject recordVar, Set<SObjectField> preserveFields){
            this.preserveRecordFields.add(new PreserveRecordFields(
                recordVar,
                preserveFields
            ));
        }

        private Set<SObjectField> getPreserveFields(List<SObject> objList){

            System.assertNotEquals(null, objList);

            Set<SObjectField> preserveFields = new Set<SObjectField>();

            if(objList.isEmpty()){
                return preserveFields;
            }

            SObjectType sObjectTypeVar = objList.get(0).getSObjectType();
            Set<SObjectField> globalPreserveFields = this.preserveFieldsMap.get(sObjectTypeVar);

            if(globalPreserveFields != null){
                preserveFields.addAll(globalPreserveFields);
            }

            for (PreserveRecordFields preserveRecordFieldsVar : this.preserveRecordFields) {
                for (SObject recordVar : objList) {
                    if(preserveRecordFieldsVar.isSameRecordByReference(recordVar)){
                        preserveFields.addAll(preserveRecordFieldsVar.getFields());
                    }
                }
            }

            return preserveFields;
        }
    }

    private class PreserveRecordFields {
        private SObject recordVar;
        private Set<SObjectField> preserveFields = new Set<SObjectField>();

        private PreserveRecordFields(SObject recordVar, Set<SObjectField> preserveFields){
            this.recordVar = recordVar;
            this.preserveFields = preserveFields;
        }

        private Boolean isSameRecordByReference(SObject recordVar){
            return this.recordVar === recordVar;
        }

        private Set<SObjectField> getFields(){
            return this.preserveFields;
        }
    }

}