public without sharing class RequestDetailTriggerHandler extends TriggerHandler {
    public static Map <Id, Request_Detail__c> newRequestDetailMap;
    public static Map <Id, Request_Detail__c> oldRequestDetailMap;
    public static List <Request_Detail__c> newRequestDetailList;
    public static List <Request_Detail__c> oldRequestDetailList;
    public final static string RT_TSA = 'Trade Spend Authorization';
    public final static string REQUEST_DETAIL_OBJECT = 'Request_Detail__c';
    public String recordTypeName;

    public RequestDetailTriggerHandler() {
        system.debug('***RequestDetailTriggerHandler***');
        newRequestDetailMap =  (map<Id, Request_Detail__c>)trigger.newMap;
        newRequestDetailList = (list<Request_Detail__c>) trigger.new;
        oldRequestDetailMap =  (map<Id,Request_Detail__c>)trigger.oldMap;
        oldRequestDetailList = (list<Request_Detail__c>) trigger.old;
        if (trigger.isDelete)
            recordTypeName = Utility.getRecordTypeName(oldRequestDetailList[0].RecordTypeId, REQUEST_DETAIL_OBJECT);
        else
            recordTypeName = Utility.getRecordTypeName(newRequestDetailList[0].RecordTypeId, REQUEST_DETAIL_OBJECT);
    }

    public override void beforeUpdate() {
        //  Get record type
        system.debug('***beforeUpdate');
        system.debug('RT Name: ' + recordTypeName);
        if (recordTypeName == RT_TSA)
            TSA_beforeUpdate();
    }
    
    public override void afterUpdate() {
        System.debug('***After Update***');
        System.debug('RT Name: ' + recordTypeName);
        if (recordTypeName == RT_TSA) 
            TSA_afterUpdate();
    }
    
    public static void TSA_beforeUpdate() {
 		updateTSABatchStatus();                        
    }
    
    public static void TSA_afterUpdate() {
        updateTSAHeaderStatus();
        rollUpTSAHeaderSAPInfo(newRequestDetailList);
    }
    
    private static void updateTSABatchStatus() {
        for (Request_Detail__c d : newRequestDetailList) {
            if (d.TSA_SAP_Integration_Status__c != oldRequestDetailMap.get(d.Id).TSA_SAP_Integration_Status__c) {
                system.debug('before: ' + d);
                switch on d.TSA_SAP_Integration_Status__c {
                    when 'P','S' {
                        d.Status__c = 'Processing';
                    }
                    when 'E' {
                        d.Status__c = 'Error';
                    }
                    when 'A' {
                        if (d.TSA_SAP_Authorization_Number__c != null && d.TSA_SAP_Authorization_Number__c != '')
                            d.Status__c = 'Accepted';
                        else
                            d.Status__c = 'Rejected';
                    }
                    when 'R' {
                        d.Status__c = 'Rejected';
                    }
                }
                system.debug('after:  ' + d);
            }
        }

    }
    
    private static void updateTSAHeaderStatus() {

        integer batchCount = 0;
        integer acceptCount = 0;
        integer rejectCount = 0;

        //  Get Header record

        List<Request_Detail__c> batchRecordList = [select id, status__c, tsa_sap_integration_status__c, request_header__r.tsa_batch_count__c
                                                    from Request_detail__c
                                                    where request_header__c = : newRequestDetailList[0].request_header__c];

        Request_Header__c headerRecord = [select id, status__c from Request_Header__c
                                        where id =: newRequestDetailList[0].request_header__c
                                        limit 1];

        system.debug('header before:  ' + headerRecord);

        for (Request_Detail__c b : batchRecordList) {
            batchcount++;
            if(newRequestDetailMap.containsKey(b.id)) {
                if (newRequestDetailMap.get(b.id).Status__c == 'Accepted') 
                    acceptCount++;
                else if (newRequestDetailMap.get(b.id).Status__c == 'Rejected')
                    rejectCount++;
            }
            else
                if (b.Status__c == 'Accepted')
                    acceptCount++;
                else if (b.Status__c == 'Rejected')
                    rejectCount++;
        }                                            
        
        if (batchCount == acceptCount)
            headerRecord.Status__c = 'Accepted';
        else if (batchCount == rejectCount)
            headerRecord.Status__c = 'Rejected';
        else if (acceptCount > 0)
            headerRecord.Status__c = 'Partial Acceptance';
        else if (rejectCount > 0)
            headerRecord.Status__c = 'Partial Rejection';

        system.debug('header after:  ' + headerRecord);

        update headerRecord;
    }  
    
    public static void rollUpTSAHeaderSAPInfo(List<Request_Detail__c> requestDetailList) {
        //  Gather list of request header ids
        map<Id, Request_Header__c> updRequestHeaderMap = getUpdRequestHeaderMap(requestDetailList);
 
        //  Roll up Batch's SAP Authorization Number and Error Messages to Header record
        List<request_Detail__c> authRequestDetailList = [select id, request_header__c, TSA_SAP_Authorization_Number__c, TSA_SAP_Error_Message__c
                                                         from Request_Detail__c
                                                         where TSA_SAP_Authorization_Number__c <> null
                                                         and request_header__c in : updRequestHeaderMap.keySet()];

        for (Request_Detail__c d : authRequestDetailList) {
            Request_Header__c h = updRequestHeaderMap.get(d.Request_Header__c);
            system.debug('Auth Number: ' + d.TSA_SAP_Authorization_Number__c);
            if (string.isNotBlank(d.TSA_SAP_Authorization_Number__c)) {
                if (h.TSA_SAP_Authorization_Number__c == '')
                    h.TSA_SAP_Authorization_Number__c += d.TSA_SAP_Authorization_Number__c;
                else
                    h.TSA_SAP_Authorization_Number__c += ';' + d.TSA_SAP_Authorization_Number__c;

                if (h.TSA_SAP_Error_Message__c == '')
                    h.TSA_SAP_Error_Message__c += d.TSA_SAP_Error_Message__c;
                else
                    h.TSA_SAP_Error_Message__c += ';' + d.TSA_SAP_Error_Message__c ;


                updRequestHeaderMap.put(d.Request_Header__c, h);
                system.debug('updRequestHeaderMap: ' + updRequestHeaderMap);
             }
        }

        if (!updRequestHeaderMap.isEmpty()) {
             update updRequestHeaderMap.values();
        }
    }

    public static Map<Id, Request_Header__c> getUpdRequestHeaderMap(List<Request_Detail__c> requestDetailList) {

        Set<Id> requestHeaderIdSet= new Set<Id> ();
        for (Request_Detail__c d : requestDetailList) {
            requestHeaderIdSet.add(d.Request_Header__c);
        }
        Map<Id, Request_Header__c> requestHeaderMap = new Map<Id, Request_Header__c> 
            ([select Id, TSA_SAP_Authorization_Number__c, TSA_SAP_Error_Message__c
            from Request_Header__c
            where id in : requestHeaderIdSet]);

        for (Request_Header__c h : requestHeaderMap.values()) {
            h.TSA_SAP_Authorization_Number__c = '';
            h.TSA_SAP_Error_Message__c = '';
        }

        return requestHeaderMap;
    }
}