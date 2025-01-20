
// Find the Unique list of all accounts which are part of the Opportunities which have Revenue more than 80k

public with sharing class ApexUseCaseTwentySeven {
    public static void GenerateAccountReport() {

      List<Opportunity>ls =  [Select AccountId,Id, Name, Amount from Opportunity where Amount>80000 ];    
      
        Set<Id> res = new Set<Id>();

        for(Opportunity opp : ls){

                 res.add(opp.AccountId);

        }







    }
}