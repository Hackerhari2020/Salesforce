
// custom label are not a object , but it also has recordId
// custom label cannot be instantiated because it is not a Object.

// call custom label in soql using System.Label.DeveloperNameXYZ

// Find the Queue name from a custom label and assign the created case to the queue

public with sharing class ApexUesCaseTwentySix {
    public static void assignCaseToQueue(Id caseRecId) {

        List<Group> queueInfo = [Select Id from Group where Type='Queue' AND DeveloperName = :System.Label.My_Primary_Quote limit 1];
        List<Case> caseToAssign = [Select Id , OwnerId from Case where Id =:caseRecId LIMIT 1];

        if(caseToAssign.size()==1 && queueInfo.size()==1){

            caseToAssign[0].OwnerId = queueInfo[0].Id;

            update caseToAssign[0];
        }


    }
}