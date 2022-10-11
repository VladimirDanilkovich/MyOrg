public virtual class vertic_Request extends vertic_DTO {

    public vertic_Request() {}

    public vertic_Request(Map<String, Object> requestMap) {
        super(requestMap);
    }

    public vertic_Request(String requestJSON) {
        super(requestJSON);
    }

    public String getJSON() {
        return JSON.serialize(this);
    }

}