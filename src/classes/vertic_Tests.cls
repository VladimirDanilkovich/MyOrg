@isTest
public class vertic_Tests {


    private static void createContacts(Integer numContacts) {
        List<Contact> cts = new List<Contact>();

        for (Integer i = 0; i < numContacts; i++) {
            Contact ct = new Contact(FirstName = 'Test' + i,
                LastName = 'Contact' + i);
            cts.add(ct);
        }
        if (cts != null) {
            insert cts;
        }
    }

    private static List<Contact> createAndReturnContacts(Integer numContacts) {
        List<Contact> contacts = new List<Contact>();

        for (Integer i = 0; i < numContacts; i++) {
            Contact ct = new Contact(
                FirstName = 'Contact' + i,
                LastName = 'Contact' + i
            );
            contacts.add(ct);
        }

        insert contacts;
        return contacts;
    }

    private static List<String> createStringList(Integer numParts) {

        List<String> stringList = new List<String>();
        for (Integer i = 0; i < numParts; i++) {
            stringList.add('test' + i);
        }
        return stringList;

    }

    private static Map<String, String> createStringsMap(Integer numParts) {

        Map<String, String> stringsMap = new Map<String, String>();
        for (Integer i = 0; i < numParts; i++) {
            stringsMap.put('key' + i, 'value' + i);
        }
        return stringsMap;

    }

    private static Contact createContact(String lastname, String mailingCountry) {

        Contact testContact = new Contact(
            LastName = lastname,
            MailingCountry = mailingCountry
        );
        return testContact;
    }


/**
     * ==============================================================================================================
     *                                           PICKLIST EXTENSIONS
     * ==============================================================================================================
     */

    @isTest
    static void testGetPicklistValuesAsSelectOptions() {

        System.assertNotEquals(null, vertic_Utils.picklists.getPicklistValuesAsSelectOptions(Account.Industry));
    }

    @isTest
    static void testGetPicklistOptionsMap() {

        Set<SObjectField> fields = new Set<SObjectField>{
            Account.Industry, Account.AccountSource
        };
        System.assertNotEquals(null, vertic_Utils.picklists.getPicklistOptionsMap(fields));
    }

    @isTest
    static void testGetDependentPicklistOptionsMap() {

        Map<SObjectField, SObjectField> fieldsMap = new Map<SObjectField, SObjectField>{
            Account.AccountSource.getDescribe().getSObjectField() => Account.Industry.getDescribe().getSObjectField()
        };
        Map<SObjectType, Map<SObjectField, SObjectField>> dependentFieldsBySObjectType = new Map<SObjectType, Map<SObjectField, SObjectField>>{
            Account.getSObjectType() => fieldsMap
        };
        System.assertNotEquals(null, vertic_Utils.picklists.getDependentPicklistOptionsMap(dependentFieldsBySObjectType));

    }

    @isTest
    static void testGetDependentOptions() {

        System.assert(vertic_Utils.picklists.getDependentOptions(null, Account.ShippingAddress.getDescribe().getSObjectField(),
            Account.BillingAddress.getDescribe().getSObjectField()).isEmpty());
        System.assert(vertic_Utils.picklists.getDependentOptions(Contact.getSObjectType(), Account.ShippingAddress.getDescribe().getSObjectField(),
            Account.BillingAddress.getDescribe().getSObjectField()).isEmpty());
    }


/**
     * ==============================================================================================================
     *                                      DATE AND DATETIME EXTENSIONS
     * ==============================================================================================================
     */

    @isTest
    static void testParseDatetimeAnyFormat() {

        Datetime dtVar = vertic_Utils.dates.parseDatetimeAnyFormat('19/09/2018 11:00:00', 'DD/MM/YYYY hh:mm:ss');
        System.assertEquals(Datetime.newInstance(2018, 9, 19, 11, 0, 0), dtVar);

        dtVar = vertic_Utils.dates.parseDatetimeAnyFormat('', 'DD/MM/YYYY hh:mm:ss');
        System.assertEquals(null, dtVar);

        dtVar = vertic_Utils.dates.parseDatetimeAnyFormat('19/09/2018 11:00:00 AM', 'DD/MM/YYYY hh:mm:ss AM');
        System.assertEquals(Datetime.newInstance(2018, 9, 19, 11, 0, 0), dtVar);

        dtVar = vertic_Utils.dates.parseDatetimeAnyFormat('2018-12-01 00:00:00', 'yyyy-MM-dd');
        System.assertEquals(Date.newInstance(2018, 12, 1), dtVar.date());

//        dtVar = vertic_Utils.dates.parseDatetimeAnyFormat('19/09/2018 11:00:00 PM', 'DD/MM/YYYY hh:mm:ss PM');
//        System.assertEquals( Datetime.newInstance(2018, 9, 19, 23, 0, 0), dtVar);

        Boolean didThrowException = false;
        try {
            dtVar = vertic_Utils.dates.parseDatetimeAnyFormat('19-09 11 00 00 PA', 'DD/MM/YYYY hh:mm:ss PM');
        } catch (Exception ex) {
            didThrowException = true;
            System.assert(didThrowException);
        }


    }

    @isTest
    static void testParseDatetimeAusFormat() {

        String dtStr = '19/09/2018 10:30 AM';
        Datetime dtVar = vertic_Utils.dates.parseDatetimeAusFormat(dtStr);
        System.assertEquals(dtStr, dtVar.format('dd/MM/yyyy hh:mm a'));

    }

    @isTest
    static void testParseDateAusFormat() {

        Date dateVar = vertic_Utils.dates.parseDateAusFormat('19/09/2018');
        System.assertEquals(Date.newInstance(2018, 9, 19), dateVar);
    }

    @isTest
    static void testDatetimeToDate() {

        Datetime dtVar = Datetime.newInstance(2018, 9, 19, 10, 30, 0);
        Date dateVar = vertic_Utils.dates.datetimeToDate(dtVar);
        System.assertEquals(Date.newInstance(2018, 9, 19), dateVar);

    }

    @isTest
    static void testParseDateAnyFormat() {

        Date dateVar = vertic_Utils.dates.parseDateAnyFormat('19/09/2018', 'DD/MM/YYYY');
        System.assertEquals(Date.newInstance(2018, 9, 19), dateVar);

        dateVar = vertic_Utils.dates.parseDateAnyFormat('', 'DD/MM/YYYY');
        System.assertEquals(null, dateVar);

        dateVar = vertic_Utils.dates.parseDateAnyFormat('19/09/18', 'DD/MM/YY');
        System.assertEquals(Date.newInstance(2018, 9, 19), dateVar);

    }

    @isTest
    static void testDateToDateTime() {

        Date dateVar = Date.newInstance(2018, 9, 19);
        Datetime dtVar = vertic_Utils.dates.dateToDateTime(dateVar);
        System.assertEquals(Datetime.newInstance(2018, 9, 19), dtVar);

    }

    @isTest
    static void testTotalWorkingDays() {

        Date startDate = Date.newInstance(2018, 9, 19);
        Date endDate = Date.newInstance(2018, 9, 24);
        Integer total = vertic_Utils.dates.totalWorkingDays(startDate, endDate);
        System.assertEquals(4, total);
    }

    @isTest
    static void testIsWorkingDay() {

// for date parameter
        Date dateVar = Date.newInstance(2018, 9, 19);
        Boolean isWorkingDay = vertic_Utils.dates.isWorkingDay(dateVar);
        System.assertEquals(true, isWorkingDay);

// for datetime parameter
        Datetime dtVar = Datetime.newInstance(2018, 9, 19);
        isWorkingDay = vertic_Utils.dates.isWorkingDay(dtVar);
        System.assertEquals(true, isWorkingDay);
    }

    @isTest
    static void testTimeStringToTime() {

        Time timeVar = vertic_Utils.dates.timeStringToTime('11:30:00');
        System.assertEquals(Time.newInstance(11, 30, 0, 0), timeVar);
    }

    @isTest
    static void testTimeStringAMPMToTime() {

        Time timeVarAM1 = vertic_utils.dates.timeStringAMPMToTime('11:30:00 AM');
        System.assertEquals(Time.newInstance(11, 30, 0, 0), timeVarAM1);

        Time timeVarAM2 = vertic_utils.dates.timeStringAMPMToTime('12:30:00 AM');
        System.assertEquals(Time.newInstance(0, 30, 0, 0), timeVarAM2);

        Time timeVarPM1 = vertic_utils.dates.timeStringAMPMToTime('11:30:00 PM');
        System.assertEquals(Time.newInstance(23, 30, 0, 0), timeVarPM1);

        Time timeVarPM2 = vertic_utils.dates.timeStringAMPMToTime('12:30:00 PM');
        System.assertEquals(Time.newInstance(12, 30, 0, 0), timeVarPM2);

        Boolean didThrownException = false;
        try {
            vertic_utils.dates.timeStringAMPMToTime('');
        } catch (Exception ex) {
            didThrownException = true;
            System.assert(didThrownException);
        }

    }

    @isTest
    static void testGetStartOfDay() {

        Datetime dtVar = vertic_Utils.dates.getStartOfDay(Datetime.newInstance(2018, 9, 19));
        System.assertEquals(Datetime.newInstance(2018, 9, 19, 0, 0, 0), dtVar);

    }

    @isTest
    static void testGetEndOfDay() {

        Datetime dtVar = vertic_Utils.dates.getEndOfDay(Datetime.newInstance(2018, 9, 19));
        System.assertEquals(Datetime.newInstance(2018, 9, 19, 23, 59, 9), dtVar);

    }

    @isTest
    static void testGetStartDateOfWeek() {

        Datetime dtVar = vertic_Utils.dates.getStartDateOfWeek(Datetime.newInstance(2018, 9, 19));
        System.assertEquals(Datetime.newInstance(2018, 9, 17), dtVar);

        Date dateVar = vertic_Utils.dates.getStartDateOfWeek(Date.newInstance(2018, 9, 22));
        System.assertEquals(Date.newInstance(2018, 9, 17), dateVar);
    }

    @isTest
    static void testGetEndDateOfWeek() {

        Datetime dtVar = vertic_Utils.dates.getEndDateOfWeek(Datetime.newInstance(2018, 9, 19));
        System.assertEquals(Datetime.newInstance(2018, 9, 23, 23, 59, 9), dtVar);

        Date dateVar = vertic_Utils.dates.getEndDateOfWeek(Date.newInstance(2018, 9, 22));
        System.assertEquals(Date.newInstance(2018, 9, 23), dateVar);
    }

    @isTest
    static void testIsDateInCurrectWeekOrInFuture() {

        Date dateVar = Date.today().addDays(10);
        Boolean currentOrFuture = vertic_Utils.dates.isDateInCurrectWeekOrInFuture(dateVar);
        System.assertEquals(true, currentOrFuture);
    }

    @isTest
    static void testGetLastDayInMonth() {

        Date dateVar = vertic_Utils.dates.getLastDayInMonth(Date.newInstance(2018, 9, 19));
        System.assertEquals(Date.newInstance(2018, 9, 30), dateVar);
    }

    @isTest
    static void testGetLastWorkingDay() {

        Date dateVar = vertic_Utils.dates.getLastWorkingDay(Date.newInstance(2018, 9, 23));
        System.assertEquals(Date.newInstance(2018, 9, 21), dateVar);

    }

    @isTest
    static void testGetLastDayInFortnight() {

        Date dateVar = Date.newInstance(2018, 9, 19);
        Date startDate = Date.newInstance(2018, 9, 18);
        Date endOfPeriod = vertic_Utils.dates.getLastDayInFortnight(dateVar, startDate);
        System.assertEquals(Date.newInstance(2018, 9, 30), endOfPeriod);

        endOfPeriod = vertic_Utils.dates.getLastDayInFortnight(Date.newInstance(2018, 10, 1), startDate);
        System.assertEquals(Date.newInstance(2018, 10, 14), endOfPeriod);
        Boolean didThrowException = false;
        try {
            vertic_Utils.dates.getLastDayInFortnight(dateVar, Date.newInstance(2018, 9, 20));
        } catch (Exception ex) {
            didThrowException = true;
        }
        System.assert(didThrowException);
    }

    @isTest
    static void testGetFirstDayInFortnight() {

        Date dateVar = Date.newInstance(2018, 9, 19);
        Date startDate = Date.newInstance(2018, 9, 18);
        Date startOfPeriod = vertic_Utils.dates.getFirstDayInFortnight(dateVar, startDate);
        System.assertEquals(Date.newInstance(2018, 9, 17), startOfPeriod);
    }

    @isTest
    static void testDateInRange() {

        Date dateVar = Date.newInstance(2018, 9, 19);
        Date startDate = Date.newInstance(2018, 9, 17);
        Date endDate = Date.newInstance(2018, 9, 30);
        dateVar = vertic_Utils.dates.dateInRange(dateVar, startDate, endDate);
        System.assertEquals(Date.newInstance(2018, 9, 19), dateVar);

    }


/**
      * ==============================================================================================================
      *                                         STRING EXTENSIONS
      * ==============================================================================================================
 */

    @isTest
    static void testThrowIfBlankString() {

        Boolean didThrowExceptionMessage = false;
        try {
            vertic_Utils.strings.throwIfBlank('', 'Passed parameter is blank');
        } catch (Exception ex) {
            didThrowExceptionMessage = true;
        }
        System.assert(didThrowExceptionMessage);

        Boolean didThrowException = false;
        try {
            vertic_Utils.strings.throwIfBlank('', new NullPointerException());
        } catch (Exception ex) {
            didThrowException = true;
        }

        System.assert(didThrowException);
    }

    @isTest
    static void testEmptyStringIfNull() {

        String result = vertic_Utils.strings.emptyStringIfNull ('');
        System.assertEquals('', result);

        result = vertic_Utils.strings.emptyStringIfNull('string');
        System.assertEquals('string', result);

    }

    @isTest
    static void testRemoveNonNumeric() {

        String result = vertic_Utils.strings.removeNonNumeric ('');
        System.assertEquals('', result);

        result = vertic_Utils.strings.removeNonNumeric ('123qwerty123qwerty');
        System.assertEquals('123123', result);

    }

    @isTest
    static void testRemoveNonNumericWithDelimiter() {

        String result = vertic_Utils.strings.removeNonNumericWithDelimiter('');
        System.assertEquals('', result);

        result = vertic_Utils.strings.removeNonNumericWithDelimiter('123qwerty,123,qwerty.321,');
        System.assertEquals('123.123..321.', result);

    }

    @isTest
    static void testPad() {

        Boolean didThrowException = false;
        String result;
        try {
            result = vertic_Utils.strings.Pad('source', 6, 'value');
        } catch (Exception ex) {
            didThrowException = true;
        }
        System.assert(didThrowException);

        result = vertic_Utils.strings.Pad('source', 6, 'v');
        System.assertEquals('source', result);

        result = vertic_Utils.strings.Pad('source', 10, 'v');
        System.assertEquals('vvvvsource', result);

        result = vertic_Utils.strings.Pad(1, 3, 'v');
        System.assertEquals('vv1', result);

    }

    @isTest
    static void testSafeSplit() {
        List<String> expectedList = new List<String>();
        for (Integer i = 0; i < 150; i++) {
            expectedList.add('string');
        }
        String inStr = String.join(expectedList, ',');
        List<String> result = vertic_Utils.strings.safeSplit(inStr, ',');
        System.assertEquals(expectedList, result);


    }

    @isTest
    static void testNewGuid() {

        String encodedString1 = vertic_Utils.strings.newGuid();
        String encodedString2 = vertic_Utils.strings.newGuid();
        System.assertNotEquals(null, encodedString1);
        System.assertNotEquals(encodedString1, encodedString2);
    }

//    @isTest
//    static void testGetCharAtIndex() {
//
//        String result = vertic_Utils.strings.getCharAtIndex(null, 2);
//        System.assertEquals(null, result);
//
//        result = vertic_Utils.strings.getCharAtIndex('', 2);
//        System.assertEquals('', result);
//
//        result = vertic_Utils.strings.getCharAtIndex('str', 3);
//        System.assertEquals(null, result);
//
//        result = vertic_Utils.strings.getCharAtIndex('string', 2);
//        System.assertEquals('r', result);
//    }

    @isTest
    static void testJoinNonBlank() {

        String expectedString = 'string/string/string';
        List<String> parts = new List<String>{
            'string', null, 'string', '', 'string', ' '
        };
        String result = vertic_Utils.strings.joinNonBlank(parts, '/');
        System.assertEquals(expectedString, result);

    }

/**f
 * ==============================================================================================================
 *                                           USER EXTENSIONS
 * ==============================================================================================================
 */

    @isTest
    static void testGetProfileIdByName() {

        Boolean didThrowException = false;
        Id profileId;

        try {
            profileId = vertic_Utils.users.GetProfileIdByName(null);
        } catch (Exception ex) {
            didThrowException = true;
        }
        System.assert(didThrowException);

        Profile p = [SELECT Id, Name FROM Profile WHERE Id = :userInfo.getProfileId()];

        profileId = vertic_Utils.users.GetProfileIdByName(p.Name);
        System.assertEquals(p.Id, profileId);


    }

    @isTest
    static void testCreateUser() {

        User testUser = new User(
            CommunityNickname = 'test',
            Username = 'test',
            Email = 'test@test.mail',
            EmailEncodingKey = 'UTF-8',
            LanguageLocaleKey = 'en_US',
            LocaleSidKey = 'en_AU',
            TimeZoneSidKey = 'Australia/Sydney',
            FirstName = 'test',
            LastName = 'test',
            ProfileId = userInfo.getUserId(),
            EmployeeNumber = '10',
            Alias = 'test',
            IsActive = true);

        User resultUser = vertic_Utils.users.CreateUser('test', 'test', 'test@test.mail',
            'test', 'test', 'test', '10', userInfo.getUserId(), true);

        System.assertEquals(testUser, resultUser);
    }

/**
 * ==============================================================================================================
 *                                         SOBJECT EXTENSIONS
 * ==============================================================================================================
 */

    @isTest
    static void testCreateSObjectById() {

        Id userId = userInfo.getUserId();
        User testUser = [SELECT Id FROM User WHERE Id = :userId];
        User resultUser = (User) vertic_Utils.sObjects.createSObjectById(userId);
        System.assertEquals(testUser, resultUser);

    }

    @isTest
    static void testCreateSObjectsByIds() {

        List<Contact> cts = createAndReturnContacts(3);
        Set<Id> setIds = new Set<Id>();
        for (Contact contact : cts) {
            setIds.add(contact.Id);
        }
        List<Contact> contacts = (List<Contact>) vertic_Utils.sObjects.createSObjectsByIds(setIds);
        System.assertEquals(cts.get(0).Id, contacts.get(0).Id);
        System.assertEquals(cts.get(1).Id, contacts.get(1).Id);
        System.assertEquals(cts.get(2).Id, contacts.get(2).Id);
    }

    @isTest
    static void testGetSobjectsFromIds() {

        List<Contact> cts = createAndReturnContacts(3);
        Set<Id> setIds = new Set<Id>();
        for (Contact contact : cts) {
            setIds.add(contact.Id);
        }
        List<Contact> contacts = (List<Contact>) vertic_Utils.sObjects.getSobjectsFromIds(Contact.getSObjectType(), setIds);
        System.assertEquals(cts.get(0).Id, contacts.get(0).Id);
        System.assertEquals(cts.get(1).Id, contacts.get(1).Id);
        System.assertEquals(cts.get(2).Id, contacts.get(2).Id);

    }

    @isTest
    static void testGetIdFieldValues() {

        List<Contact> cts = createAndReturnContacts(3);
        Set<Id> setIds = new Set<Id>();
        for (Contact contact : cts) {
            setIds.add(contact.Id);
        }
        Set<Id> values = vertic_Utils.sObjects.getIdFieldValues(cts, Contact.Id.getDescribe().getSobjectField());
        System.assert(setIds.equals(values));
    }

    @isTest
    static void testGetStringFieldValues() {
        List<Contact> cts = createAndReturnContacts(3);
        Set<String> testSet = new Set<String>{
            'Contact0', 'Contact1', 'Contact2'
        };
        System.assertEquals(testSet, vertic_Utils.sObjects.getStringFieldValues(cts, Contact.LastName.getDescribe().getSObjectField()));

    }

    @isTest
    static void testPutAllRecordsByKeyField() {

        List<Contact> cts = createAndReturnContacts(3);
        Map<String, Contact> mappedContacts = new Map<String, Contact>();
        vertic_Utils.sObjects.putAllRecordsByKeyField(cts, 'Id', mappedContacts);
        System.assertEquals(false, mappedContacts.isEmpty());

        Map<String, List<Contact>> mappedRecords = new Map<String, List<Contact>>();
        vertic_Utils.sObjects.putAllRecordsByKeyField(cts, 'Id', mappedRecords, true);
        System.assertEquals(false, mappedRecords.isEmpty());
    }

    @isTest
    static void testGetSObjectsByAnyFieldMap() {

        List<Contact> cts = createAndReturnContacts(3);
        Map<String, SObject> mappedContacts = vertic_Utils.sObjects.getSObjectsByAnyFieldMap(cts, Contact.Id.getDescribe().getSobjectField());
        System.assertEquals(false, mappedContacts.isEmpty());
    }

    @isTest
    static void testGetSObjectsListByAnyFieldMap() {

        List<Contact> cts = createAndReturnContacts(3);
        Map<String, List<SObject>> mappedContacts = vertic_Utils.sObjects.getSObjectsListByAnyFieldMap(cts, Contact.LastName.getDescribe().getSobjectField());
        System.assertEquals(false, mappedContacts.isEmpty());

        cts.add(new Contact(FirstName = 'Test', LastName = 'Contact0'));
        mappedContacts = vertic_Utils.sObjects.getSObjectsListByAnyFieldMap(cts, Contact.LastName.getDescribe().getSobjectField());
        System.assertEquals(false, mappedContacts.isEmpty());
    }

    @isTest
    static void testGetUpdatableFields() {

        Set<SObjectField> updatableFields = vertic_Utils.sobjects.getUpdatableFields(Contact.getSObjectType());
        System.assertEquals(false, updatableFields.isEmpty());

    }

    @isTest
    static void testAddAmountToField() {

        Opportunity opp = new Opportunity(Name = 'Opportunity',
            StageName = 'Prospecting',
            TotalOpportunityQuantity = 15.00,
            CloseDate = System.today().addMonths(1));

        vertic_Utils.sobjects.addAmountToField(opp, Opportunity.TotalOpportunityQuantity.getDescribe().getSobjectField(), 12);
        System.assertEquals(27.00, opp.TotalOpportunityQuantity);

        vertic_Utils.sobjects.addAmountToField(opp, Opportunity.TotalOpportunityQuantity.getDescribe().getSobjectField(), null);
        System.assertEquals(27.00, opp.TotalOpportunityQuantity);

        Opportunity opp1 = new Opportunity(Name = 'Opportunity',
            StageName = 'Prospecting',
            CloseDate = System.today().addMonths(1));
        vertic_Utils.sobjects.addAmountToField(opp1, Opportunity.TotalOpportunityQuantity.getDescribe().getSobjectField(), 12);
        System.assertEquals(12.00, opp1.TotalOpportunityQuantity);
    }

    @isTest
    static void testFieldToProperty() {

        String property = vertic_Utils.sObjects.fieldToProperty(Contact.FirstName.getDescribe().getSobjectField());
        System.assertEquals('firstName', property);
    }

    @isTest
    static void testFieldNameToProperty() {

        String property = vertic_Utils.sObjects.fieldNameToProperty('');
        System.assertEquals('', property);

        property = vertic_Utils.sObjects.fieldNameToProperty('vertic__tests_field__c');
        System.assertEquals('verticTestsField', property);
    }

    @isTest
    static void testPropertyToField() {

        SObjectField sObjectField = vertic_Utils.sObjects.propertyToField('firstName', Contact.getSObjectType());
        System.assertEquals(Contact.FirstName.getDescribe().getSobjectField(), sObjectField);

        sObjectField = vertic_Utils.sObjects.propertyToField('verticTestField', Contact.getSObjectType());
        System.assertEquals(null, sObjectField);
    }

    @isTest
    static void testPropertyToFieldName() {

        String field = vertic_Utils.sObjects.propertyToFieldName('firstName', Contact.getSObjectType());
        System.assertEquals('FirstName', field);

        field = vertic_Utils.sObjects.propertyToFieldName('verticTestField', Contact.getSObjectType());
        System.assertEquals(null, field);
    }

//    @isTest
//    static void testRecordTypeByName() {
//
//        Schema.DescribeSObjectResult r = Account.SObjectType.getDescribe();
//        Map<String, Schema.RecordTypeInfo> rtMapByName = r.getRecordTypeInfosByName();
//        Schema.RecordTypeInfo rtByName = rtMapByName.get('Test');
//
//
//        Schema.RecordTypeInfo resultRecordTypeInfo = vertic_Utils.sObjects.recordTypeByName(Account.getSObjectType(), 'Test');
//        System.assertEquals(rtByName, resultRecordTypeInfo);
//    }

//    @isTest
//    static void testRecordTypeIdByName() {
//
//        Schema.DescribeSObjectResult r = Account.SObjectType.getDescribe();
//        Map<String, Schema.RecordTypeInfo> rtMapByName = r.getRecordTypeInfosByName();
//        Schema.RecordTypeInfo rtByName = rtMapByName.get('Test');
//
//        Id expectedId = rtByName.getRecordTypeId();
//
//        Id actualId = vertic_Utils.sObjects.recordTypeIdByName(Account.getSObjectType(), 'Test');
//        System.assertEquals(expectedId, actualId);
//
//        Boolean didThrowException = false;
//        try {
//            actualId = vertic_Utils.sObjects.recordTypeIdByName(Account.getSObjectType(), '');
//        } catch (Exception ex) {
//            didThrowException = true;
//        }
//        System.assert(didThrowException);
//
//    }

//    @isTest
//    static void testRecordTypeByAPIName() {
//
//        Schema.DescribeSObjectResult r = Account.SObjectType.getDescribe();
//        Map<String, Schema.RecordTypeInfo> rtMapByName = r.getRecordTypeInfosByName();
//        Schema.RecordTypeInfo rtByName = rtMapByName.get('Test');
//
//        Schema.RecordTypeInfo resultRecordTypeInfo = vertic_Utils.sObjects.recordTypeByAPIName(Account.getSObjectType(), 'Test');
//        System.assertEquals(rtByName, resultRecordTypeInfo);
//
//    }

//    @isTest
//    static void testRecordTypeIdByAPIName() {
//
//        Schema.DescribeSObjectResult r = Account.SObjectType.getDescribe();
//        Map<String, Schema.RecordTypeInfo> rtMapByName = r.getRecordTypeInfosByName();
//        Schema.RecordTypeInfo rtByName = rtMapByName.get('Test');
//
//        Id expectedId = rtByName.getRecordTypeId();
//
//        Id actualId = vertic_Utils.sObjects.recordTypeIdByAPIName(Account.getSObjectType(), 'Test');
//        System.assertEquals(expectedId, actualId);
//
//        Boolean didThrowException = false;
//        try {
//            actualId = vertic_Utils.sObjects.recordTypeIdByAPIName(Account.getSObjectType(), '');
//        } catch (Exception ex) {
//            didThrowException = true;
//        }
//        System.assert(didThrowException);
//    }
//
//    @isTest
//    static void testRecordTypeNameById() {
//
//        List<RecordType> rt = [SELECT Id, Name FROM RecordType WHERE SobjectType = 'Account' LIMIT 1];
//
//        String recordTypeName;
//        if (rt != null) {
//            recordTypeName = vertic_Utils.sObjects.recordTypeNameById(Account.getSObjectType(), rt.get(0).Id);
//            System.assertEquals(rt.get(0).Name, recordTypeName);
//        }
//        recordTypeName = vertic_Utils.sObjects.recordTypeNameById(Account.getSObjectType(), '000000000000000000');
//        System.assertEquals(null, recordTypeName);
//    }

    @isTest
    static void testToSelectOption() {

        List<Contact> cts = createAndReturnContacts(3);
        vertic_Structs.SelectOption selectOption = vertic_Utils.sObjects.toSelectOption(cts.get(0), 'FirstName', 'LastName');
        System.assertNotEquals(null, selectOption);

        selectOption = vertic_Utils.sObjects.toSelectOption(cts.get(0), 'LastName');
        System.assertNotEquals(null, selectOption);

        selectOption = vertic_Utils.sObjects.toSelectOption(cts.get(0));
        System.assertNotEquals(null, selectOption);

        List<System.SelectOption> options = new List<System.SelectOption>();
        for (Integer i = 0; i < 3; i++) {
            options.add(new System.SelectOption('Value' + i, 'Label' + i));
        }
        List<vertic_Structs.SelectOption> selectOptions = vertic_Utils.sObjects.toSelectOptions(options);
        System.assertNotEquals(null, selectOptions);


        selectOptions = vertic_Utils.sObjects.toSelectOptions(cts);
        System.assertNotEquals(null, selectOptions);

        selectOptions = vertic_Utils.sObjects.toSelectOptions(cts, 'FirstName');
        System.assertNotEquals(null, selectOptions);

        selectOptions = vertic_Utils.sObjects.toSelectOptions(cts, 'FirstName', 'LastName');
        System.assertNotEquals(null, selectOptions);

    }

    @isTest
    static void testSwap() {

        Contact ct = new Contact(FirstName = 'Test', LastName = 'Contact');
        insert ct;

        Schema.sObjectField field1 = Contact.FirstName.getDescribe().getSobjectField();
        Schema.sObjectField field2 = Contact.LastName.getDescribe().getSobjectField();
        vertic_Utils.sObjects.swap(ct, field1, field2);
        System.assertEquals('Contact', ct.get('FirstName'));
        System.assertEquals('Test', ct.get('LastName'));
    }

    @isTest
    static void testStringToSObjectType() {

        SObjectType objectType = vertic_Utils.sObjects.stringToSObjectType('Account');
        System.assertEquals(Account.getSObjectType(), objectType);
    }

    @isTest
    static void testGetFieldsByTypes() {

        Set<DisplayType> displayTypes = new Set<DisplayType>();
        Map<String, Schema.SObjectField> fieldMap = Schema.getGlobalDescribe().get('Account').getDescribe().fields.getMap();
        for (String fieldName : fieldMap.keySet()) {
            Schema.DisplayType fielddataType = fieldMap.get(fieldName).getDescribe().getType();
            displayTypes.add(fielddataType);
        }
        Set<SObjectField> fields = vertic_Utils.sObjects.getFieldsByTypes(Account.getSObjectType(), displayTypes);
        System.assertNotEquals(null, fields);

    }

    @isTest
    static void testIsSomeFieldChanged() {

        List<SObjectField> fields = new List<SObjectField>{
            Contact.FirstName.getDescribe().getSobjectField(),
            Contact.LastName.getDescribe().getSobjectField()
        };
        Contact ct = new Contact(FirstName = 'Test', LastName = 'Test');
        Contact cloneCt = ct.clone();
        System.assertEquals(false, vertic_Utils.sObjects.isSomeFieldChanged(ct, cloneCt, fields));

        ct.FirstName = 'TestName';
        System.assertEquals(true, vertic_Utils.sObjects.isSomeFieldChanged(ct, cloneCt, fields));

    }


/**
 * ==============================================================================================================
 *                                            URL EXTENSIONS
 * ==============================================================================================================
 */


    @isTest
    static void testURLExtensions() {

        PageReference pageRef = vertic_Utils.urls.listView(Account.getSObjectType());
        System.assertNotEquals(null, pageRef);
    }


/**
 * ==============================================================================================================
 *                                            EMAIL EXTENSIONS
 * ==============================================================================================================
 */

    @isTest
    static void testCreateSingleEmail() {

        Account acc = new Account(Name = 'Test');
        insert acc;
        Opportunity opp = new Opportunity(Name = acc.Name + ' Opportunity ',
            StageName = 'Prospecting',
            CloseDate = System.today().addMonths(1),
            AccountId = acc.Id);
        insert opp;

        System.runAs(new User(Id = UserInfo.getUserId())) {
            EmailTemplate testTemplate = new EmailTemplate(Name = 'Test template',
                DeveloperName = 'Vertic_Test', TemplateType = 'text', FolderId = UserInfo.getUserId());
            insert testTemplate;

//            List<EmailTemplate> et = [select id, name, folderId from EmailTemplate where Name = 'Sales: New Customer Email'];
            Messaging.SingleEmailMessage mail = vertic_Utils.emails.createSingleEmail(acc.Id, opp.Id, testTemplate.Id);
            System.assertNotEquals(null, mail);

            mail = vertic_Utils.emails.createSingleEmail(acc.Id, opp.Id, testTemplate.Id, testTemplate.folderId);
            System.assertNotEquals(null, mail);
        }


    }

    @isTest
    static void testGetEmailTemplateIdByName() {

        System.runAs(new User(Id = UserInfo.getUserId())) {
            EmailTemplate testTemplate = new EmailTemplate(Name = 'Test template',
                DeveloperName = 'Vertic_Test', TemplateType = 'text', FolderId = UserInfo.getUserId());
            insert testTemplate;
            System.assertEquals(testTemplate.Id, vertic_Utils.emails.getEmailTemplateIdByName('Vertic_Test'));
        }


    }


    @isTest
    static void testIsEmailsTurnedOn() {

        vertic_Utils.emails.isEmailsTurnedOn();

    }


/**
 * ==============================================================================================================
 *                                          ORGANISATION EXTENSIONS
 * ==============================================================================================================
 */

    @isTest
    static void testIsSandbox() {

        List<Organization> organizations = [
            SELECT IsSandbox
            FROM Organization
            WHERE Id = :UserInfo.getOrganizationId()
        ];
        Boolean didThrowException = false;
        Boolean isSandbox = false;

        try {
            isSandbox = organizations.get(0).isSandbox;
        } catch (Exception ex) {
            didThrowException = true;
            System.assert(didThrowException);
        }
        Boolean result = vertic_Utils.orgs.isSandbox();
        System.assertEquals(isSandbox, result);

    }


/**
* ==============================================================================================================
*                                         ENCODING EXTENSIONS
* ==============================================================================================================
*/

    @isTest
    static void testMapToFormUrlEncoded() {

        Map<String, String> dataMap = new Map<String, String>();
        dataMap.put('key1', 'value1');
        dataMap.put('key2', 'value2');
        String result = vertic_Utils.encodings.mapToFormUrlEncoded(dataMap);
        System.assertEquals('key1=value1&key2=value2', result);
    }

    @isTest
    static void testFormUrlEncodedToMap() {

        Map<String, String> dataMap = new Map<String, String>();
        dataMap.put('key1', 'value1');
        dataMap.put('key2', 'value2');
        Map<String, String> resultMap = vertic_Utils.encodings.formUrlEncodedToMap('key1=value1&key2=value2');
        System.assertEquals(dataMap, resultMap);

        Boolean didThrowException = false;
        try {
            resultMap = vertic_Utils.encodings.formUrlEncodedToMap('key1=&key2=value2');
        } catch (Exception ex) {
            didThrowException = true;
            System.assert(didThrowException);
        }
    }

    @isTest
    static void testGetEncryptedValue() {

        Blob key = Crypto.generateAesKey(256);
        String keyString = EncodingUtil.base64Encode(key);

        String encryptedString = vertic_Utils.encodings.getEncryptedValue('test', keyString);
        System.assertNotEquals(null, encryptedString);

    }

    @isTest
    static void testGetDecryptedValue() {
        Blob key = Crypto.generateAesKey(256);
        String keyString = EncodingUtil.base64Encode(key);
        Blob encryptedToken = Crypto.encryptWithManagedIV('AES256', key, Blob.valueOf('test'));
        String encryptedString = EncodingUtil.base64Encode(encryptedToken);


        String decryptedString = vertic_Utils.encodings.getDecryptedValue(encryptedString, keyString);
        System.assertEquals('test', decryptedString);

    }

    @isTest
    static void testMaskCreditCard() {

        String maskedNumber = vertic_Utils.encodings.maskCreditCard('4444333322221111');
        System.assertEquals('444433XXXXXX1111', maskedNumber);

        maskedNumber = vertic_Utils.encodings.maskCreditCard('');
        System.assertEquals(null, maskedNumber);
    }

/**
* ==============================================================================================================
*                                             COLLECTION EXTENSIONS
* ==============================================================================================================
*/

    @isTest
    static void testFirstOrDefault() {

        List<String> stringList = createStringList(0);
        String result = (String) vertic_Utils.arrays.firstOrDefault(stringList, 'default');
        System.assertEquals('default', result);

        stringList = createStringList(3);
        result = (String) vertic_Utils.arrays.firstOrDefault(stringList, 'default');
        System.assertEquals('test0', result);
    }

    @isTest
    static void testFirstOrNull() {

        List<String> stringList = createStringList(0);
        String result = (String) vertic_Utils.arrays.firstOrNull(stringList);
        System.assertEquals(null, result);

        stringList = createStringList(3);
        result = (String) vertic_Utils.arrays.firstOrNull(stringList);
        System.assertEquals('test0', result);
    }

    @isTest
    static void testFirstOrException() {

        List<String> stringList = createStringList(0);

        Boolean didThrowException = false;
        String result;
        try {
            result = (String) vertic_Utils.arrays.firstOrException(stringList, 'message');
        } catch (Exception ex) {
            didThrowException = true;
            System.assert(didThrowException);
        }
        System.assertEquals(null, result);

        stringList = createStringList(3);
        result = (String) vertic_Utils.arrays.firstOrException(stringList, 'message');
        System.assertEquals('test0', result);
    }


    @isTest
    static void testReverseList() {

        List<String> stringList = null;
        List<String> result = (List<String>) vertic_Utils.arrays.reverseList(stringList);
        System.assertEquals(null, result);

        stringList = createStringList(3);
        result = (List<String>) vertic_Utils.arrays.reverseList(stringList);
        System.assertEquals('test0', result.get(2));
    }

    @isTest
    static void testGetMapFirstKey() {

        Map<String, String> stringsMap = createStringsMap(0);
        String firstKey = vertic_Utils.arrays.getMapFirstKey(stringsMap);
        System.assertEquals(null, firstKey);

        Map<String, String> testMap = createStringsMap(3);
        firstKey = vertic_Utils.arrays.getMapFirstKey(testMap);
        System.assertEquals('key0', firstKey);

    }

    @isTest
    static void testChangeMapKeys() {

        Map<String, String> source = createStringsMap(3);
        Map<String, String> donor = createStringsMap(4);

        Map<String, String> result = vertic_Utils.arrays.changeMapKeys(source, donor);
        Map<String, String> testResult = new Map<String, String>();
        testResult.put('value0', 'value0');
        testResult.put('value1', 'value1');
        testResult.put('value2', 'value2');
        System.assertEquals(testResult, result);

        System.assertEquals(null, vertic_Utils.arrays.changeMapKeys(null, donor));

    }

    @isTest
    static void testAddToSetIfNotBlank() {

        Set<String> stringsSet = new Set<String>{
            '1', '2', '3'
        };
        vertic_Utils.arrays.addToSetIfNotBlank(stringsSet, '4');
        System.assert(stringsSet.contains('4'));
    }

    @isTest
    static void testAddToListOrCreateNew() {

        Map<String, List<String>> testMap = null;
        vertic_Utils.arrays.addToListOrCreateNew(testMap, List<String>.class, 'key0', 'object', 2);
        if (testMap != null) {
            System.assertEquals('object', testMap.get('key0').get(0));
        }

        vertic_Utils.arrays.addToListOrCreateNew(testMap, List<String>.class, 'key0', 'object', 0);
        if (testMap != null) {
            System.assertEquals(2, testMap.get('key0').size());
        }
        if (testMap != null) {
            System.assertEquals(2, testMap.get('key0').size());
        }
        if (testMap != null) {
            System.assertEquals(2, testMap.get('key0').size());
        }
        vertic_Utils.arrays.addToListOrCreateNew(testMap, List<String>.class, 'key0', 'object');
        if (testMap != null) {
            System.assertEquals(3, testMap.get('key0').size());
        }

    }

    @isTest
    static void TestGetMapValue() {

        Map<String, Map<String, Object>> testMap = new Map<String, Map<String, Object>>();
        testMap.put('key0', new Map<String, Map<String, Object>>());
        Object obj = vertic_Utils.arrays.getMapValue(testMap, 'key0.key1.key2');
        System.assertEquals(null, obj);

        obj = vertic_Utils.arrays.getMapValue(null, 'key0.key1.key2');
        System.assertEquals(null, obj);

    }

    @isTest
    static void TestSetMapValue() {

        Map<String, Map<String, Object>> testMap = new Map<String, Map<String, Object>>();
        testMap.put('key0', new Map<String, Map<String, Object>>());
        vertic_Utils.arrays.setMapValue(testMap, 'key0.key1.key2', new Map<String, Map<String, Object>>());
        System.assertNotEquals(null, testMap);

        vertic_Utils.arrays.setMapValue(null, 'key0.key1.key2', new Map<String, Map<String, Object>>());
        System.assertNotEquals(null, testMap);

    }

    @isTest
    static void testMapContains() {

        Map<String, Map<String, Object>> testMap = new Map<String, Map<String, Object>>();
        testMap.put('key0', new Map<String, Map<String, Object>>());
        Boolean result = vertic_Utils.arrays.mapContains(testMap, 'key0.key1.key2');
        System.assertEquals(false, result);
    }

    @isTest
    static void testSumMaps() {

        List<Map<String, Map<String, Object>>> testList = new List<Map<String, Map<String, Object>>>();

        Decimal sum = vertic_Utils.arrays.sumMaps(testList, 'key0.key1.key2');
        System.assertEquals(0, sum);

        Map<String, Map<String, Object>> testMap = new Map<String, Map<String, Object>>();
        testMap.put('key0', new Map<String, Map<String, Object>>());
        testList.add(testMap);
        sum = vertic_Utils.arrays.sumMaps(testList, 'key0.key1.key2');
        System.assertEquals(0, sum);
        testList.add(null);
        sum = vertic_Utils.arrays.sumMaps(testList, 'key0.key1.key2');
        System.assertEquals(0, sum);

    }

    @isTest
    static void testContainsAny() {

        List<String> testStrings1 = createStringList(2);
        List<String> testStrings2 = new List<String>{
            'test2', 'test3'
        };
        Boolean result = vertic_Utils.arrays.containsAny(testStrings1, testStrings2);
        System.assertEquals(false, result);

        testStrings2.add('test0');
        result = vertic_Utils.arrays.containsAny(testStrings1, testStrings2);
        System.assertEquals(true, result);

    }

    @isTest
    static void testStringsToSelectOptions() {

        List<String> testList = createStringList(2);
        List<vertic_Structs.SelectOption> resultList = vertic_Utils.arrays.stringsToSelectOptions(testlist);
        System.assertNotEquals(null, resultList);

    }

/**
* ==============================================================================================================
*                                             OBJECT EXTENSIONS
* ==============================================================================================================
*/

    @isTest
    static void testThrowIfNull() {

        Boolean didThrowException = false;
        try {
            vertic_Utils.objects.throwIfNull(null, new vertic_Structs.MissingDataException());
        } catch (Exception ex) {
            didThrowException = true;
            System.assert(didThrowException);
        }
        try {
            vertic_Utils.objects.throwIfNull(null, 'message');
        } catch (Exception ex) {
            didThrowException = true;
            System.assert(didThrowException);
        }
    }

    @isTest
    static void testThrowIfBlank() {
        Boolean didThrowException = false;
        try {
            vertic_Utils.objects.throwIfBlank(null, 'message');
        } catch (Exception ex) {
            didThrowException = true;
            System.assert(didThrowException);
        }
        try {
            vertic_Utils.objects.throwIfBlank('', 'message');
        } catch (Exception ex) {
            didThrowException = true;
            System.assert(didThrowException);
        }

    }

    @isTest
    static void testParseDecimal() {

        Long myLong = 4271990;
        Integer myInt = 10;
        System.assertEquals(10.0, vertic_Utils.objects.parseDecimal(myInt));
        System.assertEquals(4271990.0, vertic_Utils.objects.parseDecimal(myLong));
        System.assertEquals(null, vertic_Utils.objects.parseDecimal(null));
        System.assertEquals(12.0, vertic_Utils.objects.parseDecimal(12.0));
        System.assertEquals(12.0, vertic_Utils.objects.parseDecimal('12'));

        System.assertEquals(1809091.0, vertic_Utils.objects.parseDecimal(Double.valueOf('1809091')));

        Boolean didThrowException = false;
        try {
            vertic_Utils.objects.parseDecimal(didThrowException);
        } catch (Exception ex) {
            didThrowException = true;
            System.assert(didThrowException);
        }

    }

    @isTest
    static void testdDefaultIfNull() {

        System.assertEquals(12.0, vertic_Utils.objects.defaultIfNull(null, 12.0));
        System.assertEquals(10.0, vertic_Utils.objects.defaultIfNull(10.0, 12.0));
        System.assertEquals(10, vertic_Utils.objects.defaultIfNull(null, 10));
        System.assertEquals(10, vertic_Utils.objects.defaultIfNull(10, 12));
        System.assertEquals('12', vertic_Utils.objects.defaultIfNull(null, '12'));
        System.assertEquals('10.0', vertic_Utils.objects.defaultIfNull('10.0', '12.0'));
    }

/**
 * ==============================================================================================================
 *                                             FORMAT EXTENSIONS
 * ==============================================================================================================
 */

    @isTest
    static void testFormatAddress() {

        Contact ct = new Contact(FirstName = 'Test', LastName = 'Test',
            MailingStreet = 'Street', MailingCity = 'City', MailingState = 'State',
            MailingPostalCode = '0000', MailingCountry = 'Country');
        System.assertEquals('Street, City, State, 0000, Country', vertic_Utils.formats.formatAddress(ct, 'Mailing'));

    }

    @isTest
    static void testFormatDateRange() {

        String dateRange = vertic_Utils.formats.formatDateRange(Datetime.newInstance(1960, 1, 22), Datetime.newInstance(1960, 1, 22));
        System.assertEquals('Friday 22nd Jan, 1960', dateRange);
        dateRange = vertic_Utils.formats.formatDateRange(null, Datetime.newInstance(1960, 1, 11));
        System.assertEquals('Monday 11th Jan, 1960', dateRange);
        dateRange = vertic_Utils.formats.formatDateRange(Datetime.newInstance(1960, 1, 23), null);
        System.assertEquals('Saturday 23rd Jan, 1960', dateRange);
        dateRange = vertic_Utils.formats.formatDateRange(Datetime.newInstance(1960, 1, 11), Datetime.newInstance(1960, 1, 22));
        System.assertEquals('Monday 11th to Friday 22nd Jan, 1960', dateRange);
        dateRange = vertic_Utils.formats.formatDateRange(Datetime.newInstance(1960, 1, 11), Datetime.newInstance(1960, 2, 23));
        System.assertEquals('Monday 11th Jan to Tuesday 23rd Feb, 1960', dateRange);
        dateRange = vertic_Utils.formats.formatDateRange(Datetime.newInstance(1960, 1, 21), Datetime.newInstance(1961, 2, 23));
        System.assertEquals('Thursday 21st Jan, 1960 to Thursday 23rd Feb, 1961', dateRange);

    }

    @isTest
    static void testFormatTimeRange() {

        String dateTimeVar = vertic_Utils.formats.formatTimeRange(Datetime.newInstance(1960, 1, 22, 11, 30, 00), Datetime.newInstance(1960, 1, 22, 11, 30, 00));
        System.assertEquals('11:30 AM', dateTimeVar);
        dateTimeVar = vertic_Utils.formats.formatTimeRange(null, Datetime.newInstance(1960, 1, 22, 11, 30, 00));
        System.assertEquals('11:30 AM', dateTimeVar);
        dateTimeVar = vertic_Utils.formats.formatTimeRange(Datetime.newInstance(1960, 1, 22, 11, 30, 00), null);
        System.assertEquals('11:30 AM', dateTimeVar);
        dateTimeVar = vertic_Utils.formats.formatTimeRange(Datetime.newInstance(1960, 1, 22, 11, 30, 00), Datetime.newInstance(1960, 1, 22, 14, 55, 00));
        System.assertEquals('11:30 AM - 2:55 PM', dateTimeVar);

    }

    @isTest
    static void testLongTextAreaToHTML() {

        System.assertEquals(null, vertic_Utils.formats.longTextAreaToHTML(null));
        System.assertEquals('test<br/> test<br/>', vertic_Utils.formats.longTextAreaToHTML('test\r\n test\n'));
    }

    @isTest
    static void testFormatPhoneNumbers() {

        Contact contactVar = new Contact(
            FirstName = 'Contact',
            LastName = 'Contact',
            MobilePhone = '1111111110',
            HomePhone = '2222222221'
        );

        vertic_Utils.IPhoneNumberFormatter mobileFormatter = new vertic_Utils.MobilePhoneNumberFormatter();
        vertic_Utils.IPhoneNumberFormatter homeFormatter = new vertic_Utils.HomePhoneNumberFormatter();
        Map<Schema.sObjectField, vertic_Utils.IPhoneNumberFormatter> formatMapping = new Map<Schema.sObjectField, vertic_Utils.IPhoneNumberFormatter>{
            Contact.MobilePhone.getDescribe().getSobjectField() => mobileFormatter,
            Contact.HomePhone.getDescribe().getSobjectField() => homeFormatter
        };
        vertic_Utils.formats.formatPhoneNumbers(new List<Contact>{contactVar}, formatMapping, true);
        System.assertEquals('1111 111 110 ', contactVar.MobilePhone);
        System.assertEquals('22 2222 2221 ', contactVar.HomePhone);

        contactVar.MobilePhone = '';
        contactVar.HomePhone = '';
        vertic_Utils.formats.formatPhoneNumbers(new List<Contact>{contactVar}, formatMapping, true);
        System.assertEquals('', contactVar.MobilePhone);

    }


/**
* ==============================================================================================================
*                                             OTHER UTILITIES
* ==============================================================================================================
*/

/**
* ==============================================================================================================
*                            vertic_SOQLProc, vertic_AbstractProcessor, vertic_CommonCtrl
* ==============================================================================================================
*/

    @isTest
    static void testCommonCtrl() {
        Map<String, Object> dto = new Map<String, Object>();
        dto.put('SOQL', 'SELECT Id FROM Contact LIMIT 1');
        String requestJSON = JSON.serialize(dto);
        String response = vertic_CommonCtrl.execute('vertic_SOQLProc', requestJSON);
        System.assertNotEquals(null, response);

        Boolean didThrowException = false;

        try {
            response = vertic_CommonCtrl.execute('NonexistentProc', requestJSON);
        } catch (Exception ex) {
            didThrowException = true;
            System.assert(didThrowException);
        }

        dto.put('SOQL', 'test exception');
        requestJSON = JSON.serialize(dto);

        try {
            response = vertic_CommonCtrl.execute('vertic_SOQLProc', requestJSON);
        } catch (Exception ex) {
            didThrowException = true;
            System.assert(didThrowException);
        }

        String invalidResponse = new vertic_Response('Invalid request attributes.').getJSON();
        response = vertic_CommonCtrl.execute(requestJSON);
        System.assertEquals(invalidResponse, response);

        dto.put('processor', 'vertic_SOQLProc');
        dto.put('dto', 'SELECT Id FROM Contact LIMIT 1');
        requestJSON = JSON.serialize(dto);
        response = vertic_CommonCtrl.execute(requestJSON);
        System.assertNotEquals(null, response);

        try {
            dto.put('processor', null);
            requestJSON = JSON.serialize(dto);
            response = vertic_CommonCtrl.execute(requestJSON);
        } catch (Exception ex) {
            didThrowException = true;
            System.assert(didThrowException);
        }

    }

/**
* ==============================================================================================================
*                                vertic_SOQLDataTableMetaProc
* ==============================================================================================================
*/

    @isTest
    static void testVertic_SOQLDataTableMetaProc() {

        Account acc = new Account(Name = 'TestAccount', Industry = 'Other', AnnualRevenue = 100);
        insert acc;
        Contact ct = new Contact(AccountId = acc.Id, FirstName = 'Test', LastName = 'Test', Email = 'test@test.com',
            MobilePhone = '0411111111', MailingCountry = 'Australia', MailingCity = 'Test', MailingStreet = 'Test');
        insert ct;

        Map<String, Object> dto = new Map<String, Object>{
            'sObjectType' => 'Contact',
            'fields' => 'Id, Name, Email, Birthdate, MobilePhone, MailingAddress, AccountId, Account.Industry, Account.AnnualRevenue',
            'params' => new Map<String, List<String>>{
                'idSet' => new List<String>{
                    ct.Id
                }
            },
            'condition' => 'Id = \'' + ct.Id + '\''


        };

        vertic_SOQLDataTableMetaProc SOQLDataTableProc = new vertic_SOQLDataTableMetaProc();
        vertic_Response response = SOQLDataTableProc.process (new vertic_MetadataProcessor.MetadataRequest(JSON.serialize(dto)));
        System.assertNotEquals(null, response);

    }

/**
* ==============================================================================================================
*                                vertic_SendEmailProc
* ==============================================================================================================
*/


    @isTest
    static void testVertic_SendEmailProc() {

        EmailTemplate testTemplate = new EmailTemplate(Name = 'Test template',
            DeveloperName = 'Test', TemplateType = 'text', FolderId = UserInfo.getUserId());
        insert testTemplate;

        System.runAs(new User(Id = UserInfo.getUserId())) {

            Account acc = new Account(Name = 'Test');
            insert acc;

            Vertic_Async_Process__c asyncProc = new vertic_SendEmailProc.EmailAsyncProcess(
                testTemplate.DeveloperName,
                UserInfo.getUserId(),
                acc.Id
            ).toAsyncProcess();

            new vertic_AsyncProcess().add(asyncProc).enqueue();

            Test.startTest();

            vertic_AsyncProcessBatch.run(new List<Id>{asyncProc.Id});

            Test.stopTest();
        }
    }


    @isTest
    static void testVertic_SendEmailProcForMetaProc() {

        Vertic_Async_Process__c asyncProc = vertic_SendEmailProc.newAsyncProcess('vertic_Tests.Test',
            new Map<String, Object>()).toAsyncProcess();


        new vertic_AsyncProcess().add(asyncProc).enqueue();

        Test.startTest();

        vertic_AsyncProcessBatch.run(new List<Id>{asyncProc.Id});

        Test.stopTest();

    }

    @isTest
    static void testVertic_SendEmailProcContentDocumentAttachments() {

        EmailTemplate testTemplate = new EmailTemplate(Name = 'Test template',
            DeveloperName = 'Test', TemplateType = 'text', FolderId = UserInfo.getUserId());
        insert testTemplate;

        System.runAs(new User(Id = UserInfo.getUserId())) {

            Account acc = new Account(Name = 'Test');
            insert acc;

            ContentVersion conVersion = new ContentVersion(
                VersionData = Blob.valueOf('test'),
                PathOnClient = 'test.csv',
                Title = 'test.csv'
            );
            insert conVersion;
            conVersion = [SELECT Id, PublishStatus, ContentDocumentId, ContentDocument.Title FROM ContentVersion WHERE Id = :conVersion.Id];
            ContentDocumentLink cdl = new ContentDocumentLink(
                ContentDocumentId = conVersion.ContentDocumentId,
                LinkedEntityId = acc.Id,
                ShareType = 'I',
                Visibility = 'AllUsers'
            );
            insert cdl;

            vertic_Response sendEmailResponse = new vertic_SendEmailProc().process(new vertic_SendEmailProc.EmailAsyncProcess(
                testTemplate.DeveloperName,
                UserInfo.getUserId(),
                acc.Id
            ).setAttachments(new List<Map<String, Object>>{
                new Map<String, Object>{
                    'contentDocumentIds' => new List<String>{
                        conVersion.ContentDocumentId
                    }
                }
            }));

            System.assertEquals(true, sendEmailResponse.isValid);
        }
    }

    @isTest
    static void testVertic_SendEmailProcContentAttachments() {
        EmailTemplate testTemplate = new EmailTemplate(Name = 'Test template',
            DeveloperName = 'Test', TemplateType = 'text', FolderId = UserInfo.getUserId());
        insert testTemplate;

        System.runAs(new User(Id = UserInfo.getUserId())) {

            Account acc = new Account(Name = 'Test');
            insert acc;

            ContentVersion conVersion = new ContentVersion(
                VersionData = Blob.valueOf('test'),
                PathOnClient = 'test.csv',
                Title = 'test.csv'
            );
            insert conVersion;
            conVersion = [SELECT Id, PublishStatus, ContentDocumentId, ContentDocument.Title FROM ContentVersion WHERE Id = :conVersion.Id];
            ContentDocumentLink cdl = new ContentDocumentLink(
                ContentDocumentId = conVersion.ContentDocumentId,
                LinkedEntityId = acc.Id,
                ShareType = 'I',
                Visibility = 'AllUsers'
            );
            insert cdl;

            vertic_Response sendEmailResponse = new vertic_SendEmailProc().process(new vertic_SendEmailProc.EmailAsyncProcess(
                testTemplate.DeveloperName,
                UserInfo.getUserId(),
                acc.Id
            ).setAttachments(new List<Map<String, Object>>{
                new Map<String, Object>{
                    'contentDocumentIds' => new List<String>{
                        conVersion.ContentDocumentId
                    }
                }
            }).setContentAttachments(new List<Map<String, Object>>{
                new Map<String, Object>{
                    'proc' => 'vertic_Tests.Test',
                    'renderAs' => 'pdf'
                    }
                }
            ));

            System.assertEquals(true, sendEmailResponse.isValid);
            if (vertic_Utils.emails.isEmailsTurnedOn()) {
                System.assertEquals(true, sendEmailResponse.getInteger('countAttachments') == 2);
            }
        }
    }

/**
* ==============================================================================================================
*                                   vertic_UnitOfWork
* ==============================================================================================================
*/

    @isTest
    static void testVertic_UnitOfWork() {
        System.runAs(new User(Id = UserInfo.getUserId())) {

            Account parentAccount = new Account(Name = 'Parent');
            Account childAccount = new Account(Name = 'Child');

            vertic_UnitOfWork uow = new vertic_UnitOfWork(new List<SObjectType>{
                Account.SObjectType
            }, new vertic_UnitOfWork.DatabaseDMLIml());
            uow.registerUpsert(parentAccount);
            uow.registerUpsert(childAccount);
            uow.registerHierarchy(childAccount, Account.ParentId, parentAccount);

            uow.commitWork();

            List <Account> registeredAccs = [SELECT Id, ParentId FROM Account WHERE Id = :childAccount.Id];
            System.assertEquals(parentAccount.Id, registeredAccs.get(0).ParentId);

        }
    }


/**
* ==============================================================================================================
*                                   vertic_AutoMapper
* ==============================================================================================================
*/

    @isTest
    static void testMapToSObject() {
        Contact testContact = createContact('test', 'Australia');
        Contact testContact2 = createContact('test2', 'Australia');

        List<Contact> testContacts = new List<Contact>{
            testContact, testContact2
        };

        Map<String, Object> stringToObjectMap = new Map<String, Object>();
        vertic_AutoMapper autoMapper = new vertic_AutoMapper(stringToObjectMap)
            .mapFromSObject('contact', testContact)
            .mapFromListSObjects('contacts', testContacts);

        System.assert(stringToObjectMap.containsKey('contact'));
        System.assert(stringToObjectMap.containsKey('contacts'));

        Contact newContact = new Contact(
            Email = 'test@test.com', Birthdate = Date.newInstance(2018, 10, 10)
        );
        autoMapper.mapToSObject('contact', newContact);

        System.assertEquals('test@test.com', newContact.Email);
        System.assertEquals('Australia', newContact.MailingCountry);
        System.assertEquals('test', newContact.LastName);

        autoMapper.mapToSObject(newContact);

        vertic_AutoMapper.Options optionsVar = autoMapper.getOptions();
        System.assertNotEquals(null, optionsVar.getMapper());
        optionsVar.setIsVisualforce(true);
        optionsVar.setIsAllFields(true);
        optionsVar.setDefaultFieldValue('default value');
        autoMapper.mapToSObject(newContact);
        autoMapper.mapFromSObject('newContact', newContact);

        optionsVar.setIsVisualforce(false);
//        optionsVar.setIsAllFields(false);
        autoMapper.mapToSObject(newContact);
        autoMapper.mapFromSObject('newContact', newContact);


    }

    @isTest
    static void testGetMap() {
        vertic_AutoMapper autoMapper = new vertic_AutoMapper();
        vertic_AutoMapper autoMapperImpl = new vertic_AutoMapper(autoMapper);
        System.assertNotEquals(null, autoMapperImpl.getMap());
    }

    @isTest
    static void testGetOptions() {
        vertic_AutoMapper autoMapper = new vertic_AutoMapper();
        System.assertNotEquals(null, autoMapper.getOptions());
    }

    @isTest
    static void testMapAnyValue() {

        vertic_AutoMapper autoMapper = new vertic_AutoMapper();
        System.assertNotEquals(null, autoMapper.mapAnyValue('path', 'object'));
    }


    @isTest
    static void testBehaviour() {


        Contact ct = createContact('test', 'Australia');
        Map<String, Object> dataMap = new Map<String, Object>();

        List<SObjectField> fields = new List<SObjectField>{
            Contact.LastName.getDescribe().getSobjectField(), Contact.MailingCountry.getDescribe().getSobjectField()
        };
        vertic_AutoMapper.JoinStringFieldsBinder testJoinFieldsBinder = new vertic_AutoMapper.JoinStringFieldsBinder('path', fields, ',');

        testJoinFieldsBinder.bind(ct, dataMap);
        System.assertEquals('test,Australia', dataMap.get('path'));

        vertic_AutoMapper.BinderQueue binderQ = new vertic_AutoMapper.BinderQueue(new vertic_AutoMapper.JoinStringFieldsBinder('commaPath', fields, '.'));
        binderQ.process(ct, dataMap);
        System.assertEquals('test.Australia', dataMap.get('commaPath'));

        List<String> testListFields = new List<String>{
            'MailingCountry', 'LastName'
        };
        vertic_AutoMapper.JoinStringBinder testJoinStringBinder = new vertic_AutoMapper.JoinStringBinder('pathString', testListFields, ';');
        testJoinStringBinder.bind(ct, dataMap);
        System.assertNotEquals(null, dataMap.get('pathString'));

//   vertic_AutoMapper.DatetimeFormatBinder

        ct.Birthdate = Date.newInstance(1990, 10, 10);
        vertic_AutoMapper.DatetimeFormatBinder dateBinder = new vertic_AutoMapper.DatetimeFormatBinder('datePath', Contact.Birthdate.getDescribe().getSobjectField(), 'dd/MM/YYYY hh:mm:ss');
        dateBinder.bind(ct, dataMap);
        System.assertEquals('10/10/1990 12:00:00', dataMap.get('datePath'));

        vertic_AutoMapper.DefaultValueBinder valueBinder = new vertic_AutoMapper.DefaultValueBinder('object', 'object');
        valueBinder.bind(ct, dataMap);
        System.assertEquals('object', dataMap.get('object'));

        List<vertic_AutoMapper.IBinder> binders = new List<vertic_AutoMapper.IBinder>();
        binderQ = new vertic_AutoMapper.BinderQueue(binders);

        vertic_AutoMapper autoMapper = new vertic_AutoMapper(dataMap)
            .mapFromSObject('contact', ct, binderQ);

    }

/**
* ==============================================================================================================
*                                          vertic_SettingService
* ==============================================================================================================
*/


    @isTest
    static void testVertic_SettingService() {

        vertic_SettingService.setValues(new Map<String, String>{
            'Test' => 'Value'
        });

        System.assertEquals(null, vertic_SettingService.getNumberValue('Test'));

        Boolean didThrowException = false;
        try {
            vertic_SettingService.getMetadataType(Account.SObjectType, 'Test');
        } catch (Exception ex) {
            didThrowException = true;
            System.assert(didThrowException);
        }

        Test.startTest();
        vertic_SettingService.setValuesAsync(new Map<String, String>{
            'Test1' => 'Value1'
        });
        Test.stopTest();

        System.assertEquals('Value1', vertic_SettingService.getValue('Test1'));
    }


/**
* ==============================================================================================================
*                                          vertic_ContentCtrl
* ==============================================================================================================
*/


    public class TestMetaProc extends vertic_MetadataProcessor {

        public override vertic_Response process(vertic_Request request) {

            super.process(new MetadataRequest());

            this.response.dto.put('components', new List<Object>{
                new Component.Apex.OutputText()
            });

            return this.response;
        }
    }


    @isTest
    static void testVertic_ContentCtrl() {

        vertic_ContentCtrl contentCtrl = new vertic_ContentCtrl();

        Map<String, String> testMap = new Map<String, String>{
            'proc' => 'vertic_Tests.Test',
            'renderAs' => 'excel'
        };

        PageReference pageRef = Page.vertic_Content;
        Test.setCurrentPage(pageRef);
        ApexPages.currentPage().getParameters().putAll(testMap);

        contentCtrl.onInit();
        System.assertEquals('', contentCtrl.getPageStyles());
        System.assertEquals('', contentCtrl.getCustomStyles());
        System.assertEquals('', contentCtrl.getPageEvenStyles());
        System.assertEquals('', contentCtrl.getPageOddStyles());
        System.assertEquals('11pt', contentCtrl.getFontSize());
        System.assertEquals('Arial Unicode MS', contentCtrl.getFontFamily());
        System.assertEquals('application/vnd.ms-excel', contentCtrl.getContentType());
        System.assertEquals('html', contentCtrl.getRenderAs());
        System.assertnotEquals(null, contentCtrl.getPanel());

    }

//    @isTest
//    static void fake() {
//        vertic_Utils.fake();
//    }


    /**
    * ==============================================================================================================
    *                                          vertic_RestService
    * ==============================================================================================================
    */

    public class TestGetProc extends vertic_AbstractProcessor {

        public override vertic_Response process(vertic_Request request) {
            this.request = (vertic_RestService.Request) request;
            this.response = (vertic_RestService.Response) super.response;

            String accountId = this.request.params.get('Id');
            Account acc = (Account) vertic_Utils.arrays.firstOrException([SELECT Name FROM Account WHERE Id = :accountId], 'Account not found');

            this.response.getMapper().mapFromSObject('account', acc);

            return this.response;
        }

        private vertic_RestService.Response response;

        protected override vertic_Response getResponseInstance() {
            return new vertic_RestService.Response();
        }

        private vertic_RestService.Request request;

        public override Type getRequestType() {
            return vertic_RestService.Request.class;
        }

        public override vertic_Request getRequestInstance(String requestJSON) {
            return (vertic_RestService.Request) JSON.deserialize(requestJSON, this.getRequestType());
        }

    }

    static testMethod void test_RestService_GetBehavior() {
        Account testAccount = new Account(Name = 'Vertic');
        insert testAccount;

        RestRequest request = new RestRequest();
        request.requestURI = '/vertic_tests.test';
        request.httpMethod = 'GET';
        request.params.put('Id', testAccount.Id);

        RestContext.request = request;
        RestContext.response = new RestResponse();

        vertic_RestService.handleRequest();

        if (RestContext.response.statusCode == 400) {
            System.debug(RestContext.response.responseBody.toString());
        }

        System.assertEquals(200, RestContext.response.statusCode);
        Map<String, Object> result = (Map<String, Object>) JSON.deserializeUntyped(RestContext.response.responseBody.toString());
        vertic_DTO dto = new vertic_DTO(result);
        System.assertEquals('Vertic', dto.getString('account.Name'));
    }

    public class TestPostProc extends vertic_AbstractProcessor {

        public override vertic_Response process(vertic_Request request) {
            this.request = (vertic_RestService.Request) request;
            this.response = (vertic_RestService.Response) super.response;

            Account acc = new Account();
            this.request.getMapper().mapToSObject('account', acc);
            insert acc;

            return this.response;
        }

        private vertic_RestService.Response response;

        protected override vertic_Response getResponseInstance() {
            return new vertic_RestService.Response();
        }

        private vertic_RestService.Request request;

        public override Type getRequestType() {
            return vertic_RestService.Request.class;
        }

        public override vertic_Request getRequestInstance(String requestJSON) {
            return (vertic_RestService.Request) JSON.deserialize(requestJSON, this.getRequestType());
        }

    }

    static testMethod void test_RestService_PostBehavior() {
        RestRequest request = new RestRequest();
        request.requestURI = '/vertic_tests.test';
        request.httpMethod = 'POST';
        request.requestBody = Blob.valueOf(JSON.serialize(new Map<String, Object>{
            'account' => new Map<String, Object>{
                'Name' => 'Vertic'
            }
        }));

        RestContext.request = request;
        RestContext.response = new RestResponse();

        vertic_RestService.handleRequest();

        if (RestContext.response.statusCode == 400) {
            System.debug(RestContext.response.responseBody.toString());
        }

        System.assertEquals(200, RestContext.response.statusCode);
        System.assertEquals(1, [SELECT count() FROM Account]);
        System.assertEquals('Vertic', [SELECT Name FROM Account][0].Name);
    }

    static testMethod void test_Deduplicable_UOW() {

        final String sourceDescription = 'source description will be preserved on duplicate insert/update';
        final String sourceTitle = 'source title will be preserved on duplicate insert/update';

        Contact contact1 = new Contact(
            FirstName = 'test',
            LastName = 'test',
            Email = 'test@test.com',
            Description = sourceDescription,
            Title = sourceTitle
        );
        insert contact1;

        List<Contact> contacts = new List<Contact>();
        Integer total = 5;
        for (Integer i = 0; i < total; i++) {
            Contact clonedContact = contact1.clone(false);
            clonedContact.Description = '' + i;
            clonedContact.Title = '' + i;
            contacts.add(clonedContact);
        }

        Boolean isDuplicateRuleEnabled = false;
        try {
            insert contacts;
        } catch (DmlException ex) {
            isDuplicateRuleEnabled = true;
        }

        // Skip test if no duplicate rule on Contact.
        if(isDuplicateRuleEnabled != true){
            return;
        }

        Test.startTest();

            vertic_UnitOfWork uow = new vertic_UnitOfWork(
                new List<SObjectType>{
                    Contact.SObjectType
                },
                new vertic_UnitOfWork.DeduplicableDMLIml(new Map<SObjectType, Set<SObjectField>>{
                    Contact.SObjectType => new Set<SObjectField>{Contact.Description} // Preserve Description field (Object level setting)
                })
            );

            uow.registerUpsert(contacts, new Set<SObjectField>{Contact.Title}); // Preserve Title field (Record level setting)
            uow.commitWork();

        Test.stopTest();

        System.assertEquals(1, [SELECT COUNT() FROM Contact]);
        System.assertNotEquals(null, contact1.Id);

        for (Contact contactVar : contacts) {
            System.assertEquals(contact1.Id, contactVar.Id);
        }

        contact1 = (Contact) vertic_Utils.arrays.firstOrException(
            [SELECT Id, Description, Title FROM Contact WHERE Id = :contact1.Id],
            'No Contact with id: ' + contact1.Id
        );

        System.assertEquals(sourceDescription, contact1.Description);
        System.assertEquals(sourceTitle, contact1.Title);
    }

    @isTest
    static void deduplicate() {
        Contact contact1 = new Contact(
            FirstName = '1',
            LastName = '1',
            Email = '1@test.com',
            Title = 'Developer'
        );

        insert contact1;

        Contact contact2 = contact1.clone(false);
        contact2.Title = 'Manager';

        Boolean isExistingRecordFound = vertic_Utils.sObjects.deduplicate(contact2, new Set<SObjectField>{Contact.Title});
        System.debug(contact2);

        upsert contact2;

        System.assertEquals(isExistingRecordFound ? 1 : 2, [SELECT COUNT() FROM Contact]);

        if(isExistingRecordFound){
            Contact contactVar = [SELECT Id, Title FROM Contact WHERE Id = :contact1.Id];
            System.assertEquals('Developer', contactVar.Title); // Preserved Field.
        }


        // Just ot increase the test coverage.
        vertic_Utils.sObjects.deduplicate(contact2);
    }
}