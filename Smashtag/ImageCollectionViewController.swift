//
//  ImageCollectionViewController.swift
//  Smashtag
//
//  Created by enrico  gigante on 10/07/16.
//

import UIKit





class ImageCollectionViewController: UICollectionViewController, UICollectionViewDelegateFlowLayout, customDelegate {
    var cacheMemory =  NSCache()
    override func viewDidLoad() {
        super.viewDidLoad()
        
        collectionView?.backgroundColor = UIColor.grayColor()


    }
    // ogni volta che cambia la scala fa un redraw del layout della collectionView
    private var scale:CGFloat = 3 { didSet {  imageCollectionView?.collectionViewLayout.invalidateLayout() } }

    private var tweetsWithImages: [[Tweet]] = [[]]

    var tweets = [Array<Tweet>]() {
        didSet{
            for arrayOfTweet in tweets{
                let filterArray = arrayOfTweet.filter({$0.media.first != nil })
                tweetsWithImages.append(filterArray)
            }
        }
    }

    struct Storyboard{
        static let CollectionViewReusableCellIdentifier = "ImageCell"
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
 // MARK: - Gestures
    @IBOutlet var imageCollectionView: UICollectionView!{
        didSet{
            //solo le view possono recognize (riconoscere) le gesture
            //questo didSet è su un outlet, quindi viene chiamato solo la prima volta che iOS si collega alla view, è il momento migliore per aggiungere una gesture alla view!
            //in questo caso il pich cambia solo la scala (non cambia il model) quindi potrei dire che l'handler è la view stessa,
            // se dovessi cambiare anche il model dovrei mettere come target il controller (in questo caso metto il controller(self) pechè non ho creato una classe per la view, changeScale è l'handler della gesture
            imageCollectionView.addGestureRecognizer(UIPinchGestureRecognizer(target: self, action: #selector(ImageCollectionViewController.changeScale(_:))))
            
        }
    }
    //handler
    func changeScale (recognizer: UIPinchGestureRecognizer){
        switch recognizer.state {
        case .Changed:
            // diamo un limite allo zooming!
            scale = max (min(5, scaleZooming(scale, recognizer: recognizer)), 1)
            //scale *= recognizer.scale
            recognizer.scale = 1
        case .Ended:
            //questo è per le bitches di instagram
            if scale % 1 < 1{
                scale -= scale % 1
            }
        default:
            break
        }
    }
    
    private func scaleZooming(scale : CGFloat, recognizer: UIPinchGestureRecognizer) -> CGFloat{
        return scale * recognizer.scale
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using [segue destinationViewController].
        // Pass the selected object to the new view controller.
    }
    */

    // MARK: UICollectionViewDataSource

    override func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return tweetsWithImages.count
    }


    override func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of items
        return tweetsWithImages[section].count
    }
    
    override func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(Storyboard.CollectionViewReusableCellIdentifier, forIndexPath: indexPath) as! ImageCollectionViewCell
        let tweet = tweetsWithImages[indexPath.section][indexPath.row]
        cell.delegate = self
        if let url = tweet.media.first?.url {
            if let cachedPhoto = cacheMemory.objectForKey(url ) {
                cell.imageView.image = cachedPhoto as? UIImage
            }else{
                cell.urlPhoto = tweet.media.first?.url
                
            }
        }
       
        return cell
    }
    
    func finishFatchImage(obj: AnyObject, key: AnyObject, cost: Int) {
        cacheMemory.setObject(obj, forKey: key, cost: cost)
    }
    //MARK: - ImageCollectionViewDelegateFlowLayout
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        let width: CGFloat = collectionView.bounds.size.width/scale
        let size = CGSize(width: width-1, height: width-1)
        
        return size
    }
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAtIndex section: Int) -> CGFloat {
        return 1
    }
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAtIndex section: Int) -> CGFloat {
        return 2
    }


}
