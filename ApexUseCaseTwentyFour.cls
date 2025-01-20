// Return Account whose AnnualRevenue is Highest

public with sharing class ApexUseCaseTwentyFour {
    public  static Account  FindHighestAnnualRevenue() {

        List<Account> result = [Select Id, Name, AnnualRevenue from Account where AnnualRevenue!=null  Order By AnnualRevenue DESC limit 1];

                if(result.size()==1){
                   return result[0];
                }
                return null;
        
    }
}