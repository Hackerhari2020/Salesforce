public class GeneralProviderIntegrator {
    
    /*

/**
* @description  Class for providing services for create/update records from multiple vendor

@RestResource(urlMapping='/General/*')
global class GeneralProviderIntegrator
{
    /**
* @description post method to call provider Actions
    @httpPost
    global static void GeneralProvider()
    {
        RestRequest request = RestContext.request;
        system.debug('request-->'+request);
        system.debug('request Body-->'+request.requestbody.toString());
        //check request is encrypted or not and encryption is enabled
        if(String.isNotBlank(request.requestbody.toString()))
        {
            request = IntegrationProviderEncryptionUtility.DecryptionActions('General',request);        
        }
        if(request.requestURI == '/General/CreateCase')
        {
            GeneralProviderActions.createCase(request);
        }
        else if(request.requestURI == '/General/CreateLead')
        {
            GeneralProviderActions.createLead(request);
        }
        else if(request.requestURI == '/General/CreateLead_Online')
        {
            Map<String,Object> onlineLead = (Map<String,Object>)JSON.deserializeUntyped(request.requestbody.toString());            
            request.requestbody = Blob.valueOf(JSON.serialize(onlineLead.get('lead_info')));
            system.debug('final online lead requestbody-->'+ JSON.serialize(onlineLead.get('lead_info')));
            GeneralProviderActions.createLead(request);
        }
        else if(request.requestURI == '/General/CreateLead_Eterm')
        {
            Map<String,Object> onlineLead = (Map<String,Object>)JSON.deserializeUntyped(request.requestbody.toString());            
            request.requestbody = Blob.valueOf(JSON.serialize(onlineLead.get('Eterm_CRM_Lead_Req')));
            system.debug('final online lead requestbody-->'+ JSON.serialize(onlineLead.get('Eterm_CRM_Lead_Req')));
            GeneralProviderActions.createLead(request);
        }
        else if(request.requestURI == '/General/CreateContact')
        {
            GeneralProviderActions.createContact(request);
        }
        else if(request.requestURI == '/General/ESB/GetPolicies')
        {
            GeneralProviderActions.getPolicies(request);
        }
        else
        {
            RestContext.response.statuscode = 404;
            return;
        }
        RestContext.response.responseBody = IntegrationProviderEncryptionUtility.EncryptionActions('General',RestContext.response.responseBody);
    }
}


*/

}