//
//  VideoDetailViewController.swift
//  IgniteSTEM Video App
//
//  Created by Dominic Whyte on 07/09/16.
//  Copyright © 2016 IgniteSTEM. All rights reserved.
//

import UIKit
import Social

class VideoDetailViewController: UIViewController {
    
    @IBOutlet weak var webViewDetail: UIWebView!
    @IBOutlet weak var titleLabelDetail: UILabel!
    
    @IBOutlet weak var speakerDateLabel: UILabel!
    @IBOutlet weak var descriptionLabelDetail: UILabel!

    @IBOutlet weak var webViewHeightConstraintDetail: NSLayoutConstraint!
    
    var selectedVideo : Video?
    
    var selectedFromFilterType : String = "FEATURED"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //webViewDetail.scrollView.scrollEnabled = false
        webViewDetail.scrollView.bounces = false
        backButton.setTitle(selectedFromFilterType, forState: UIControlState.Normal)
        
        // Do any additional setup after loading the view.
    }
    
    @IBOutlet weak var scrollViewHeightConstraint: NSLayoutConstraint!
    
    override func viewWillAppear(animated: Bool) {
        if let vid = self.selectedVideo {
            self.titleLabelDetail.text = vid.videoTitle
            if (selectedVideo != nil && selectedVideo!.videoDate != nil && selectedVideo!.videoSpeaker != nil) {
                print(selectedVideo!.videoDate!)
                print(selectedVideo!.videoSpeaker!)
                speakerDateLabel.text = "\(selectedVideo!.videoSpeaker!) | \(selectedVideo!.videoDate!)"
                descriptionLabelDetail.text = selectedVideo?.videoDescription
            }
            else {
                self.descriptionLabelDetail.text = vid.videoDescription
                self.speakerDateLabel.text = ""
            }
            
            scrollViewHeightConstraint.constant = scrollViewHeightConstraint.constant + titleLabelDetail.requiredHeight() + descriptionLabelDetail.requiredHeight()
            
            let width = self.view.frame.size.width //width of entire view
            let height = width / 320 * 180
            self.webViewHeightConstraintDetail.constant = height
           
            
            let videoEmbedString = "<html><head><style type=\"text/css\">body {background-color: transparent;color: white;}</style></head><body style=\"margin:0\"><iframe frameBorder=\"0\" height=\"" + String(height) + "\" width=\"" + String(width) + "\" src=\"http://www.youtube.com/embed/" + vid.videoID + "?showinfo=0&modestbranding=1&frameborder=0&rel=0\"></iframe></body></html>"
            
            self.webViewDetail.loadHTMLString(videoEmbedString, baseURL: nil)
        }
        
    }
    @IBOutlet weak var backButton: UIButton!
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        webViewDetail.scrollView.contentInset = UIEdgeInsetsZero
    }
    
    @IBAction func socialMediaClicked(sender: AnyObject) {
        
        let optionMenu = UIAlertController(title: nil, message: "Share this video on Social Media", preferredStyle: .ActionSheet)
        
        // 2
        let facebookShare = UIAlertAction(title: "Share on Facebook", style: .Default, handler: {
            (alert: UIAlertAction!) -> Void in
            self.shareToFacebook()
        })
        
        let twitterShare = UIAlertAction(title: "Share on Twitter", style: .Default, handler: {
            (alert: UIAlertAction!) -> Void in
            self.shareToTwitter()
        })
        
        //
        let cancelAction = UIAlertAction(title: "Cancel", style: .Cancel, handler: {
            (alert: UIAlertAction!) -> Void in
        })
        
        
        // 4
        optionMenu.addAction(facebookShare)
        optionMenu.addAction(twitterShare)
        optionMenu.addAction(cancelAction)
        
        // 5
        self.presentViewController(optionMenu, animated: true, completion: nil)
        
    }
    
func shareToFacebook() {
        let shareToFacebook : SLComposeViewController = SLComposeViewController(forServiceType: SLServiceTypeFacebook)
        shareToFacebook.addURL(NSURL(string: "https://www.youtube.com/watch?v=" + (selectedVideo?.videoID)!))
        self.presentViewController(shareToFacebook, animated: true, completion: nil)
    }
    
func shareToTwitter() {
        let shareToTwitter : SLComposeViewController = SLComposeViewController(forServiceType: SLServiceTypeTwitter)
        shareToTwitter.addURL(NSURL(string: "https://www.youtube.com/watch?v=" + (selectedVideo?.videoID)!))
        self.presentViewController(shareToTwitter, animated: true, completion: nil)
    }
    
    @IBAction func backButtonPressed(sender: UIButton) {
        navigationController?.popViewControllerAnimated(true)
    }
}

extension UILabel {
    
    func requiredHeight() -> CGFloat {
        let label : UILabel = UILabel(frame: CGRectMake(0, 0, self.frame.width, CGFloat.max))
        label.numberOfLines = 0
        label.lineBreakMode = NSLineBreakMode.ByWordWrapping
        label.font = self.font
        label.text = self.text
        label.sizeToFit()
        return label.frame.height
    }
}

