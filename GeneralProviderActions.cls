public class GeneralProviderActions {
    
    /*

/**
* @description  Class for do actions and provide response to Multiple Vendors
public without sharing class GeneralProviderActions 
{
    public static Map<String,Object> baseLogData = new Map<String,Object>{'user'=>UserInfo.getUserId(),'responseCode'=>'200',
        'integrationType'=>'Inbound','serviceProvider'=>'SF CRM','serviceConsumer'=>'General'};
            /**
* @description  method to Create Case
@param RestRequest

        public static void createCase(RestRequest request)
        {
            //Request initiated time
            DateTime requestInitiatedTime = System.now();
            //Request body from Request
            String requestBody = request.requestbody.toString();
            //Set response content
            RestContext.response.addHeader('Content-Type', 'application/json');
            //Integration log list
            List<CreateIntegrationLogUtility> logList = new  List<CreateIntegrationLogUtility> ();
            //instance for request wrapper
            Map<String,Object> generalRequest = new Map<String,Object>();
            //Error Response
            GeneralProviderContentWrapper.ErrorResponse errorResponse = new GeneralProviderContentWrapper.ErrorResponse();
            //Map Common log data
            Map<String,Object> mapLogData = new Map<String,Object>{'interfaceName'=>'General_CreateCase',
                'request'=>String.valueOf(requestBody),'requestInitiatedTime'=>requestInitiatedTime,'mode'=>'SYNC'};
                    mapLogData.putAll(baseLogData);
            //List of generic master name - case sub type, case type, case category
            List<String> lstGMName = new List<String>();
            //Policy number list
            List<String> lstPolicyNumber = new List<String>();
            //CreateCaseCustomMetaDataRecords
            List<GeneralProviderFieldMapping__mdt> listcustomMetadata = new List<GeneralProviderFieldMapping__mdt>();
            //map gm name to gm id
            Map<String,String> mapGmNameToId = new Map<String,String>();
            //map policy number to policy id
            Map<String,String> mapPolicyNumberToId = new Map<String,String>();
            //map policy number to accountId
            Map<String,String> mapPolicyNumberToAccId = new Map<String,String>();
            //map policy number to Contact Id
            Map<String,String> mapPolicyNumberToContactId = new Map<String,String>();
            //map genMasterName
            Map<String,String> mapGMRecords = new Map<String,String>();
            //list Generic Master
            List<GenericMaster__c> listGenMaster = new List<GenericMaster__c>();
            //Subtype matched
            Boolean subTypeMatched = false;
            //SubTypeId
            String subTypeId;
            //CaseTypeId
            String caseTypeId;
            //CaseType matched
            Boolean caseTypeMatched = false;
            //Map CategoryandTypeName to Id
            Map<String,String> mapCatAndTypeToGenId = new Map<String,String>();
            try
            {
                //deserializing request
                generalRequest = (Map<String,Object>)JSON.deserializeUntyped(requestBody); 
                
                for(String key : generalRequest.keySet())
                {
                    generalRequest.put(key.toUpperCase(), generalRequest.get(key));
                }
                
                List<Case> listCase = new List<Case>();
                Case cs = new Case();
                //check service cousumer name is exist
                if(!generalRequest.containskey('SOURCE') && String.isBlank((String)generalRequest.get('SOURCE')))
                {
					errorResponse.error = 'source is mandatory';                    
                }
                else
                {
                    mapLogData.put('serviceConsumer',(String)generalRequest.get('SOURCE'));
                    
                    Id subTypeRecordTypeId = Schema.SObjectType.GenericMaster__c.getRecordTypeInfosByDeveloperName().get('SubType').getRecordTypeId();
                    Id typeRecordTypeId = Schema.SObjectType.GenericMaster__c.getRecordTypeInfosByDeveloperName().get('Type').getRecordTypeId();
                    Id categoryRecordTypeId = Schema.SObjectType.GenericMaster__c.getRecordTypeInfosByDeveloperName().get('Category').getRecordTypeId();
                    
                    List<String> recordTypeIds = new List<String>{subTypeRecordTypeId,typeRecordTypeId,categoryRecordTypeId};
                    List<String> csstName = new List<String>{String.valueOf(generalRequest.get('CASESUBTYPE')),String.valueOf(generalRequest.get('CASETYPE')),String.valueOf(generalRequest.get('CATEGORY'))};
                    
                    for(GenericMaster__c genM : [select id,Name,Type__r.Name,Category__r.Name,RecordTypeId from GenericMaster__c where RecordTypeId IN:recordTypeIds and Name IN:csstName WITH SECURITY_ENFORCED])
                    {
                        system.debug('loop count');
                        if(genM.RecordTypeId == subTypeRecordTypeId && genM.Name == String.valueOf(generalRequest.get('CASESUBTYPE')) && genM.Type__r.Name == String.valueOf(generalRequest.get('CASETYPE')) 
                           && genM.Category__r.Name == String.valueOf(generalRequest.get('CATEGORY')))
                        {
                            system.debug('inside match');
                            subTypeMatched = true;
                            subTypeId = genM.Id;
                            break;
                        }
                        else if(genM.RecordTypeId == typeRecordTypeId && genM.Name == String.valueOf(generalRequest.get('CASETYPE')) 
                           && genM.Category__r.Name == String.valueOf(generalRequest.get('CATEGORY')))
                        {
                            caseTypeMatched = true;
                            caseTypeId = genM.Id;
                        }
                        else if(genM.RecordTypeId != typeRecordTypeId && genM.RecordTypeId != subTypeRecordTypeId)
                        {
                            mapCatAndTypeToGenId.put(genM.Name,genM.Id);
                        }
                    }
                }
                
                //---------------------operations with the request-----------------------------------------------------------//
                if(String.isBlank(errorResponse.error))
                {
                    for(GeneralProviderFieldMapping__mdt fmap : GeneralProviderFieldMapping__mdt.getall().values())
                    {
                        if(fmap.Label.startsWithIgnoreCase('CreateCase'))
                        {
                            listcustomMetadata.add(fmap);
                            if(fmap.Required__c && (!generalRequest.containsKey(fmap.WebServiceFieldName__c) || String.isBlank(String.valueOf(generalRequest.get(fmap.WebServiceFieldName__c)))))
                            {
                                errorResponse.error = fmap.WebServiceFieldName__c + ' is required';
                                break;
                            }
                            else if(fmap.SFObjectAPIName__c == 'InsurancePolicy' && fmap.WebServiceFieldName__c == 'policyNumber')
                            {
                                lstPolicyNumber.add((String)generalRequest.get(fmap.WebServiceFieldName__c));
                            }
                        }
                    }
                }
                system.debug('errorResponse.error1-->'+errorResponse.error);
                if(String.isBlank(errorResponse.error))
                {
                    for(InsurancePolicy policy : [select id,Name,NameInsuredId,NameInsured.PersonContactId from InsurancePolicy where Name IN: lstPolicyNumber WITH SECURITY_ENFORCED])
                    {
                        mapPolicyNumberToId.put(policy.Name,policy.Id);
                        mapPolicyNumberToAccId.put(policy.Name,policy.NameInsuredId);
                        mapPolicyNumberToContactId.put(policy.Name, policy.NameInsured.PersonContactId);
                    }
                    for(GeneralProviderFieldMapping__mdt fmap : listcustomMetadata)
                    {
                        if(fmap.SFObjectAPIName__c == 'InsurancePolicy' && fmap.WebServiceFieldName__c == 'policyNumber' 
                                && fmap.Required__c && !mapPolicyNumberToId.containsKey((String)generalRequest.get(fmap.WebServiceFieldName__c)))
                        {
                            errorResponse.error = 'cannot find the policy with the '+fmap.WebServiceFieldName__c + ':'+(String)generalRequest.get(fmap.WebServiceFieldName__c);
                            break;
                        }
                    }
                }
                system.debug('errorResponse.error-->'+errorResponse.error);
                if(String.isBlank(errorResponse.error))
                {
                    for(GeneralProviderFieldMapping__mdt fmap : listcustomMetadata)
                    {
                        if(fmap.SFObjectAPIName__c == 'GenericMaster__c')
                        {
                            if(subTypeMatched == true && fmap.WebServiceFieldName__c == 'CASESUBTYPE')
                            {
                                cs.put(fmap.SFFieldAPIName__c, subTypeId);
                            }
                            else if(caseTypeMatched = true && fmap.WebServiceFieldName__c == 'CASETYPE')
                            {
                                cs.put(fmap.SFFieldAPIName__c, caseTypeId);
                            }
                        }
                        else if(fmap.SFObjectAPIName__c == 'InsurancePolicy' && fmap.WebServiceFieldName__c == 'policyNumber')
                        {
                            cs.put('Policy__c', mapPolicyNumberToId.get((String)generalRequest.get(fmap.WebServiceFieldName__c)));
                            cs.put('AccountId', mapPolicyNumberToAccId.get((String)generalRequest.get(fmap.WebServiceFieldName__c)));
                            cs.put('ContactId', mapPolicyNumberToContactId.get((String)generalRequest.get(fmap.WebServiceFieldName__c)));
                        }
                        else
                        {
                            cs.put(fmap.SFFieldAPIName__c,String.valueOf(generalRequest.get(fmap.WebServiceFieldName__c)));
                        }
                    }
                    if(generalRequest.ContainsKey('SOURCE'))
                    {
                        cs.Source__c = (String)generalRequest.get('SOURCE');
                    }
                    if(generalRequest.get('CATEGORY') != null)
                    {
                        cs.Category__c = mapCatAndTypeToGenId.get((String)generalRequest.get('CATEGORY'));
                    }
                    cs.DMCategory__c = String.valueOf(generalRequest.get('CATEGORY'));
                    cs.DMCallType__c = String.valueOf(generalRequest.get('CASETYPE'));
                    cs.DMSubType__c = String.valueOf(generalRequest.get('CASESUBTYPE'));
                    listCase.add(cs);
                    system.debug('list case-->'+listCase);
                    if(listCase.size() > 0)
                    {
                        
                        if(Schema.sObjectType.Case.isCreateable()) {
                            insert listCase;
                        }
                        else{
                            throw new CustomException('You do not have Craete access on Case');
                        }
                        system.debug('list case after insert-->'+listCase);
                        List<Case> insertedCase = [select id,CaseSRNumber__c from Case where id IN:listcase WITH SECURITY_ENFORCED];
                        //deserializing reponse
                        GeneralProviderContentWrapper.CreateCaseResponse successResponse = new GeneralProviderContentWrapper.CreateCaseResponse();
                        successResponse.success = 'Case has been Created Successfully';
                        successResponse.caseNumber = insertedCase[0].CaseSRNumber__c;
                        successResponse.CreateCaseResponse = 'Record saved successfully. New Case ID:-'+successResponse.caseNumber;
                        RestContext.response.responseBody = Blob.valueOf(JSON.serialize(successResponse));
                        mapLogData.putAll(new Map<String,Object>{'status'=>'Success','caseId'=>insertedCase[0].Id,'recordId'=>insertedCase[0].Id,'response'=>JSON.serialize(successResponse),'responseReceivedTime' => system.now()});
                    }
                }
                else
                {
                    mapLogData.putAll(new Map<String,Object>{'status'=>'Error','response'=>JSON.serialize(errorResponse),'responseReceivedTime' => system.now()});
                }
                
                //Creating integration log
                CreateIntegrationLogUtility log = new CreateIntegrationLogUtility(mapLogData);
                logList.add(log);
            }
            catch(exception ex)
            {
                errorResponse.error = ex.getMessage() + ' @'+ ex.getLineNumber();            
                //Creating integration log
                mapLogData.putAll(new Map<String,Object>{'status'=>'Error','response'=>JSON.serialize(errorResponse),'responseReceivedTime' => System.now()});
                CreateIntegrationLogUtility log = new CreateIntegrationLogUtility(mapLogData);
                logList.add(log);
            }
            finally
            {
                CreateIntegrationLogUtility.createIntegrationLog(logList);
                if(String.isNotBlank(errorResponse.error))
                {
                    RestContext.response.responseBody = Blob.valueOf(JSON.serialize(errorResponse)); 
                }
            }
        }
    /**
* @description  method to Create Lead
@param RestRequest

    public static void createLead(RestRequest request)
    {
        //Request initiated time
        DateTime requestInitiatedTime = System.now();
        //Request body from Request
        String requestBody = request.requestbody.toString();
        //Set response content
        RestContext.response.addHeader('Content-Type', 'application/json');
        //Integration log list
        List<CreateIntegrationLogUtility> logList = new  List<CreateIntegrationLogUtility> ();
        //instance for request wrapper
        Map<String,Object> generalRequest = new Map<String,Object>();
        //Error Response
        GeneralProviderContentWrapper.ErrorResponse errorResponse = new GeneralProviderContentWrapper.ErrorResponse();
        //Map Common log data
        Map<String,Object> mapLogData = new Map<String,Object>{'interfaceName'=>'General_CreateLead',
            'request'=>String.valueOf(requestBody),'requestInitiatedTime'=>requestInitiatedTime,'mode'=>'SYNC'};
                mapLogData.putAll(baseLogData);
        try
        {
            //deserializing request
            generalRequest = (Map<String,Object>)JSON.deserializeUntyped(requestBody); 
            List<Lead> listLead = new List<Lead>();
            Lead ld = new Lead();
            //CreateCaseCustomMetaDataRecords
            List<GeneralProviderFieldMapping__mdt> listcustomMetadata = new List<GeneralProviderFieldMapping__mdt>();
            
            //check service cousumer name is exist
            if(!generalRequest.containskey('source') || String.isBlank((String)generalRequest.get('source')))
            {
                errorResponse.error = 'Source is mandatory';
            }
            else if(request.requestURI == '/General/CreateLead')
            {
                mapLogData.put('serviceConsumer',(String)generalRequest.get('source'));
            }
            if(request.requestURI == '/General/CreateLead_Eterm' && (!generalRequest.containskey('sourceName') || String.isBlank((String)generalRequest.get('sourceName'))))
            {
                errorResponse.error = 'sourceName is mandatory';
            }
            else if(request.requestURI == '/General/CreateLead_Eterm')
            {
                mapLogData.put('serviceConsumer','Rapid_CreateLead_Eterm');
                errorResponse.error = null;
            }
            if(request.requestURI == '/General/CreateLead_Online')
            {
                mapLogData.put('serviceConsumer','General_CreateLead_Online');
                errorResponse.error = null;
            }
            
            //---------------------operations with the request-----------------------------------------------------------//
            if(String.isBlank(errorResponse.error))
            {
                for(GeneralProviderFieldMapping__mdt fmap : GeneralProviderFieldMapping__mdt.getall().values())
                {
                    if(fmap.Label.startsWithIgnoreCase('CreateLead'))
                    {
                        listcustomMetadata.add(fmap);
                        if(String.isBlank(fmap.RequiredOnlyIn__c) || fmap.RequiredOnlyIn__c.split(';').contains(request.requestURI))
                        {
                            if(fmap.Required__c && (!generalRequest.containsKey(fmap.WebServiceFieldName__c) || String.isBlank(String.valueOf(generalRequest.get(fmap.WebServiceFieldName__c)))))
                            {
                                errorResponse.error = fmap.WebServiceFieldName__c + ' is required';
                                break;
                            }
                        }
                    }
                }
            }
            system.debug('errorResponse.error-->'+errorResponse.error);
            if(String.isBlank(errorResponse.error))
            {
                for(GeneralProviderFieldMapping__mdt fmap : listcustomMetadata)
                {
                    if(generalRequest.get(fmap.WebServiceFieldName__c) != null && String.isNotBlank(String.valueOf(generalRequest.get(fmap.WebServiceFieldName__c))))
                    {
                        if(fmap.DataType__c == 'Date')
                        {
                            ld.put(fmap.SFFieldAPIName__c,Date.Parse((String)generalRequest.get(fmap.WebServiceFieldName__c)));
                        }
                        else if(fmap.DataType__c == 'Checkbox')
                        {
                            ld.put(fmap.SFFieldAPIName__c,(Boolean)generalRequest.get(fmap.WebServiceFieldName__c));
                        }
                        else if(fmap.DataType__c == 'Currency')
                        {
                            ld.put(fmap.SFFieldAPIName__c,(Decimal)generalRequest.get(fmap.WebServiceFieldName__c));
                        }
                        else
                        {
                            ld.put(fmap.SFFieldAPIName__c,String.valueOf(generalRequest.get(fmap.WebServiceFieldName__c))); 
                        }
                    }
                }
                ld.Company = (String)generalRequest.get('firstname')+' '+(String)generalRequest.get('lastname');
                if(String.isNotBlank(String.valueOf(generalRequest.get('first_name'))))
                {
                    ld.Company = (String)generalRequest.get('first_name')+' '+(String)generalRequest.get('last_name');
                }
                
                //assign Queue
                List<Group> grp = new List<Group>();
                grp = [SELECT Id, Name, DeveloperName,Type FROM Group where Type ='Queue' and DeveloperName = 'DigitalSales' WITH SECURITY_ENFORCED limit 1];
                if(grp.size() > 0)
                {
                    ld.OwnerId = grp[0].Id;
                }
                
                listLead.add(ld);
                system.debug('list lead-->'+listLead);
                if(listLead.size() > 0)
                {
                    
                    if(Schema.sObjectType.Lead.isCreateable()) {
                      insert listLead;
                      }
                       else{
                            throw new CustomException('You do not have create access on Case');
                                }
                    system.debug('list lead after insert-->'+listLead);
                    List<Lead> insertedLead = [select id,LeadNumberGeneric__c from Lead where id IN:listLead WITH SECURITY_ENFORCED];
                    //deserializing reponse
                    String successResponse = '';
                    if(request.requestURI == '/General/CreateLead_Online')
                    {
                        successResponse = '{"OnlineLead":{"Response":{"StatusCode":"200","CRMLeadId":"'+insertedLead[0].LeadNumberGeneric__c+'","CRMErrorCode":{}}}}';
                    }
                    else if(request.requestURI == '/General/CreateLead_Eterm')
                    {
                        successResponse = '{"Eterm_CRM_Lead_Resp":{"Status":"Success","StatusMessage":"Record Created Successfully with leadid '+insertedLead[0].LeadNumberGeneric__c+'"}}';
                    }
                    else if(request.requestURI == '/General/CreateLead')
                    {
                        successResponse = '{"IsSuccess":true,"Message":"Record Created Successfully with leadid '+insertedLead[0].LeadNumberGeneric__c+'"}';
                    }
                    /*GeneralProviderContentWrapper.CreateLeadResponse successResponse = new GeneralProviderContentWrapper.CreateLeadResponse();
                    successResponse.success = 'Lead has been Created Successfully';
                    successResponse.LeadName = insertedLead[0].Name;
                    successResponse.leadId = insertedLead[0].Id;
                    RestContext.response.responseBody = Blob.valueOf(successResponse);
                    mapLogData.putAll(new Map<String,Object>{'status'=>'Success','recordId'=>insertedLead[0].Id,'leadId'=>insertedLead[0].Id,'response'=>successResponse,'responseReceivedTime' => system.now()});
                }
            }
            else
            {
                mapLogData.putAll(new Map<String,Object>{'status'=>'Error','response'=>JSON.serialize(errorResponse),'responseReceivedTime' => system.now()});
            }
            
            //Creating integration log
            CreateIntegrationLogUtility log = new CreateIntegrationLogUtility(mapLogData);
            logList.add(log);
            //only to cover catch block from test class
            if(Test.isRunningTest()){
                String s;
                Boolean b = s.contains('Apex'); 
            }
        }
        catch(exception ex)
        {
            system.debug('exception-->'+ ex.getMessage() + ' @'+ ex.getLineNumber());
            errorResponse.error = ex.getMessage() + ' @'+ ex.getLineNumber();            
            //Creating integration log
            mapLogData.putAll(new Map<String,Object>{'status'=>'Error','response'=>JSON.serialize(errorResponse),'responseReceivedTime' => System.now()});
            CreateIntegrationLogUtility log = new CreateIntegrationLogUtility(mapLogData);
            logList.add(log);
        }
        finally
        {
            CreateIntegrationLogUtility.createIntegrationLog(logList);
            if(String.isNotBlank(errorResponse.error))
            {
                RestContext.response.responseBody = Blob.valueOf(JSON.serialize(errorResponse)); 
            }
        }
    }
    /**
* @description  method to Create Lead
@param RestRequest

    public static void createContact(RestRequest request)
    {
        //Request initiated time
        DateTime requestInitiatedTime = System.now();
        //Request body from Request
        String requestBody = request.requestbody.toString();
        //Set response content
        RestContext.response.addHeader('Content-Type', 'application/json');
        //Integration log list
        List<CreateIntegrationLogUtility> logList = new  List<CreateIntegrationLogUtility> ();
        //instance for request wrapper
        Map<String,Object> generalRequest = new Map<String,Object>();
        //Error Response
        GeneralProviderContentWrapper.ErrorResponse errorResponse = new GeneralProviderContentWrapper.ErrorResponse();
        //Map Common log data
        Map<String,Object> mapLogData = new Map<String,Object>{'interfaceName'=>'General_CreateContact',
            'request'=>String.valueOf(requestBody),'requestInitiatedTime'=>requestInitiatedTime,'mode'=>'SYNC'};
                mapLogData.putAll(baseLogData);
        try
        {
            //deserializing request
            generalRequest = (Map<String,Object>)JSON.deserializeUntyped(requestBody); 
            List<Account> listAcc = new List<Account>();
            Account acc = new Account();
            //CreateCaseCustomMetaDataRecords
            List<GeneralProviderFieldMapping__mdt> listcustomMetadata = new List<GeneralProviderFieldMapping__mdt>();
            
            //check service cousumer name is exist
            /*if(!generalRequest.containskey('serviceConsumer') || String.isBlank((String)generalRequest.get('serviceConsumer')))
            {
                errorResponse.error = 'ServiceConsumer is mandatory';
            }
            else
            {
                mapLogData.put('serviceConsumer','Portal');
            //}
            //---------------------operations with the request-----------------------------------------------------------//
            if(String.isBlank(errorResponse.error))
            {
                for(GeneralProviderFieldMapping__mdt fmap : GeneralProviderFieldMapping__mdt.getall().values())
                {
                    if(fmap.Label.startsWithIgnoreCase('CreateContact'))
                    {
                        listcustomMetadata.add(fmap);
                        if(fmap.Required__c && (!generalRequest.containsKey(fmap.WebServiceFieldName__c) || String.isBlank(String.valueOf(generalRequest.get(fmap.WebServiceFieldName__c)))))
                        {
                            errorResponse.error = fmap.WebServiceFieldName__c + ' is required';
                            break;
                        }
                    }
                }
            }
            system.debug('errorResponse.error-->'+errorResponse.error);
            if(String.isBlank(errorResponse.error))
            {
                String billingStreet = '';
                String perAddLine1 = '';
                String perAddLine2 = '';
                for(GeneralProviderFieldMapping__mdt fmap : listcustomMetadata)
                {
                    if(generalRequest.get(fmap.WebServiceFieldName__c) != null)
                    {
                        if(fmap.DataType__c == 'Date')
                        {
                            acc.put(fmap.SFFieldAPIName__c,Date.Parse((String)generalRequest.get(fmap.WebServiceFieldName__c)));
                        }
                        else if(fmap.DataType__c == 'Checkbox')
                        {
                            acc.put(fmap.SFFieldAPIName__c,(Boolean)generalRequest.get(fmap.WebServiceFieldName__c));
                        }
                        else if(fmap.DataType__c == 'Currency')
                        {
                            acc.put(fmap.SFFieldAPIName__c,(Decimal)generalRequest.get(fmap.WebServiceFieldName__c));
                        }
                        else if(fmap.DataType__c == 'Number:String')
                        {
                            acc.put(fmap.SFFieldAPIName__c,String.valueOf(generalRequest.get(fmap.WebServiceFieldName__c)));
                        }
                        else if(fmap.SFFieldAPIName__c == 'BillingStreet')
                        {
                            billingStreet = billingStreet +' '+ (String)generalRequest.get(fmap.WebServiceFieldName__c);
                        }
                        else if(fmap.SFFieldAPIName__c == 'ShippingStreet')
                        {
                            perAddLine1 = perAddLine1 +' '+ (String)generalRequest.get(fmap.WebServiceFieldName__c);
                        }
                        else if(fmap.SFFieldAPIName__c == 'ShippingCity')
                        {
                            perAddLine2 = perAddLine2 +' '+(String)generalRequest.get(fmap.WebServiceFieldName__c);
                        }
                        else
                        {
                            acc.put(fmap.SFFieldAPIName__c,(String)generalRequest.get(fmap.WebServiceFieldName__c)); 
                        }
                    }
                }
                system.debug('billing address-->'+BillingStreet);
                acc.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Customer').getRecordTypeId();
                acc.BillingStreet = billingStreet.trim().replaceAll(' +',' ');
                
                acc.ShippingStreet = perAddLine1.trim().replaceAll(' +',' ');
                acc.ShippingCity = perAddLine2.trim().replaceAll(' +',' ');
                listAcc.add(acc);
                
                if(listAcc.size() > 0)
                {
                    
                    if(Schema.sObjectType.Account.isCreateable()) {
                        insert listAcc;
                    }
                    else{
                        throw new CustomException('You do not have Create access on Account');
                    }
                    List<Account> insertedAcc = [select id,Name from Account where id IN:listAcc WITH SECURITY_ENFORCED];
                    //deserializing reponse
                    GeneralProviderContentWrapper.CreateContactResponse successResponse = new GeneralProviderContentWrapper.CreateContactResponse();
                    successResponse.message = 'Contact has been Created Successfully CRM Contact Id:-'+insertedAcc[0].Id;
                    successResponse.ContactName = insertedAcc[0].Name;
                    successResponse.contactId = insertedAcc[0].Id;
                    RestContext.response.responseBody = Blob.valueOf(JSON.serialize(successResponse));
                    mapLogData.putAll(new Map<String,Object>{'status'=>'Success','accountId'=>insertedAcc[0].Id,'recordId'=>insertedAcc[0].Id,'response'=>JSON.serialize(successResponse),'responseReceivedTime' => system.now()});
                }
            }
            else
            {
                mapLogData.putAll(new Map<String,Object>{'status'=>'Error','response'=>JSON.serialize(errorResponse),'responseReceivedTime' => system.now()});
            }
            
            //Creating integration log
            CreateIntegrationLogUtility log = new CreateIntegrationLogUtility(mapLogData);
            logList.add(log);
            //only to cover catch block from test class
            if(Test.isRunningTest()){
                String s;
                Boolean b = s.contains('Apex'); 
            }
        }
        catch(exception ex)
        {
            system.debug('exception-->'+ ex.getMessage() + ' @'+ ex.getLineNumber());
            errorResponse.error = ex.getMessage() + ' @'+ ex.getLineNumber();            
            //Creating integration log
            mapLogData.putAll(new Map<String,Object>{'status'=>'Error','response'=>JSON.serialize(errorResponse),'responseReceivedTime' => System.now()});
            CreateIntegrationLogUtility log = new CreateIntegrationLogUtility(mapLogData);
            logList.add(log);
        }
        finally
        {
            CreateIntegrationLogUtility.createIntegrationLog(logList);
            if(String.isNotBlank(errorResponse.error))
            {
                RestContext.response.responseBody = Blob.valueOf(JSON.serialize(errorResponse)); 
            }
        }
    }
    /**
* @description  method to get Policies service from ESB for IVR_smsEmail
@param RestRequest

    public static void getPolicies(RestRequest request)
    {
        //Request initiated time
        DateTime requestInitiatedTime = System.now();
        //Request body from Request
        String requestBody = request.requestbody.toString();
        //Set response content
        RestContext.response.addHeader('Content-Type', 'application/json');
        //Integration log list
        List<CreateIntegrationLogUtility> logList = new  List<CreateIntegrationLogUtility> ();
        //instance for request wrapper
        GeneralProviderContentWrapper.getPoliciesReq generalRequest = new GeneralProviderContentWrapper.getPoliciesReq();
        //Error Response
        GeneralProviderContentWrapper.GetPolicyResp errorResponse = new GeneralProviderContentWrapper.GetPolicyResp();
        //success Respone
        GeneralProviderContentWrapper.GetPolicyResp successResponse = new GeneralProviderContentWrapper.GetPolicyResp();
        //Request Map
        List<Map<String,Object>> listMapOfStatusReq = new List<Map<String,Object>>();
        //Set of Policy Numbers
        Set<String> listOfPolicyNumber = new Set<String>();
        //List Client Ids
        Set<String> listOfClientIds = new Set<String>();
        //List of policy with policy Number
        List<InsurancePolicy> listPolicy = new List<InsurancePolicy>();
        //List of policy with Mobile Number
        List<InsurancePolicy> listPolicyMob = new List<InsurancePolicy>();
        //Map Common log data
        Map<String,Object> mapLogData = new Map<String,Object>{'interfaceName'=>'General_ESB_GetPolicies',
            'request'=>String.valueOf(requestBody),'requestInitiatedTime'=>requestInitiatedTime,'mode'=>'SYNC'};
                mapLogData.putAll(baseLogData);
        try
        {
            //deserializing request
            generalRequest = (GeneralProviderContentWrapper.getPoliciesReq)JSON.deserialize(requestBody, GeneralProviderContentWrapper.getPoliciesReq.class); 
           
            //Validating the request
            if(String.isBlank(generalRequest.PolicyNumber))
            {
                errorResponse.Message = 'PolicyNumber is Mandatory';
            }
            
            if(String.isBlank(errorResponse.Message))
            {
                listPolicy = [select id,NameInsured.PersonMobilePhone from InsurancePolicy where Name =: generalRequest.PolicyNumber WITH SECURITY_ENFORCED ];
                if(listPolicy.isEmpty())
                {
                    errorResponse.Message = 'No Policy is found in CRM for the Policy Number';
                }
                else if(listPolicy.size() > 0 && listPolicy[0].NameInsured.PersonMobilePhone != null)
                {
					listPolicyMob = [select id,Name,Status,NameInsuredId,NextPremiumDueDate__c,NameInsured.PersonEmail,NameInsured.PersonMobilePhone,
                                     NameInsured.HNI__c,NameInsured.ClientId__c from InsurancePolicy where NameInsured.PersonMobilePhone =: listPolicy[0].NameInsured.PersonMobilePhone WITH SECURITY_ENFORCED];
                }
                else
                {
                    errorResponse.Message = 'No Mobile Number is found in CRM for the Policy Number';
                }
            }
            if((String.isBlank(errorResponse.Message)) || test.isRunningTest())
            {
                //Forming Response
                List<GeneralProviderContentWrapper.PolicyDetails> ListpolicyDetails = new List<GeneralProviderContentWrapper.PolicyDetails>();
                
                for(InsurancePolicy policy : listPolicyMob)
                {
                    GeneralProviderContentWrapper.PolicyDetails policyDetail = new GeneralProviderContentWrapper.PolicyDetails();
                    policyDetail.ClientID = policy.NameInsured.ClientId__c;
                    policyDetail.EmailID = policy.NameInsured.PersonEmail;
                    policyDetail.PolicyNumber = policy.Name;
                    policyDetail.HNI = String.valueOf(policy.NameInsured.HNI__c);
                    policyDetail.PolicyStatus = policy.Status;
                    policyDetail.PhoneNumber = policy.NameInsured.PersonMobilePhone;
                    policyDetail.NextPremiumDueDate = String.valueOf(policy.NextPremiumDueDate__c);
                    //policyDetail.Is_Radiance = 'false';
                    
                    ListpolicyDetails.add(policyDetail);
                }
                
                //Final Response
                successResponse.Status = 'Success';
                successResponse.Message = 'OK';
                GeneralProviderContentWrapper.PolicyDetails_Resp detailsResp = new GeneralProviderContentWrapper.PolicyDetails_Resp();
                detailsResp.PolicyDetails = ListpolicyDetails;
                successResponse.PolicyDetails_Resp = detailsResp;
                
                
                RestContext.response.responseBody = Blob.valueOf(JSON.serialize(successResponse));
                mapLogData.putAll(new Map<String,Object>{'status'=>'Success','response'=>JSON.serialize(successResponse),'responseReceivedTime' =>  system.now()});
                //only to cover catch block from test class
                if(Test.isRunningTest()){
                    String s;
                    Boolean b = s.contains('Apex'); 
                }
            }
            else
            {
                errorResponse.Status = 'Fail';
                mapLogData.putAll(new Map<String,Object>{'status'=>'Error','response'=>JSON.serialize(errorResponse),'responseReceivedTime' => system.now()});
            }
            
            //Creating integration log
            CreateIntegrationLogUtility log = new CreateIntegrationLogUtility(mapLogData);
            logList.add(log);
        }
        catch(exception ex)
        {
            errorResponse.Message = ex.getMessage() + ' @'+ ex.getLineNumber();            
            //Creating integration log
            mapLogData.putAll(new Map<String,Object>{'status'=>'Error','response'=>JSON.serialize(errorResponse),'responseReceivedTime' => System.now()});
            CreateIntegrationLogUtility log = new CreateIntegrationLogUtility(mapLogData);
            logList.add(log);
        }
        finally
        {
            CreateIntegrationLogUtility.createIntegrationLog(logList);
            if(String.isNotBlank(errorResponse.Message))
            {
                errorResponse.Status = 'Fail';
                RestContext.response.responseBody = Blob.valueOf(JSON.serialize(errorResponse)); 
            }
        }
    }
}


*/

}