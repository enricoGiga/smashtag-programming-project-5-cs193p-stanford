//
//  UserDefaults.swift
//  Smashtag
//
//  Created by enrico  gigante on 10/07/16.
//  
//

import Foundation
class UserDefaults {
 
    private let chiavePerArrayRicerche = "keyUserSearch"
    private let numberOfSearchStored = 10 // quanti ne voglio memorizzare
    private let userDefaults = NSUserDefaults.standardUserDefaults()
    
    func store(ricercheRecenti:[String]) {
        
        //evitiamo le ripetizioni
        
        var ricerche = ricercheRecenti
        while (ricerche.count > numberOfSearchStored){
            ricerche.removeLast()
        }
       userDefaults.setObject(ricerche, forKey: chiavePerArrayRicerche)
    }
    
    func returnWhatIsStored () -> [String]{
        return userDefaults.objectForKey(chiavePerArrayRicerche) as? [String] ?? []
    }
    func delateSearchTerm(removeAtIndexPath indexPath: NSIndexPath)  {
         var searchTerms = returnWhatIsStored ()
            searchTerms.removeAtIndex(indexPath.row)
            store(searchTerms)
        }
    func deletateSerchTermWithKey (removeKey key: String){
        let searchTerms = returnWhatIsStored ()
        var tempArray: [String] = []
        for value in searchTerms{
            
            if value != key{
                tempArray.append(value)
            }
        }
        store(tempArray)

    }
}