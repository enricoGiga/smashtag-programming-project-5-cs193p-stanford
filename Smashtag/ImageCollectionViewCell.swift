//
//  ImageCollectionViewCell.swift
//  Smashtag
//
//  Created by enrico  gigante on 12/07/16.
//
@objc protocol customDelegate {
    optional func finishFatchImage(obj: AnyObject, key: AnyObject, cost: Int)
}
import UIKit

class ImageCollectionViewCell: UICollectionViewCell {
   
    var urlPhoto: NSURL?{
        didSet{
            updateUI()
        }
    }
    weak var delegate: customDelegate?
    @IBOutlet weak var imageView: UIImageView!
   

    
    func updateUI(){
        imageView.image = nil
     
        
        // Put the placeHolder image while downloading
        if let placeholder = UIImage(named: "placeholder") {
            imageView.image = placeholder
        }
        
        if let imageUrl = urlPhoto{
  
            dispatch_async(dispatch_get_global_queue(QOS_CLASS_USER_INITIATED, 0)) {
                if let contentsOfURL = NSData(contentsOfURL: imageUrl){
                    dispatch_async(dispatch_get_main_queue()) {
                        if let image = UIImage(data: contentsOfURL){
                        
                        self.imageView.image = image
                         self.delegate?.finishFatchImage?(image, key: imageUrl, cost: contentsOfURL.length)
                        }
                    }
                }
            }
        
    }
    }
    
}
