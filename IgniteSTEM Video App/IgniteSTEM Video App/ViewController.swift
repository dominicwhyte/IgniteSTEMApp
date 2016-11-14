//
//  ViewController.swift
//  IgniteSTEM Video App
//
//  Created by Dominic Whyte on 07/09/16.
//  Copyright © 2016 IgniteSTEM. All rights reserved.
//

import UIKit

class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, VideoModelDelegate {
    
    @IBOutlet weak var featuredButton: UIButton!
    @IBOutlet weak var allButton: UIButton!
    
    @IBOutlet weak var tableViewVideos: UITableView!
    
    var videosFeatured : [Video] = [Video]()
    var videosAll : [Video] = [Video]()
    var selectedVideo : Video?
    let model : VideoModel = VideoModel()
    
    var filter : String = "FEATURED"
    
    let selectedColor : UIColor = UIColor(red: 88/255, green: 121/255, blue: 133/255, alpha: 1)
    let unSelectedColor : UIColor = UIColor(red: 77/255, green: 105/255, blue: 116/255, alpha: 1)
    
    @IBAction func filterClicked(sender: UIButton) {
        let title = (sender.titleLabel?.text)!
        if (title == "FEATURED") {
            featuredButton.enabled = false
            allButton.enabled = true
            allButton.backgroundColor = unSelectedColor
            featuredButton.backgroundColor = selectedColor
        }
        else {
            featuredButton.enabled = true
            allButton.enabled = false
            allButton.backgroundColor = selectedColor
            featuredButton.backgroundColor = unSelectedColor
        }
        tableViewVideos.scrollToRowAtIndexPath(NSIndexPath.init(forRow: 0, inSection: 0), atScrollPosition: UITableViewScrollPosition.Top, animated: true)
        model.getFeedVideos(title)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        model.getFeedVideos(filter)
        self.tableViewVideos.dataSource = self
        self.tableViewVideos.delegate = self
        model.delegate = self
        
        if (filter == "FEATURED")  {
            featuredButton.enabled = false
        }
        else {
            allButton.enabled = true
        }
        tableViewVideos.separatorStyle = .None
    }
    
    func dataReady(filter : String) {
        if (filter == "FEATURED") {
            self.videosFeatured = self.model.videoArrayFeatured
        }
        else {
            self.videosAll = self.model.videoArrayAll
        }
        self.filter = filter
        self.tableViewVideos.reloadData()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return videosFeatured.count
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        //get width of screen to calculate necessary height to show the whole pciture
        return (self.view.frame.width / 320) * 180
    }
    
    let secondLineColor : UIColor = UIColor(red: 200/255, green: 214/255, blue: 219/255, alpha: 1)
    
    func getColoredText(text: String) -> NSMutableAttributedString {
        let string:NSMutableAttributedString = NSMutableAttributedString(string: text)
        let words:[String] = text.componentsSeparatedByString(" ")
        var w = ""
        
        for word in words {
            if (word.hasPrefix("{|") && word.hasSuffix("|}")) {
                let range:NSRange = (string.string as NSString).rangeOfString(word)
                string.addAttribute(NSForegroundColorAttributeName, value: secondLineColor, range: range)
                w = word.stringByReplacingOccurrencesOfString("{|", withString: "")
                w = w.stringByReplacingOccurrencesOfString("|}", withString: "")
                string.replaceCharactersInRange(range, withString: w)
            }
        }
        
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineSpacing = 3
        
        string.addAttribute(NSParagraphStyleAttributeName, value:paragraphStyle, range:NSMakeRange(0, string.length))
        
        return string
    }
    
    var cachedImages : [String: UIImage] = [:]
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("BasicCell")!
        //let videoTitle = videos[indexPath.row].videoTitle
        cell.selectionStyle = UITableViewCellSelectionStyle.None
        
        
        //Construct the video thumnail url
        //let videoThumnailUrlString = "https://i1.ytimg.com/vi/" + videos[indexPath.row].videoID + "/maxresdefault.jpg"
        let videoThumbnailUrlString : String
        var titleString : String = ""
        //var speakerString : String = ""
        
        if (filter == "FEATURED") {
            videoThumbnailUrlString = videosFeatured[indexPath.row].videoThumbnailUrl
            titleString = videosFeatured[indexPath.row].videoTitle
            //speakerString = videosFeatured[indexPath.row].videoTitle
        }
        else {
            videoThumbnailUrlString = videosAll[indexPath.row].videoThumbnailUrl
            titleString = videosAll[indexPath.row].videoTitle
            //speakerString = videosAll[indexPath.row].videoTitle
        }
        
        //get cell label
        let label = cell.viewWithTag(2) as! UILabel
//        label.attributedText = getColoredText("\(titleString) \n {|\(speakerString)|}")
        label.attributedText = getColoredText("\(titleString)")

        if (cachedImages[videoThumbnailUrlString] == nil) {
            //Create NSUrl object
            let videoThumbnailURL = NSURL(string: videoThumbnailUrlString)
            
            if (videoThumbnailURL != nil) {
                //Create NSUrl request object
                let request = NSURLRequest(URL: videoThumbnailURL!)
                
                //Create NSUrlSession
                let session = NSURLSession.sharedSession()
                
                //Create a datatask and pass the request
                let dataTask = session.dataTaskWithRequest(request, completionHandler: { (data : NSData?, response : NSURLResponse?, error : NSError?) in
                    
                    //the following is all updating UI, so do it in the main thread
                    
                    dispatch_async(dispatch_get_main_queue(), {
                        //get a reference to the imageview element of the cell
                        let imageView = cell.viewWithTag(1) as! UIImageView
                        
                        //create image object from data and assign to image
                        if (data != nil) {
                            imageView.image = UIImage(data: data!)
                            self.cachedImages[videoThumbnailUrlString] = imageView.image
                        }
                        
                    })
                })
                dataTask.resume()
                
            }
        }
        else {
            let imageView = cell.viewWithTag(1) as! UIImageView
            imageView.image = cachedImages[videoThumbnailUrlString]
        }
        
        
        
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if (filter == "FEATURED") {
            selectedVideo = videosFeatured[indexPath.row]
        }
        else {
            selectedVideo = videosAll[indexPath.row]
        }

        self.performSegueWithIdentifier("goToDetail", sender: self)
    }
    
    //NOTE: for this to work, you have to delete the original segue that fires upon selection. see video 9
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        //get reference to destination view controller
        let detailViewController = segue.destinationViewController as! VideoDetailViewController
        detailViewController.selectedFromFilterType = filter
        print(detailViewController.selectedFromFilterType)
        detailViewController.selectedVideo = self.selectedVideo
    }
    
}



