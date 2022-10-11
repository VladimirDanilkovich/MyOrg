@RestResource(urlMapping='/*')
global class vertic_RestService {

    /**
     * ==============================================================================================================
     *                                              PROCESS
     * ==============================================================================================================
     */

    @HttpGet global static void handleGet() { handleRequest(); }
    @HttpPost global static void handlePost() { handleRequest(); }
    @HttpPut global static void handlePut() { handleRequest(); }
    @HttpPatch global static void handlePatch() { handleRequest(); }
    @HttpDelete global static void handleDelete() { handleRequest(); }

    @TestVisible
    private static void handleRequest() {
        try {

            String httpMethod = RestContext.request.httpMethod.toLowerCase();
            String requestURI = RestContext.request.requestURI;

            String methodName = requestURI.toLowerCase().substringAfter('/').substringBefore('/');

            String processorName = methodName + httpMethod + 'Proc';

            vertic_AbstractProcessor processorVar = vertic_ProcessorFactory.getInstance(processorName, 'Unsupported Method: ' + methodName);

            Request req = new Request();
            if (RestContext.request.params != null) req.params.putAll(RestContext.request.params);
            if (RestContext.request.headers != null) req.headers.putAll(RestContext.request.headers);
            if (RestContext.request.requestBody != null && String.isNotBlank(RestContext.request.requestBody.toString())) {
                req.dto.putAll((Map<String, Object>) JSON.deserializeUntyped(RestContext.request.requestBody.toString()));
            }

            Response resp = (Response) processorVar.process(req);

            if (resp.isValid != true) {
                throw new RestException(resp.error.message);
            }

            if (resp.headers != null && resp.headers.size() > 0) {
                for (String key : resp.headers.keySet()) {
                    RestContext.response.addHeader(key, resp.headers.get(key));
                }
            } else {
                jsonResponse();
            }

            setStatusCode(resp.statusCode);

            if (RestContext.response.responseBody == null) {
                setBody(resp.dto);
            }

        } catch (Exception ex) {
        	hey.Logger.exception(ex);
            errorResponse(ex.getMessage());
        } finally {
        	hey.Logger.publish();
        }
    }


    /**
     * ==============================================================================================================
     *                                             PRIVATE METHODS
     * ==============================================================================================================
     */

    private static void setStatusCode(Integer statusCode) {
        RestContext.response.statusCode = statusCode != null ? statusCode : 200;
    }

    private static void setBody(Map<String, Object> data) {
        if (data != null && data.size() > 0) {
            RestContext.response.responseBody = Blob.valueOf(JSON.serialize(data));
        }
    }

    private static void setBody(Object result) {
        RestContext.response.responseBody = Blob.valueOf(JSON.serialize(result));
    }

    private static void jsonResponse() {
        RestContext.response.addHeader('Content-Type', 'application/json');
    }

    public static void jsonResponse(Object result, Integer statusCode) {
        jsonResponse();
        setBody(result);
        setStatusCode(statusCode);
    }

    public static void jsonResponse(Object result) {
        jsonResponse(result, 200);
    }

    public static void errorResponse(Object result) {
        jsonResponse(result, 400);
    }


    /**
     * ==============================================================================================================
     *                                             STRUCTURES AND OVERRIDES
     * ==============================================================================================================
     */

    public class RestException extends Exception {}

    public class Request extends vertic_Request {
        public Map<String, String> params = new Map<String, String>();
        public Map<String, String> headers = new Map<String, String>();
    }

    /** ============================================================================================================= */

    public class Response extends vertic_Response {
        public Map<String, String> headers = new Map<String, String>();
        public Integer statusCode;
    }

    /** ============================================================================================================= */

}