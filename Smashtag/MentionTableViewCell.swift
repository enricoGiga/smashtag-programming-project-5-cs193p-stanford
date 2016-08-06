//
//  MentionTableViewCell.swift
//  Smashtag
//
//  Created by enrico  gigante on 08/07/16.
//

import UIKit

class MentionTableViewCell: UITableViewCell {


    var imageUrl: NSURL?{
        didSet{
           updateUI()
        }
    }

    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var MantionImage: UIImageView!
    
    func updateUI(){
        
        // resetto i tweet preesistenti
        MantionImage.image = nil
        
        if let imageUrl = imageUrl {
            
            activityIndicator.startAnimating()
            
            
            //faccio il fetch dei dati fuori dal main queue
            dispatch_async(dispatch_get_global_queue(QOS_CLASS_USER_INITIATED, 0)) {
                if let data = NSData(contentsOfURL: imageUrl) {
                    
                    //update UI nel main queue
                    dispatch_async(dispatch_get_main_queue()) {
                        self.MantionImage?.image = UIImage(data: data)
                        self.activityIndicator.stopAnimating()
                    }
                } else {
                    self.activityIndicator.stopAnimating()
                }
            }
        }
    }
    
 
    

}
