public class vertic_AutoMapper implements vertic_Structs.IMappable {

    private Options options = new Options(this);
    private Map<String, Object> stringToObjectMap;

    public vertic_AutoMapper() {
        this.stringToObjectMap = new Map<String, Object>();
    }

    public vertic_AutoMapper(Map<String, Object> stringToObjectMap) {
        this.stringToObjectMap = stringToObjectMap;
        if (this.stringToObjectMap == null) this.stringToObjectMap = new Map<String, Object>();
    }

    public vertic_AutoMapper(vertic_Structs.IMappable mappableImpl) {
        this(mappableImpl.getMap());
    }

    public Map<String, Object> getMap() {
        return this.stringToObjectMap;
    }

    public Options getOptions() {
        return this.options;
    }

    public vertic_AutoMapper mapToSObject(SObject sObj) {
        return mapToSObject(sObj, false);
    }

    public vertic_AutoMapper mapToSObject(String path, SObject sObj) {
        return mapToSObject(path, sObj, false);
    }

    public vertic_AutoMapper mapToSObject(SObject sObj, Boolean skipValidation) {
        return mapToSObject(sObj, skipValidation, null);
    }
    public vertic_AutoMapper mapToSObject(SObject sObj, Boolean skipValidation, BinderQueue binderQueue) {
        return mapToSObject('', sObj, skipValidation, binderQueue);
    }

    public vertic_AutoMapper mapToSObject(String path, SObject sObj, Boolean skipValidation) {
        return mapToSObject(path, sObj, skipValidation, null);
    }

    public vertic_AutoMapper mapToSObject(String path, SObject sObj, Boolean skipValidation, BinderQueue binderQueue) {

        Object value;
        if (String.isNotBlank(path)) {
            value = vertic_Utils.arrays.getMapValue(this.stringToObjectMap, path);
        } else {
            value = this.stringToObjectMap;
        }

        if (value != null) {
            Map<String, Object> dataMap = (Map<String, Object>) value;

            SkipBinderQueue skipBinderQueue = new SkipBinderQueue(binderQueue);

            if (this.options.isVisualforce) {
                this.populateSObjectFieldsVF(sObj, dataMap, skipValidation, skipBinderQueue);
            } else {
                this.populateSObjectFields(sObj, dataMap, skipValidation, skipBinderQueue);
            }

            if (skipBinderQueue.skipRecord(sObj, dataMap)) {
                return this;
            }

            if (binderQueue != null) {
                binderQueue.process(sObj, dataMap);
            }
        }

        return this;
    }


    public List<SObject> mapToListSObjects(String path, SObjectType sObjectTypeVar) {
        return mapToListSObjects(path, sObjectTypeVar, false);
    }

    public List<SObject> mapToListSObjects(String path, SObjectType sObjectTypeVar, Boolean skipValidation) {
        return mapToListSObjects(path, sObjectTypeVar, skipValidation, null);
    }

    public List<SObject> mapToListSObjects(String path, SObjectType sObjectTypeVar, Boolean skipValidation, BinderQueue binderQueue) {

        List<Object> values = (List<Object>)vertic_Utils.arrays.getMapValue(this.stringToObjectMap, path);

        if(values == null){
            return null;
        }

        SkipBinderQueue skipBinderQueue = new SkipBinderQueue(binderQueue);

        List<SObject> sObjects = new List<SObject>();

        for (Object value : values) {
            SObject sObj = sObjectTypeVar.newSObject();

            Map<String, Object> dataMap = (Map<String, Object>) value;

            if (this.options.isVisualforce) {
                this.populateSObjectFieldsVF(sObj, dataMap, skipValidation, skipBinderQueue);
            } else {
                this.populateSObjectFields(sObj, dataMap, skipValidation, skipBinderQueue);
            }

            if (skipBinderQueue.skipRecord(sObj, dataMap)) {
                continue;
            }

            if (binderQueue != null) {
                binderQueue.process(sObj, dataMap);
            }

            sObjects.add(sObj);
        }

        return sObjects;
    }

    public vertic_AutoMapper mapFromSObject(String propertyName, SObject sObj) {
        return sObj == null ? null : this.mapFromSObject(propertyName, sObj, null);
    }

    public vertic_AutoMapper mapFromSObject(String path, SObject sObj, BinderQueue binderQueue) {

        SkipBinderQueue skipBinderQueue = new SkipBinderQueue(binderQueue);

        Map<String, Object> dataMap;

        if (this.options.isVisualforce) {
            dataMap = this.getSObjectAsMapVF(sObj, skipBinderQueue);
        } else {
            dataMap = this.getSObjectAsMap(sObj, skipBinderQueue);

        }

        if (skipBinderQueue.skipRecord(sObj, dataMap)) {
            return this;
        }

        if (binderQueue != null) {
            binderQueue.process(sObj, dataMap);
        }

        vertic_Utils.arrays.setMapValue(
            this.stringToObjectMap,
            path,
            dataMap
        );

        return this;
    }

    public vertic_AutoMapper mapFromListSObjects(String path, List<SObject> sObjects) {
        return sObjects == null ? null : this.mapFromListSObjects(path, sObjects, null);
    }

    public vertic_AutoMapper mapFromListSObjects(String path, List<SObject> sObjects, BinderQueue binderQueue) {
        return mapFromListSObjects(path, sObjects, binderQueue, null);
    }

    public vertic_AutoMapper mapFromListSObjects(String path, List<SObject> sObjects, BinderQueue binderQueue, Integer recordsLimit) {

        String recordsPath = path;

        if(recordsLimit != null){
            Boolean hasMore = sObjects.size() > recordsLimit;
            while(sObjects.size() > recordsLimit){
                sObjects.remove(sObjects.size() - 1);
            }
            recordsPath = path + '.records';
            String hasMorePath = path + '.hasMore';
            String limitPath = path + '.limit';
            String countPath = path + '.count';

            this.mapAnyValue(hasMorePath, hasMore);
            this.mapAnyValue(limitPath, recordsLimit);
            this.mapAnyValue(countPath, sObjects.size());
        }

        vertic_Utils.arrays.setMapValue(
            this.stringToObjectMap,
            recordsPath,
            this.getSObjectsAsMaps(sObjects, binderQueue)
        );

        return this;
    }


    public List<Map<String, Object>> getSObjectsAsMaps(List<SObject> sObjects){
        return getSObjectsAsMaps(sObjects, null);
    }

    public List<Map<String, Object>> getSObjectsAsMaps(List<SObject> sObjects, BinderQueue binderQueue) {
        SkipBinderQueue skipBinderQueue = new SkipBinderQueue(binderQueue);

        List<Map<String, Object>> sObjMaps = new List<Map<String, Object>>();

        for (SObject sObj : sObjects) {
            Map<String, Object> sObjMap = new Map<String, Object>();

            if (this.options.isVisualforce) {
                sObjMap = this.getSObjectAsMapVF(sObj, skipBinderQueue);
            } else {
                sObjMap = this.getSObjectAsMap(sObj, skipBinderQueue);
            }

            if (skipBinderQueue.skipRecord(sObj, sObjMap)) {
                continue;
            }

            if (binderQueue != null) {
                binderQueue.process(sObj, sObjMap);
            }

            sObjMaps.add(sObjMap);
        }
        return sObjMaps;
    }

    public vertic_AutoMapper mapAnyValue(String path, Object value) {
        vertic_Utils.arrays.setMapValue(this.stringToObjectMap, path, value);

        return this;
    }

    public Map<String, Object> getSObjectAsMap(SObject sObj) {
        return getSObjectAsMap(sObj, null);
    }

    public Map<String, Object> getSObjectAsMap(SObject sObj, SkipBinderQueue skipBinderQueue) {
        Map<String, Object> sObjMap = new Map<String, Object>();

        if (skipBinderQueue != null && skipBinderQueue.skipRecord(sObj, sObjMap)) {
            return sObjMap;
        }

        Map<String, Object> populatedFieldsMap = sObj.getPopulatedFieldsAsMap();
        Map<String, SObjectField> fieldsMap = sObj.getSObjectType().getDescribe().fields.getMap();

        for (String fieldName : populatedFieldsMap.keySet()) {
            Object fieldValue = populatedFieldsMap.get(fieldName);
            SObjectField fieldVar = fieldsMap.get(fieldName);

            if (skipBinderQueue != null && skipBinderQueue.skipField(sObj, sObjMap, fieldVar)) {
                continue;
            }

            if (fieldValue instanceof List<SObject>) {
                // Skip related Lists
            } else if (fieldValue instanceof SObject) {
                sObjMap.put(fieldName, this.getSObjectAsMap((SObject) fieldValue, skipBinderQueue));
            } else if (fieldValue != null && fieldVar != null && fieldVar.getDescribe().type == DisplayType.DATE) {
                sObjMap.put(fieldName, fieldValue);
            } else if (fieldValue != null && fieldVar != null && fieldVar.getDescribe().type == DisplayType.DATETIME) {
                sObjMap.put(fieldName, fieldValue);
            } else if (fieldValue != null && fieldVar != null && fieldVar.getDescribe().type == DisplayType.TIME) {
                sObjMap.put(fieldName, fieldValue);
            } else {
                sObjMap.put(fieldName, fieldValue == null ? options.defaultFieldValue : fieldValue);
            }
        }

        if (options.isAllFields == true) {
            for (SObjectField field : fieldsMap.values()) {
                String fieldName = field.getDescribe().getName();
                if (!populatedFieldsMap.containsKey(fieldName)) {
                    sObjMap.put(fieldName, options.defaultFieldValue);
                }
            }
        }

        return sObjMap;
    }

    public Map<String, Object> getSObjectAsMapVF(SObject sObj) {
        return getSObjectAsMapVF(sObj, null);
    }

    public Map<String, Object> getSObjectAsMapVF(SObject sObj, SkipBinderQueue skipBinderQueue) {
        Map<String, Object> sObjMap = new Map<String, Object>();

        if (skipBinderQueue != null && skipBinderQueue.skipRecord(sObj, sObjMap)) {
            return sObjMap;
        }

        Map<String, Object> populatedFieldsMap = sObj.getPopulatedFieldsAsMap();
        Map<String, SObjectField> fieldsMap = sObj.getSObjectType().getDescribe().fields.getMap();

        for (String fieldName : populatedFieldsMap.keySet()) {
            Object fieldValue = populatedFieldsMap.get(fieldName);
            SObjectField fieldVar = fieldsMap.get(fieldName);

            if (skipBinderQueue != null && skipBinderQueue.skipField(sObj, sObjMap, fieldVar)) {
                continue;
            }

            if (fieldValue instanceof List<SObject>) {
                // Skip related Lists
            } else if (fieldValue instanceof SObject) {
                sObjMap.put(fieldName, this.getSObjectAsMapVF((SObject) fieldValue, skipBinderQueue));
            } else if (fieldValue != null && fieldVar != null && fieldVar.getDescribe().type == DisplayType.DATE) {
                sObjMap.put(fieldName, vertic_Utils.dates.dateToDateTime(((Date) fieldValue)).format('dd/MM/yyyy'));
            } else if (fieldValue != null && fieldVar != null && fieldVar.getDescribe().type == DisplayType.DATETIME) {
                sObjMap.put(fieldName, ((Datetime) fieldValue).format());
            } else if (fieldValue != null && fieldVar != null && fieldVar.getDescribe().type == DisplayType.TIME) {
                sObjMap.put(fieldName, Datetime.newInstance(Date.today(), (Time) fieldValue).format('hh:mm a'));
            } else {
                sObjMap.put(fieldName, fieldValue == null ? options.defaultFieldValue : fieldValue);
            }

        }

        if (options.isAllFields == true) {
            for (SObjectField field : fieldsMap.values()) {
                String fieldName = field.getDescribe().getName();
                if (!populatedFieldsMap.containsKey(fieldName)) {
                    sObjMap.put(fieldName, options.defaultFieldValue);
                }
            }
        }

        return sObjMap;
    }

    private SObject populateSObjectFields(SObject sObj, Map<String, Object> sObjMap, Boolean skipValidation, SkipBinderQueue skipBinderQueue) {
        if (skipBinderQueue != null && skipBinderQueue.skipRecord(sObj, sObjMap)) {
            return sObj;
        }

        Map<String, SObjectField> fieldsMap = sObj.getSObjectType().getDescribe().fields.getMap();
        for (String property : sObjMap.keySet()) {

            SObjectField field = fieldsMap.get(property.toLowerCase());

            if (field != null) {
                if (skipBinderQueue != null && skipBinderQueue.skipField(sObj, sObjMap, field)) {
                    continue;
                }
                try {
                    Object fieldValue = sObjMap.get(property);
                    if (fieldValue instanceof String && String.isNotBlank((String) fieldValue)) {
                        DisplayType fieldDisplayType = field.getDescribe().type;
                        String fieldValueStr = (String) fieldValue;

                        if (fieldDisplayType == DisplayType.DATE) {
                            fieldValue = Date.valueOf(fieldValueStr);
                            //fieldValue = JSON.deserialize(fieldValueStr, Date.class);
                        } else if (fieldDisplayType == DisplayType.DATETIME) {
                            if (!fieldValueStr.startsWith('"')) {
                                fieldValueStr = '"' + fieldValueStr;
                            }
                            if (!fieldValueStr.endsWith('"')) {
                                fieldValueStr = fieldValueStr + '"';
                            }
                            fieldValue = JSON.deserialize(fieldValueStr, Datetime.class);
//                        } else if (fieldDisplayType == DisplayType.TIME) {
//                            Datetime dt = vertic_Utils.dates.parseDatetimeAnyFormat((String) fieldValue, 'hh:mm a');
//                            fieldValue = dt == null ? fieldValue : dt.time();
//                        } else if (fieldDisplayType == DisplayType.BOOLEAN) {
//                            fieldValue = 'Yes'.equalsIgnoreCase((String) fieldValue) ? true : false;
                        } else if (new Set<DisplayType>{
                            DisplayType.DOUBLE, DisplayType.CURRENCY
                        }.contains(fieldDisplayType)) {
                            fieldValue = String.isBlank(fieldValueStr) ? null : Decimal.valueOf(fieldValueStr);
                        } else if (new Set<DisplayType>{DisplayType.INTEGER}.contains(fieldDisplayType)) {
                            fieldValue = String.isBlank(fieldValueStr) ? null : Integer.valueOf(fieldValueStr);
                        } else if (DisplayType.BASE64 == fieldDisplayType) {
                            fieldValue = EncodingUtil.base64Decode(fieldValueStr);
                        } else if (DisplayType.BOOLEAN == fieldDisplayType){
                            sObj.put(property, Boolean.valueOf(fieldValue));
                        }
                    }
                    if (fieldValue instanceof Long && (fieldValue instanceof Integer) == false) {
                        sObj.put(property, (Long) fieldValue);
                    } else {
                        sObj.put(property, fieldValue);
                    }
                } catch (SObjectException ex) { // Skip "System.SObjectException: Field is not editable"
                } catch (Exception ex) {
                    hey.Logger.debug(property);
                    throw ex;
                }
            } else {
                Boolean isCustomSObjectField = property.endsWithIgnoreCase('__c');
                if (isCustomSObjectField && skipValidation != true) {
                    throw new vertic_Structs.MissingDataException(String.format(
                        'No Field with name {0} on {1}',
                        new List<String>{
                            property,
                            '' + sObj
                        }
                    ));
                }
            }
        }
        return sObj;
    }

    private SObject populateSObjectFieldsVF(SObject sObj, Map<String, Object> sObjMap, Boolean skipValidation, SkipBinderQueue skipBinderQueue) {
        if (skipBinderQueue != null && skipBinderQueue.skipRecord(sObj, sObjMap)) {
            return sObj;
        }

        Map<String, SObjectField> fieldsMap = sObj.getSObjectType().getDescribe().fields.getMap();
        for (String property : sObjMap.keySet()) {

            SObjectField field = fieldsMap.get(property.toLowerCase());

            if (field != null) {
                if (skipBinderQueue != null && skipBinderQueue.skipField(sObj, sObjMap, field)) {
                    continue;
                }
                try {
                    Object fieldValue = sObjMap.get(property);
                    if (fieldValue instanceof String && String.isNotBlank((String) fieldValue)) {
                        DisplayType fieldDisplayType = field.getDescribe().type;
                        String fieldValueStr = (String) fieldValue;

                        if (fieldDisplayType == DisplayType.DATE) {
                            fieldValue = vertic_Utils.dates.parseDateAusFormat((String) fieldValue);
                        } else if (fieldDisplayType == DisplayType.DATETIME) {
                            fieldValue = vertic_Utils.dates.parseDatetimeAusFormat((String) fieldValue);
                        } else if (fieldDisplayType == DisplayType.TIME) {
                            Datetime dt = vertic_Utils.dates.parseDatetimeAnyFormat((String) fieldValue, 'hh:mm a');
                            fieldValue = dt == null ? fieldValue : dt.time();
                        } else if (fieldDisplayType == DisplayType.BOOLEAN) {
                            fieldValue = 'Yes'.equalsIgnoreCase((String) fieldValue) ? true : false;
                        } else if (new Set<DisplayType>{
                            DisplayType.DOUBLE, DisplayType.CURRENCY
                        }.contains(fieldDisplayType)) {
                            fieldValue = String.isBlank(fieldValueStr) ? null : Decimal.valueOf(fieldValueStr);
                        } else if (new Set<DisplayType>{
                            DisplayType.INTEGER
                        }.contains(fieldDisplayType)) {
                            fieldValue = String.isBlank(fieldValueStr) ? null : Integer.valueOf(fieldValueStr);
                        }
                    }
                    if (fieldValue instanceof Long && (fieldValue instanceof Integer) == false) {
                        sObj.put(property, (Long) fieldValue);
                    } else {
                        sObj.put(property, fieldValue);
                    }
                } catch (SObjectException ex) { // Skip "System.SObjectException: Field is not editable"
                } catch (Exception ex) {
                    hey.Logger.debug(property);
                    throw ex;
                }
            } else {
                Boolean isCustomSObjectField = property.endsWithIgnoreCase('__c');
                if (isCustomSObjectField && skipValidation != true) {
                    throw new vertic_Structs.MissingDataException(String.format(
                        'No Field with name {0} on {1}',
                        new List<String>{
                            property,
                            '' + sObj
                        }
                    ));
                }
            }
        }
        return sObj;
    }

    public class Options {
        private vertic_AutoMapper autoMapper;
        public Boolean isVisualforce = false;
        public Boolean isAllFields = false;
        public Object defaultFieldValue = '';

        public Options(vertic_AutoMapper autoMapper) {
            this.autoMapper = autoMapper;
        }

        public vertic_AutoMapper getMapper() {
            return this.autoMapper;
        }

        public Options setIsVisualforce(Boolean value) {
            this.isVisualforce = value == true;
            return this;
        }

        public Options setIsAllFields(Boolean value) {
            this.isAllFields = value == true;
            return this;
        }

        public Options setDefaultFieldValue(Object value) {
            this.defaultFieldValue = value;
            return this;
        }
    }



    /**
     * ==============================================================================================================
     *                                             BINDING
     * ==============================================================================================================
     */


    public interface IBinder {
        void bind(SObject record, Map<String, Object> dataMap);
    }

    public interface ISkipRecordBinder extends IBinder {
        Boolean skipRecord(SObject record, Map<String, Object> dataMap);
    }

    public interface ISkipFieldBinder extends IBinder {
        Boolean skipField(SObject record, Map<String, Object> dataMap, SObjectField field);
    }

    public abstract class AbstractBinder implements IBinder {
        public AbstractBinder() {}
    }

    public class BinderQueue {
        private List<IBinder> binders = new List<IBinder>();

        public BinderQueue(IBinder binder) {
            this.addBinder(binder);
        }

        public BinderQueue(List<IBinder> binders) {
            this.binders = binders != null ? binders : this.binders;
        }

        public List<IBinder> getBinders() {
            return this.binders;
        }

        public BinderQueue addBinder(IBinder binder) {
            this.binders.add(binder);
            return this;
        }

        public void process(SObject record, Map<String, Object> dataMap) {
            for(IBinder binderVar : this.binders){
                binderVar.bind(record, dataMap);
            }
        }
    }

    public class SkipBinderQueue {
        private List<ISkipFieldBinder> skipFieldBinders = new List<ISkipFieldBinder>();
        private List<ISkipRecordBinder> skipRecordBinders = new List<ISkipRecordBinder>();

        public SkipBinderQueue(BinderQueue binderQueue) {
            if (binderQueue != null) {
                this(binderQueue.getBinders());
            }
        }

        public SkipBinderQueue(IBinder binder) {
            this.addBinder(binder);
        }

        public SkipBinderQueue(List<IBinder> binders) {
            for (IBinder binder : binders) {
                this.addBinder(binder);
            }
        }

        public SkipBinderQueue addBinder(IBinder binder) {
            if (binder instanceof ISkipFieldBinder) {
                this.skipFieldBinders.add((ISkipFieldBinder) binder);
            }
            if (binder instanceof ISkipRecordBinder) {
                this.skipRecordBinders.add((ISkipRecordBinder) binder);
            }
            return this;
        }

        public Boolean skipRecord(SObject sObj, Map<String, Object> dataMap) {
            for (ISkipRecordBinder skipRecordBinder : this.skipRecordBinders) {
                if (skipRecordBinder.skipRecord(sObj, dataMap)) {
                    return true;
                }
            }
            return false;
        }

        public Boolean skipField(SObject sObj, Map<String, Object> dataMap, SObjectField field) {
            for (ISkipFieldBinder skipFieldBinder : this.skipFieldBinders) {
                if (skipFieldBinder.skipField(sObj, dataMap, field)) {
                    return true;
                }
            }
            return false;
        }

    }


    public virtual class JoinStringFieldsBinder extends AbstractBinder{

        protected String path;
        protected List<SObjectField> joinFields = new List<SObjectField>();
        protected String separator;
        protected Boolean skipBlankValues;

        public JoinStringFieldsBinder(String resultPath, List<SObjectField> joinFields, String separator){
            this(resultPath, joinFields, separator, true);
        }

        public JoinStringFieldsBinder(String resultPath, List<SObjectField> joinFields, String separator, Boolean skipBlankValues){
            this.path = resultPath;
            this.joinFields = joinFields;
            this.separator = separator;
            this.skipBlankValues = skipBlankValues;
        }

        public void bind(SObject record, Map<String, Object> dataMap) {

            List<String> values = new List<String>();

            for (SObjectField sObjectFieldVar : joinFields) {
                String val = record.get(sObjectFieldVar) == null ? null : '' + record.get(sObjectFieldVar);
                if(String.isNotBlank(val) || this.skipBlankValues == false){
                    values.add(val);
                }
            }

            String joinedValue = String.join(values, this.separator);

            vertic_Utils.arrays.setMapValue(dataMap, this.path, joinedValue);
        }
    }

    public virtual class JoinStringBinder extends AbstractBinder{

        protected String path;
        protected List<String> joinPaths = new List<String>();
        protected String separator;
        protected Boolean skipBlankValues;

        public JoinStringBinder(String resultPath, List<String> joinPaths, String separator){
            this(resultPath, joinPaths, separator, true);
        }

        public JoinStringBinder(String resultPath, List<String> joinPaths, String separator, Boolean skipBlankValues){
            this.path = resultPath;
            this.joinPaths = joinPaths;
            this.separator = separator;
            this.skipBlankValues = skipBlankValues;
        }

        public void bind(SObject record, Map<String, Object> dataMap) {

            List<String> values = new List<String>();

            for (String joinPathVar : joinPaths) {
                Object objVal = vertic_Utils.arrays.getMapValue(dataMap, joinPathVar);
                String val = objVal == null ? null : '' + objVal;

                if(String.isNotBlank(val) || this.skipBlankValues == false){
                    values.add(val);
                }
            }

            String joinedValue = String.join(values, this.separator);

            vertic_Utils.arrays.setMapValue(dataMap, this.path, joinedValue);
        }
    }

    public virtual class DatetimeFormatBinder extends AbstractBinder{

        protected String path;
        protected SObjectField fieldVar;
        protected String format;

        public DatetimeFormatBinder(String path, SObjectField fieldVar, String format){
            this.path = path;
            this.fieldVar = fieldVar;
            this.format = format;
        }

        public void bind(SObject record, Map<String, Object> dataMap) {

            Object objVal = record.get(fieldVar);

            Datetime dateTimeVar;
            if(objVal instanceof Date){
                dateTimeVar = vertic_Utils.dates.dateToDateTime((Date)objVal);
            } else if (objVal instanceof Datetime){
                dateTimeVar = (Datetime)objVal;
            }

            if(dateTimeVar != null){
                vertic_Utils.arrays.setMapValue(dataMap, this.path, dateTimeVar.format(this.format));
            }
        }
    }

    public virtual class DefaultValueBinder extends AbstractBinder{

        protected String path;
        protected Object val;
        protected Boolean isOverrideExisting;

        public DefaultValueBinder(String path, Object val, Boolean isOverrideExisting){
            this.path = path;
            this.val = val;
            this.isOverrideExisting = isOverrideExisting;
        }

        public DefaultValueBinder(String path, Object val){
            this(path, val, false);
        }

        public void bind(SObject record, Map<String, Object> dataMap) {

            Object objVal = vertic_Utils.arrays.getMapValue(dataMap, this.path);

            if(objVal == null || this.isOverrideExisting == true){
                vertic_Utils.arrays.setMapValue(dataMap, this.path, this.val);
            }

        }
    }

    public virtual class IncludeFieldsBinder implements ISkipFieldBinder {

        protected Set<SObjectField> fields;

        public IncludeFieldsBinder(Set<SObjectField> fields) {
            this.fields = fields == null ? new Set<SObjectField>() : fields;
        }

        public void bind(SObject record, Map<String, Object> dataMap) {}

        public Boolean skipField(SObject record, Map<String, Object> dataMap, SObjectField field) {
            return !this.fields.contains(field);
        }
    }

    public virtual class ExcludeFieldsBinder implements ISkipFieldBinder {

        protected Set<SObjectField> fields;

        public ExcludeFieldsBinder(Set<SObjectField> fields) {
            this.fields = fields == null ? new Set<SObjectField>() : fields;
        }

        public void bind(SObject record, Map<String, Object> dataMap) {}

        public Boolean skipField(SObject record, Map<String, Object> dataMap, SObjectField field) {
            return this.fields.contains(field);
        }
    }



}