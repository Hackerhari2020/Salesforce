
// Merge list of Case assigned to two different queues and return the merged  list

public with sharing class ApexUseCaseTwentyFive {
    public static Set<Case> MergeListofTask(String queueName1, String queueName2) {
        
    List<Case> escalationRecord = [Select Id from Case where Owner.Name =:queueName1];
    List<Case> slaRecord = [Select Id from Case where Owner.Name = :queueName2];
    Set<Case> MergeResult = new Set<Case>();

       MergeResult.addAll(escalationRecord);
       MergeResult.addAll(slaRecord);

       return MergeResult;



 

    }
}