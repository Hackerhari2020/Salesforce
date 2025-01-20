// Assign Case to SLA Queue if criteria is met.
//Case Origin should be Web and Priority should be High



// Note ----> Assigning means change OwnerId(i.e., Case OwnerId to SLA Queue Id);
// Note-----> Always use null check for null pointer exceptions

public with sharing class ApexUseCaseTwentyThree {

    public static final String priorityType='High';
    public static final  String caseOrigin='Web';
    
    public static void caseToQueueAssignment(Case caseRec) {

        // always use null check for null pointer exceptions
        if(caseRec!=null){

            if(caseRec.Priority==priorityType && caseRec.Origin==caseOrigin){

                List<Group> mySLAQueue = [Select Id, Name from Group where Type='Queue' AND DeveloperName='SLA_Queue'];

                    if(mySLAQueue.size()>0){

                        caseRec.OwnerId=mySLAQueue[0].Id;

                        update caseRec;
                    }

            }

        }


    }
}