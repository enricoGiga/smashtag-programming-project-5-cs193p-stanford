//
//  CoreDataTableViewController.swift
//
//  Created by CS193p Instructor.
//

import UIKit
import CoreData

class CoreDataTableViewController: UITableViewController, NSFetchedResultsControllerDelegate
{
    // quando setto questa variabile pubblica , viene fatto l'update della tableview
    var fetchedResultsController: NSFetchedResultsController? {
        didSet {
            do {
                if let frc = fetchedResultsController {
                    //sono io che devo essere notificato quando il fatch risulta diverso
                    frc.delegate = self
                    //esegue la request 
                    try frc.performFetch()
                }
                tableView.reloadData()
            } catch let error {
                print("NSFetchedResultsController.performFetch() failed: \(error)")
            }
        }
    }

    // MARK: UITableViewDataSource
//nel nostro caso il numero di section sarà una perchè ricerchiamo una sola entity (TwitterUser)
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
       
        return fetchedResultsController?.sections?.count ?? 1
    }
// il numero delle righe corrisponde al numero di oggetti
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let sections = fetchedResultsController?.sections where sections.count > 0 {
           // print(sections[section].numberOfObjects)
            return sections[section].numberOfObjects
            
        } else {
            return 0
        }
    }
    
    override func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if let sections = fetchedResultsController?.sections where sections.count > 0 {
       
            return sections[section].name
        } else {
            return nil
        }
    }
    
    override func sectionIndexTitlesForTableView(tableView: UITableView) -> [String]? {
        return fetchedResultsController?.sectionIndexTitles
    }
    
    override func tableView(tableView: UITableView, sectionForSectionIndexTitle title: String, atIndex index: Int) -> Int {
        return fetchedResultsController?.sectionForSectionIndexTitle(title, atIndex: index) ?? 0
    }
    //ogni volta che il database cambia il delegato richiama queste funzioni che servono per fare l'update della table view
    // MARK: NSFetchedResultsControllerDelegate
    
    func controllerWillChangeContent(controller: NSFetchedResultsController) {
        tableView.beginUpdates()
    }
    
    func controller(controller: NSFetchedResultsController, didChangeSection sectionInfo: NSFetchedResultsSectionInfo, atIndex sectionIndex: Int, forChangeType type: NSFetchedResultsChangeType) {
        switch type {
            case .Insert: tableView.insertSections(NSIndexSet(index: sectionIndex), withRowAnimation: .Fade)
            case .Delete: tableView.deleteSections(NSIndexSet(index: sectionIndex), withRowAnimation: .Fade)
            default: break
        }
    }
    
    func controller(controller: NSFetchedResultsController, didChangeObject anObject: AnyObject, atIndexPath indexPath: NSIndexPath?, forChangeType type: NSFetchedResultsChangeType, newIndexPath: NSIndexPath?) {
        switch type {
            case .Insert:
                tableView.insertRowsAtIndexPaths([newIndexPath!], withRowAnimation: .Fade)
            case .Delete:
                tableView.deleteRowsAtIndexPaths([indexPath!], withRowAnimation: .Fade)
            case .Update:
                tableView.reloadRowsAtIndexPaths([indexPath!], withRowAnimation: .Fade)
            case .Move:
                tableView.deleteRowsAtIndexPaths([indexPath!], withRowAnimation: .Fade)
                tableView.insertRowsAtIndexPaths([newIndexPath!], withRowAnimation: .Fade)
        }
    }
    
    func controllerDidChangeContent(controller: NSFetchedResultsController) {
        tableView.endUpdates()
    }
}

