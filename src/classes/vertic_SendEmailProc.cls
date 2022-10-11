public virtual class vertic_SendEmailProc extends vertic_AbstractProcessor implements vertic_Structs.IAsyncPostProcessing {

    /**
     * ==============================================================================================================
     *                                              PROCESS
     * ==============================================================================================================
     */

    public virtual override vertic_Response process(vertic_Request request) {
        this.request = request;

        this.isEmailsTurnedOn = vertic_Utils.emails.isEmailsTurnedOn();

        if (this.isEmailsTurnedOn == true) {
            this.sendEmail();
        }

        return this.response;
    }

    @TestVisible
    protected virtual vertic_Response process(EmailAsyncProcess emailAsyncProcessRequest) {
        return this.process(emailAsyncProcessRequest.payloadMap);
    }

    public Vertic_Async_Process__c postProcess(Vertic_Async_Process__c asyncProcess) {
        if (this.isEmailsTurnedOn != true) {
            asyncProcess.Status__c = 'Skipped';
        }
        return asyncProcess;
    }


    /**
     * ==============================================================================================================
     *                                             PRIVATE METHODS
     * ==============================================================================================================
     */

    protected virtual void sendEmail() {

        Messaging.SingleEmailMessage emailVar = new Messaging.SingleEmailMessage();

        String templateName = this.request.getString('email.templateName');
        if(String.isNotBlank(templateName)){
            Id templateId = vertic_Utils.emails.getEmailTemplateIdByName(templateName);
            emailVar.setTemplateId(templateId);
        } else if (this.request.has('email.htmlBody')) {
            emailVar.setHtmlBody(this.request.getString('email.htmlBody'));
        } else {
            PageReference pageRef = Page.vertic_Content;
            if(this.request.dto != null && this.request.dto.get('params') != null){
                Map<String, Object> params = (Map<String, Object>)this.request.dto.get('params');
                for (String dtoKey : params.keySet()) {
                    pageRef.getParameters().put(
                        dtoKey,
                        '' + params.get(dtoKey)
                    );
                }
            }

            String emailContent = Test.isRunningTest() ? 'fake content' : pageRef.getContent().toString();

            emailVar.setHtmlBody(emailContent);
        }

        String targetId = this.request.getString('email.targetId');
        if(String.isNotBlank(targetId)){
            emailVar.setTargetObjectId(targetId);
        }

        String whatId = this.request.getString('email.whatId');
        if(String.isNotBlank(whatId)){
            emailVar.setWhatId(whatId);
        }

        Boolean saveAsActivity = this.request.getBoolean('email.saveAsActivity');
        if(saveAsActivity != null){
            emailVar.setSaveAsActivity(saveAsActivity);
        }

        Boolean useSignature = this.request.getBoolean('email.useSignature');
        if(useSignature != null){
            emailVar.setUseSignature(useSignature);
        }

        String subject = this.request.getString('email.subject');
        if(String.isNotBlank(subject)){
            emailVar.setSubject(subject);
        }

        String orgWideEmail = this.request.getString('email.orgWideEmail');
        if(String.isNotBlank(orgWideEmail)){
            OrgWideEmailAddress orgWideEmailAddresses = (OrgWideEmailAddress)vertic_Utils.arrays.firstOrNull([SELECT Id FROM OrgWideEmailAddress WHERE Address = :orgWideEmail]);
            if(orgWideEmailAddresses != null){
                emailVar.setOrgWideEmailAddressId(orgWideEmailAddresses.Id);
            }
        }

        List<String> toAddresses = this.request.getListAsStrings('email.toAddresses');
        if(toAddresses != null){
            emailVar.setToAddresses(toAddresses);
        }

        List<String> ccAddresses = this.request.getListAsStrings('email.ccAddresses');
        if(ccAddresses != null){
            emailVar.setCcAddresses(ccAddresses);
        }

        List<String> bccAddresses = this.request.getListAsStrings('email.bccAddresses');
        if(ccAddresses != null){
            emailVar.setBccAddresses(bccAddresses);
        }

        List<Messaging.EmailFileAttachment> emailFileAttachments = new List<Messaging.EmailFileAttachment>();
        List<Object> attachments = this.request.getList('email.attachments');
        if(attachments != null){
            Map<String, List<String>> contentDocumentIdsMap = new Map<String, List<String>>{
                'contentDocumentIds' => new List<String>()
            };
            for (Object attachmentVar : attachments) {
                vertic_DTO verticDTO = new vertic_DTO((Map<String, Object>)attachmentVar);
                List<String> contentDocumentIds = verticDTO.getListAsStrings('contentDocumentIds');
                if (!contentDocumentIds.isEmpty()) {
                    contentDocumentIdsMap.get('contentDocumentIds').addAll(contentDocumentIds);
                }
            }
            if (!contentDocumentIdsMap.get('contentDocumentIds').isEmpty()) {
                emailFileAttachments.addAll(this.addEmailFileAttachments(contentDocumentIdsMap));
                emailVar.setFileAttachments(emailFileAttachments);
            }
        }

        List<Object> contentAttachments = this.request.getList('email.contentAttachments');
        if(contentAttachments != null){
            for (Object contentAttachmentObj : contentAttachments) {
                Map<String, Object> contentAttachment = (Map<String, Object>)contentAttachmentObj;
                PageReference pageRef = Page.vertic_Content;
                for(String key : contentAttachment.keySet()) {
                    pageRef.getParameters().put(key, (String) contentAttachment.get(key));
                }
                System.debug(pageRef);
                Blob contentBlob;
                try {
                    if (!Test.isRunningTest()) {
                        contentBlob = pageRef.getContentAsPDF();
                    } else {
                        contentBlob = Blob.valueOf('fake content');
                    }
                } catch (Exception e) {
                    throw new vertic_Structs.CommonException('Unable to render attachment');
                }
                String fileName = (String)contentAttachment.get('fileName');
                if (String.isBlank(fileName)) {
                    filename = 'Attachment' + (contentAttachments.indexOf(contentAttachment) + 1) + '.pdf';
                }
                Messaging.EmailFileAttachment emailFileAttachmentVar = new Messaging.EmailFileAttachment();
                emailFileAttachmentVar.setBody(contentBlob);
                emailFileAttachmentVar.setFileName(fileName);
                emailFileAttachments.add(emailFileAttachmentVar);
            }
        }

        if (!emailFileAttachments.isEmpty()) {
            emailVar.setFileAttachments(emailFileAttachments);
        }

        if ( !Test.isRunningTest() ) {
            List<Messaging.SendEmailResult> sendEmailResults = Messaging.sendEmail(
                new List<Messaging.Email>{
                    emailVar
                },
                false
            );

            for (Messaging.SendEmailResult sendEmailResult : sendEmailResults) {
                if (!sendEmailResult.isSuccess()) {
                    hey.Logger.error( sendEmailResult.getErrors() );
                    hey.Logger.debug( this.request.dto );
                    this.response = new vertic_Response( JSON.serialize( sendEmailResult.getErrors() ) );
                } else{
                    this.response.getMapper().mapAnyValue('isEmailSent', true);
                }
            }
        } else {
            this.response.put('countAttachments', emailVar.getFileAttachments() != null ? emailVar.getFileAttachments().size() : 0);
        }
    }

    protected List<Messaging.EmailFileAttachment> addEmailFileAttachments(Map<String, Object> attachmentSetting){
        List<Messaging.EmailFileAttachment> emailFileAttachments = new List<Messaging.EmailFileAttachment>();

        vertic_DTO verticDTO = new vertic_DTO(attachmentSetting);
        List<String> contentDocumentIds = verticDTO.getListAsStrings('contentDocumentIds');

        if(contentDocumentIds != null){
            List<ContentDocument> contentDocuments = [
                SELECT Id, Title, LatestPublishedVersion.VersionData
                FROM ContentDocument
                WHERE Id IN :contentDocumentIds
            ];
            for (ContentDocument contentDocumentVar : contentDocuments) {
                Messaging.EmailFileAttachment emailFileAttachmentVar = new Messaging.EmailFileAttachment();
                emailFileAttachmentVar.setBody(contentDocumentVar.LatestPublishedVersion.VersionData);
                emailFileAttachmentVar.setFileName(contentDocumentVar.Title);

                emailFileAttachments.add(emailFileAttachmentVar);
            }
        }

        return emailFileAttachments;
    }

    public static EmailAsyncProcess newAsyncProcess(String vfComponent, Map<String, Object> params){
        return new EmailAsyncProcess(vfComponent, params);
    }

//    public static EmailAsyncProcess newAsyncProcess(String templateName, String targetId, String whatId){
//        return new EmailAsyncProcess(templateName, targetId, whatId);
//    }

    public class EmailAsyncProcess{

        Map<String, Object> payloadMap = new Map<String, Object>();

        public EmailAsyncProcess(String templateName, String targetId, String whatId){
            this.setTemplateName(templateName)
                .setTargetId(targetId)
                .setWhatId(whatId);
        }

        public EmailAsyncProcess(String templateName, Contact contactVar, String whatId){
            this.checkTarget(contactVar);
            this.setTemplateName(templateName)
                .setTargetId(contactVar.Id)
                .setWhatId(whatId);
        }

        public EmailAsyncProcess(String templateName, User userVar, String whatId){
            this.checkTarget(userVar);
            this.generateEmailWithUser(templateName, userVar, whatId);
        }

        public EmailAsyncProcess(String templateName, Lead leadVar, String whatId){
            this.checkTarget(leadVar);
            this.setTemplateName(templateName)
                .setTargetId(leadVar.Id)
                .setWhatId(whatId);
        }

        public EmailAsyncProcess(String vfComponent, Map<String, Object> params){
            vertic_Utils.arrays.setMapValue(this.payloadMap, 'params', params);
            vertic_Utils.arrays.setMapValue(this.payloadMap, 'params.proc', vfComponent);
        }

        private void checkTarget(SObject targetVar){
            if(targetVar instanceof Contact || targetVar instanceof User || targetVar instanceof Lead){
                vertic_Utils.objects.throwIfBlank((String)targetVar.get('Email'), 'Email is blank on record with Id: ' + targetVar.Id);
            } else {
                throw new vertic_Structs.ValidationException('Unsupported Target Type. Can be Contact, User or Lead.');
            }
        }

        private void generateEmailWithUser(String templateName, User userVar, String whatId) {
            String templateId = vertic_Utils.emails.getEmailTemplateIdByName(templateName);

            if (templateId == null) {
                throw new vertic_Structs.ValidationException('No email template with name ' + templateName);
            }

            Messaging.SingleEmailMessage emailMessage = Messaging.renderStoredEmailTemplate(
                templateId,
                userVar.Id,
                whatId
            );

            this.setTargetId(userVar.Id);
            this.setSubject(emailMessage.getSubject());
            this.setHtmlBody(emailMessage.getHtmlBody());
            this.setSaveAsActivity(false);
        }

        public Map<String, Object> getPayload() {
            return this.payloadMap;
        }

        public EmailAsyncProcess setTargetId(Id targetId){
            vertic_Utils.arrays.setMapValue(this.payloadMap, 'email.targetId', targetId);
            return this;
        }

        public EmailAsyncProcess setWhatId(Id whatId){
            vertic_Utils.arrays.setMapValue(this.payloadMap, 'email.whatId', whatId);
            return this;
        }

        private EmailAsyncProcess setTemplateName(String templateName){
            vertic_Utils.arrays.setMapValue(this.payloadMap, 'email.templateName', templateName);
            return this;
        }

        private EmailAsyncProcess setHtmlBody(String htmlBody){
            vertic_Utils.arrays.setMapValue(this.payloadMap, 'email.htmlBody', htmlBody);
            return this;
        }

        public EmailAsyncProcess setSaveAsActivity(Boolean saveAsActivity){
            vertic_Utils.arrays.setMapValue(this.payloadMap, 'email.saveAsActivity', saveAsActivity);
            return this;
        }

        public EmailAsyncProcess setUseSignature(Boolean useSignature){
            vertic_Utils.arrays.setMapValue(this.payloadMap, 'email.useSignature', useSignature);
            return this;
        }

        public EmailAsyncProcess setSubject(String subject){
            vertic_Utils.arrays.setMapValue(this.payloadMap, 'email.subject', subject);
            return this;
        }

        public EmailAsyncProcess setOrgWideEmail(String orgWideEmail){
            vertic_Utils.arrays.setMapValue(this.payloadMap, 'email.orgWideEmail', orgWideEmail);
            return this;
        }

        public EmailAsyncProcess setToAddresses(List<String> toAddresses){
            vertic_Utils.arrays.setMapValue(this.payloadMap, 'email.toAddresses', toAddresses);
            return this;
        }

        public EmailAsyncProcess setCCAddresses(List<String> ccAddresses){
            vertic_Utils.arrays.setMapValue(this.payloadMap, 'email.ccAddresses', ccAddresses);
            return this;
        }

        public EmailAsyncProcess setBCCAddresses(List<String> bccAddresses){
            vertic_Utils.arrays.setMapValue(this.payloadMap, 'email.bccAddresses', bccAddresses);
            return this;
        }

        public EmailAsyncProcess setAttachments(List<Map<String, Object>> attachments){
            vertic_Utils.arrays.setMapValue(this.payloadMap, 'email.attachments', attachments);
            return this;
        }

        public EmailAsyncProcess setContentAttachments(List<Map<String, Object>> contentAttachments){
            vertic_Utils.arrays.setMapValue(this.payloadMap, 'email.contentAttachments', contentAttachments);
            return this;
        }

        public EmailAsyncProcess setPayloadParam(String path, Object val){
            vertic_Utils.arrays.setMapValue(this.payloadMap, path, val);
            return this;
        }

        public Vertic_Async_Process__c toAsyncProcess(){
            return toAsyncProcess(vertic_SendEmailProc.class);
        }

        public Vertic_Async_Process__c toAsyncProcess(Type processorType){
            return new Vertic_Async_Process__c(
                Processor__c = '' + processorType,
                Payload__c = JSON.serialize(this.payloadMap)
            );
        }
    }

    /**
     * ==============================================================================================================
     *                                               STRUCTURES
     * ==============================================================================================================
     */

    // Proposed Live Templates to override Super properties:
    // vertic_request
    // vertic_response

    private Boolean isEmailsTurnedOn = false;


}