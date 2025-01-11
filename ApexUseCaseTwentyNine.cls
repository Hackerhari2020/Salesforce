/* Return a list of all record Types of a sObject
    Ensure you have a method that checks for a specific
    record type and returns the record type id
    Method 1 
*/




public with sharing class ApexUseCaseTwentyNine {

    public static List<String> ReturnRecordType(String objectName){
  
        List<String> result= new List<String>();
        List<RecordType> rt  = [ Select Id, DeveloperName from RecordType where SobjectType =:objectName];

        for(RecordType r :rt){

            result.add(r.DeveloperName);
        }
            return result;
    }

}