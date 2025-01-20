//Categorize all cases by their Origin and Return a collection of all the Cases



public with sharing class ApexUseCaseTwentyEight {
    public static void  ApexUseCaseTwentyEight() {

    Map<String, List<Case>> result = new Map<String, List<Case>>();

    List<Case> c = [Select Id, Origin from Case];

        for(Case cc : c){

            //if map has a key(already contains a key i.e., case origin)
            //don't create a new list, just append the case to the current list

            // if map does not have the key(Does not have the case origin)
            //create a new put entry, with a new  list with this particular case record added

          if(result.containsKey(cc.Origin)){
            result.get(cc.Origin).add(cc);
          }
          else{

            List<Case> caseByOrigin = new List<Case>();
            caseByOrigin.add(cc);
            result.put(cc.Origin,caseByOrigin);

          }

        }

    }
}