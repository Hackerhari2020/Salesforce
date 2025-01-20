/* Return a list of all record Types of a sObject
    Ensure you have a method that checks for a specific
    record type and returns the record type id
    Method 1
*/



public with sharing class ApexUseCaseTwentyNine {

    public static List<String> ReturnRecordType(String objectName){
  
    //     List<String> result= new List<String>();
    //     List<RecordType> rt  = [ Select Id, DeveloperName from RecordType where SobjectType =:objectName];

    //     for(RecordType r :rt){

    //         result.add(r.DeveloperName);
    //     }
    //         return result;
    // }
 //------------------------------------------------------------------------------------------->>

 // Method 2 : Using Schema Class in Salesforce :


 //  1. Map<String, Schema.SObjectType> gd = Schema.getGlobalDescribe();
// here String is the Name of Object as key

  List<String> result = new List<String>();

 
  // System.debug ( Schema.getGlobalDescribe().get(objectName).getDescribe().getRecordTypeInfosByDeveloperName());

  Map<String, Schema.RecordTypeInfo> recordTypeInfo =  Schema.getGlobalDescribe().get(objectName).getDescribe().getRecordTypeInfosByDeveloperName();

      For(String s : recordTypeInfo.keyset()){
          if(s!='Master')
        result.add(recordTypeInfo.get(s).developerName);

      }

  return  result;


    }  


}