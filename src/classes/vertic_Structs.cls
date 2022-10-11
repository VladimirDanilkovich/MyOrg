public class vertic_Structs {

    /**
     * ==============================================================================================================
     *                                             COMMON STRUCTURES
     * ==============================================================================================================
     */

    public virtual class SelectOption{

        public Object value;
        public String label;

        public SelectOption() {}

        public SelectOption(Object value, String label) {
            this.value = value;
            this.label = label;
        }

        public SelectOption(String value) {
            this(value, value);
        }
    }

    public virtual class ErrorDetails {
        public String message {get; set;}

        public ErrorDetails(String message) {
            this.message = message;
        }
    }

    public class ExceptionDetails extends ErrorDetails {
        public Integer lineNumber {get; set;}
        public String stackTraceString {get; set;}
        public String typeName {get; set;}

        public ExceptionDetails(Exception ex) {
            super(ex.getMessage());
            this.lineNumber = ex.getLineNumber();
            this.stackTraceString = ex.getStackTraceString();
            this.typeName = ex.getTypeName();
        }
    }


    /**
     * ==============================================================================================================
     *                                             TEMPLATE STRUCTURES
     * ==============================================================================================================
     */

    public enum TemplateType {
        COMPONENT, HTML
    }

    public class TemplateSection {
        public TemplateType type;
        public String value;

        public TemplateSection(TemplateType type, String value) {
            this.type = type;
            this.value = value;
        }
    }

    public abstract class Expression {
        public String source;
        public List<String> params = new List<String>();

        public Expression(String source) {
            this.source = source;
            this.parseSource();
        }

        protected abstract void parseSource();
        protected abstract String getValue(vertic_DTO dtoVar);

        public virtual String apply(vertic_DTO dtoVar, String targetStr) {
            String expressionStrToReplace = ('{!' + this.source + '}');
            String escapedExpressionStrToReplace = expressionStrToReplace.replaceAll('\\p{Punct}', '\\\\$0');
            return targetStr.replaceAll(escapedExpressionStrToReplace, this.getValue(dtoVar));
        }
    }

    public virtual class MergeFieldExpression extends Expression {

        public MergeFieldExpression(String source) {
            super(source);
        }

        protected override void parseSource() {
            this.params.add(this.source);
        }

        protected override String getValue(vertic_DTO dtoVar) {
            String path = this.params.get(0);
            String value = vertic_Utils.objects.defaultIfNull(dtoVar.getString(path), '');
            return value;
        }

    }

    public virtual class DocumentImageExpression extends Expression {

        public DocumentImageExpression(String source) {
            super(source);
        }

        protected override void parseSource() {
            String placeholder = this.source;
            placeholder = placeholder.removeStartIgnoreCase('DOCUMENT_IMAGE(');
            placeholder = placeholder.removeEndIgnoreCase(')');
            List<String> params = placeholder.split(',');
            for (String param : params) {
                this.params.add(param == null ? null : param.trim());
            }
        }

        protected override String getValue(vertic_DTO dtoVar) {

            String documentNameMergeField = this.params.get(0);
            String styles = this.params.size() > 1 ? this.params.get(1) : '';

            String documentName = dtoVar.getString(documentNameMergeField);

            String imageLink;
            try {
                imageLink = vertic_DocumentImageCtrl.getImageLink(documentName);
            } catch (vertic_Structs.MissingDataException e) {
                return String.format('<div style="border: 2px solid red;">Unable to render the image. No document with name: {0}</div>', new List<String>{
                    documentName
                });
            }

//            System.debug('documentNameMergeField: ' + documentNameMergeField);
//            System.debug('stylesstyles: ' + styles);
//            System.debug('documentName: ' + documentName);
//            System.debug('imageLink: ' + imageLink);

            return String.format('<img src="{0}" style="{1}"/>', new List<String>{
                imageLink,
                styles
            });
        }

    }


    /**
     * ==============================================================================================================
     *                                             INTERFACES
     * ==============================================================================================================
     */

    public interface IMappable {
        Map<String, Object> getMap();
    }

    public interface ISchedulable {
        void start();
        void stop();
    }

    public interface IAsyncPostProcessing {
        Vertic_Async_Process__c postProcess(Vertic_Async_Process__c asyncProcess);
    }

    public interface IRollbackable {}

    public interface ISerializable {
        String serialize();
    }

    public abstract class Serializable implements ISerializable {

        public virtual String serialize() {
            return JSON.serialize(this);
        }
        public String getJSON() {
            return this.serialize();
        }

    }

    /**
     * ==============================================================================================================
     *                                             EXCEPTIONS
     * ==============================================================================================================
     */

    public class CommonException extends Exception {}
    public class MissingDataException extends Exception {}
    public class UtilsException extends Exception {}
    public class InvalidDataException extends Exception {}
    public class NotFoundException extends Exception {}
    public class ValidationException extends Exception {}
    public class InitException extends Exception {}
    public class ProcessException extends Exception {}

}