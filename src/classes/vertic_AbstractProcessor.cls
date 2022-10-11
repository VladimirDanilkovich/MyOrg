public abstract class vertic_AbstractProcessor {

    protected vertic_Request request;
    protected vertic_Response response = getResponseInstance();

    public abstract vertic_Response process(vertic_Request request);

    public virtual vertic_Response process(Map<String, Object> requestMap){
        return this.process(new vertic_Request(requestMap));
    }

    public virtual Type getRequestType() { return vertic_Request.class; }

    public virtual vertic_Request getRequestInstance(String requestJSON) {
        return new vertic_Request(requestJSON);
    }

    public virtual vertic_Request getRequestInstance(Map<String, Object> requestMap) {
        return new vertic_Request(requestMap);
    }

    protected virtual vertic_Response getResponseInstance() {
        return new vertic_Response();
    }

}