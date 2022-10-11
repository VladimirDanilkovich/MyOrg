public virtual class vertic_DTO implements vertic_Structs.IMappable {
    public Map<String, Object> dto = new Map<String, Object>();

    public vertic_DTO() {}

    public vertic_DTO(String requestJSON) {
        this.dto = (Map<String, Object>) JSON.deserializeUntyped(requestJSON);
    }

    public vertic_DTO(Map<String, Object> requestMap) {
        this.dto = requestMap == null ? this.dto : requestMap;
    }

    public Map<String, Object> getMap() {
        return this.dto;
    }

    public Object get(String path) {
        return vertic_Utils.arrays.getMapValue(this.dto, path);
    }

    public Object get(String path, Type objType) {
        Object value = this.get(path);
        return JSON.deserialize(JSON.serialize(value), objType);
    }

    public String getId(String path) {
        return (Id) vertic_Utils.arrays.getMapValue(this.dto, path);
    }

    public String getString(String path) {
        Object val = vertic_Utils.arrays.getMapValue(this.dto, path);
        return val == null ? null : String.valueOf(val);
    }

    public String getRequiredString(String path) {
        return this.getRequiredString(path, 'The following parameter is missing in the request: ' + path);
    }

    public String getRequiredString(String path, String errorMessage) {
        String val = this.getString(path);
        vertic_Utils.objects.throwIfBlank(val, errorMessage);
        return val;
    }

    public Integer getInteger(String path) {
        Object val = vertic_Utils.arrays.getMapValue(this.dto, path);
        return val == null ? null : Integer.valueOf(val);
    }

    public Long getLong(String path) {
        Object val = vertic_Utils.arrays.getMapValue(this.dto, path);
        if(val == null){
            return null;
        }
        if(val instanceof String){
            return Long.valueOf((String)val);
        }
        return (Long)val;
    }

    public Decimal getDecimal(String path) {
        return vertic_Utils.objects.parseDecimal(vertic_Utils.arrays.getMapValue(this.dto, path));
    }

    public Boolean getBoolean(String path) {
        Object val = vertic_Utils.arrays.getMapValue(this.dto, path);
        if(val == null){
            return null;
        }
        if(val instanceof Boolean){
            return (Boolean)val;
        }
        return Boolean.valueOf(val);
    }

    public Date getISODate(String path) {
        String dateStr = this.getString(path);
        return String.isBlank(dateStr) ? null : Date.valueOf(dateStr);
    }

    public List<Object> getList(String path) {
        return (List<Object>) vertic_Utils.arrays.getMapValue(this.dto, path);
    }

    public List<String> getListAsStrings(String path) {
        List<String> strings = new List<String>();

        List<Object> objects = (List<Object>) vertic_Utils.arrays.getMapValue(this.dto, path);

        if(objects == null){
            return null;
        }

        for (Object obj : objects) {
            strings.add(obj == null ? null : obj.toString());
        }

        return strings;
    }

    public List<Map<String, Object>> getListAsMap(String path) {
        List<Map<String, Object>> returnList = new List<Map<String, Object>>();

        List<Object> objects = getList(path);
        if (objects == null) {
            return null;
        }

        for (Object obj : objects) {
            returnList.add((Map<String, Object>) obj);
        }

        return returnList;
    }

    public Boolean has(String path) {
        return vertic_Utils.arrays.mapContains(this.dto, path);
    }

    public vertic_DTO put(String path, Object value) {
        vertic_Utils.arrays.setMapValue(this.dto, path, value);

        return this;
    }

    public vertic_AutoMapper getMapper(){
        return new vertic_AutoMapper(this);
    }
}