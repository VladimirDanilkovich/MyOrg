public without sharing class vertic_DocumentImageCtrl {

    private static Organization organizationVar {get {
        if(organizationVar == null){
            organizationVar = [SELECT Id, InstanceName FROM Organization WHERE Id = :UserInfo.getOrganizationId() LIMIT 1];
        }
        return organizationVar;
    } private set;}

    private static Map<String, Id> cacheMap = new Map<String, Id>();

    public static String getImageLink(String documentAPIName){
        Id docId;
        String docApiName = documentAPIName.toLowerCase();
        vertic_Utils.objects.throwIfBlank(docApiName, 'No Document API Name for Visualforce component vertic_DocumentImage');
        docId = cacheMap.get(docApiName);
        if (docId == null) {
            List<Document> documents = [SELECT Id FROM Document WHERE DeveloperName = :docApiName LIMIT 1];
            if (documents.isEmpty()) {
                throw new vertic_Structs.MissingDataException('No Document with API Name: ' + documentAPIName);
            } else {
                docId = documents.get(0).Id;
                cacheMap.put(docApiName, docId);
            }
        }

        return String.format(
            'https://c.{2}.content.force.com/servlet/servlet.ImageServer?id={0}&oid={1}',
            new List<String>{
                docId,
                UserInfo.getOrganizationId(),
                organizationVar.InstanceName
            }
        );
    }

    public String documentAPIName { get; set; }
    public String link {
        get {
            return getImageLink(this.documentAPIName);
        }
        private set;
    }

}