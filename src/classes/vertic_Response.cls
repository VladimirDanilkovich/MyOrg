public virtual class vertic_Response extends vertic_DTO {

    public Boolean isValid = true;
    public vertic_Structs.ErrorDetails error;
    public List<vertic_Structs.ErrorDetails> errors = new List<vertic_Structs.ErrorDetails>();

    public vertic_Response() {}

    public vertic_Response(Map<String, Object> requestMap) {
        super(requestMap);
    }

    public vertic_Response(Exception ex) {
        this();

        this.isValid = (ex == null);

        if (ex != null) {
            this.error = new vertic_Structs.ExceptionDetails(ex);
            this.errors.add(this.error);
        }
    }

    public vertic_Response(List<Exception> exs) {
        this(exs == null || exs.isEmpty() ? null : exs.get(0));

        this.errors = new List<vertic_Structs.ErrorDetails>();
        for (Exception ex : exs) {
            this.errors.add(new vertic_Structs.ExceptionDetails(ex));
        }
    }

    public vertic_Response(List<String> messages) {
        this(String.join(messages, ', '));

        this.errors = new List<vertic_Structs.ErrorDetails>();
        for (String message : messages) {
            this.errors.add(new vertic_Structs.ErrorDetails(message));
        }
    }

    public vertic_Response(String message) {
        this();

        this.isValid = (String.isBlank(message));

        if (String.isNotBlank(message)) {
            this.error = new vertic_Structs.ErrorDetails(message);
            this.errors.add(this.error);
        }
    }

    public String getJSON() {
        return JSON.serialize(this);
    }

}