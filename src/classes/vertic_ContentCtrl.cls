public class vertic_ContentCtrl extends vertic_MetadataCtrl {

    private final String HTML = 'html';
    private final String ADVANCED_PDF = 'advanced_pdf';
    private final String PDF_EXPORT = 'pdfexport';
    private final String EXCEL = 'excel';

    private final Map<String, String> CONTENT_TYPE_BY_RENDER_AS = new Map<String, String>{
        EXCEL => 'application/vnd.ms-excel',
        PDF_EXPORT => 'application/pdf'
    };

    public String paramsStr {
        get;
        set {
            if (String.isNotBlank(value)) {

                Map<String, Object> params = (Map<String, Object>) JSON.deserializeUntyped(value.replace('`', '"'));
                for (String key : params.keySet()) {
                    Object val = params.get(key);
                    if (value != null) {
                        ApexPages.currentPage().getParameters().put(key, val.toString());
                    }
                }

                this.onInit();
            }
        }
    }

    public ApexPages.Component headComponent { get; private set; }
    public List<ApexPages.Component> components { get; set; }
    public List<Object> componentsAsObjects { get; set; }

    // Prevent the double processor invocation for Content and Content Body page controllers.
    public static Boolean isInitialised = false;

    public override void onInit() {

        if(isInitialised == true){
            return;
        }
        isInitialised = true;

        super.onInit();

        this.componentsAsObjects = this.response.getList('components');
        this.components = new List<ApexPages.Component>();
        for (Object cmp : this.componentsAsObjects) {
            this.components.add((ApexPages.Component) cmp);
        }
        this.headComponent = (ApexPages.Component) this.response.get('head-component');

        this.response.dto.putAll(ApexPages.currentPage().getParameters());
    }

    public String getPageStyles() {
        String param = this.response.getString('page-styles');
        return String.isBlank(param) ? '' : param;
    }

    public String getCustomStyles() {
        String param = this.response.getString('custom-styles');
        return String.isBlank(param) ? '' : param;
    }

    public String getPageEvenStyles() {
        String param = this.response.getString('page-even-styles');
        return String.isBlank(param) ? '' : param;
    }

    public String getPageOddStyles() {
        String param = this.response.getString('page-odd-styles');
        return String.isBlank(param) ? '' : param;
    }

    public String getFontSize() {
        String param = this.response.getString('font-size');
        return String.isBlank(param) ? '11pt' : param;
    }

    public String getFontFamily() {
        String param = this.response.getString('font-family');
        return String.isBlank(param) ? 'Arial Unicode MS' : param;
    }

    public String getContentType() {
        String fileName = this.response.getString('fileName');

        String renderAs = this.response.getString('renderAs').toLowerCase();
        renderAs = renderAs != null ? renderAs.toLowerCase() : renderAs;

        String contentType = 'text/html';

        if (CONTENT_TYPE_BY_RENDER_AS.containsKey(renderAs)) {
            contentType = CONTENT_TYPE_BY_RENDER_AS.get(renderAs);

            if (String.isBlank(fileName)) {
                fileName = this.response.getString('proc');
            }
        }

        if (String.isNotBlank(fileName)) {
            ApexPages.currentPage().getHeaders().put('content-disposition', 'attachment; filename=' + fileName);
        }

        return contentType;
    }

    public String getRenderAs() {
        String renderAs = this.response.getString('renderAs');
        renderAs = renderAs != null ? renderAs.toLowerCase() : renderAs;
        if (CONTENT_TYPE_BY_RENDER_AS.containsKey(renderAs)) {
            return HTML;
        }
        return vertic_Utils.objects.defaultIfNull(this.response.getString('renderAs'), ADVANCED_PDF);
    }

    public String getRenderAsForBody() {
        String renderAs = this.response.getString('renderAs');
        renderAs = renderAs != null ? renderAs.toLowerCase() : renderAs;
        if (CONTENT_TYPE_BY_RENDER_AS.containsKey(renderAs)) {
            if (PDF_EXPORT.equalsIgnoreCase(renderAs)) {
                return ADVANCED_PDF;
            }
            return HTML;
        }
        return vertic_Utils.objects.defaultIfNull(this.response.getString('renderAs'), ADVANCED_PDF);
    }

    public Component.Apex.OutputPanel getPanel() {
        Component.Apex.OutputPanel panel = new Component.Apex.OutputPanel();

        for (ApexPages.Component component : this.components) {
            panel.childComponents.add(component);

            Component.Apex.OutputPanel pageBreak = new Component.Apex.OutputPanel(styleClass = 'page-break', layout = 'block');
            panel.childComponents.add(pageBreak);
        }

        if (!panel.childComponents.isEmpty()) {
            panel.childComponents.remove(panel.childComponents.size() - 1);
        }

        return panel;
    }

    protected override virtual vertic_Request initRequest() {
        vertic_Request request = super.initRequest();
        if (ApexPages.currentPage() != null) {
            request.dto.putAll(ApexPages.currentPage().getParameters());
        }
        return request;
    }

}