//
//  VideoModel.swift
//  IgniteSTEM Video App
//
//  Created by Dominic Whyte on 07/09/16.
//  Copyright © 2016 IgniteSTEM. All rights reserved.
//

import UIKit
import Alamofire

protocol VideoModelDelegate {
    func dataReady(filter : String)
}

class VideoModel: NSObject {
    
    let API_KEY : String = "AIzaSyB5mmCRr9ucCym8SUgc4xZ49EKiHpEXQgY"
    var UPLOAD_PLAYLIST_ID : String = ""
    
    var delegate : VideoModelDelegate?
    var videoArrayFeatured = [Video]()
    var videoArrayAll = [Video]()
    
    struct Playlists {
        static let FEATURED = "PLOUSlWzJElBPyR49Nc_FEs2sNDwkygEcY"
        static let ALL = "PLOUSlWzJElBPyR49Nc_FEs2sNDwkygEcY"
    }
    
    
    func getFeedVideos(filter : String) {
        if (filter == "FEATURED") {
            UPLOAD_PLAYLIST_ID = Playlists.FEATURED
        }
        else {
            UPLOAD_PLAYLIST_ID = Playlists.ALL
        }
        
        Alamofire.request(.GET, "https://www.googleapis.com/youtube/v3/playlistItems", parameters: ["part" : "snippet", "playlistId" : UPLOAD_PLAYLIST_ID, "key" : API_KEY, "maxResults" : 20], encoding: ParameterEncoding.URL, headers: nil).responseJSON { (response) -> Void in
            
            if let JSON = response.result.value {
                var arrayOfVideos = [Video]()
                
                for video in JSON["items"] as! NSArray {
                    let videoObj = Video()
                    
                    if let videoIDText = video.valueForKeyPath("snippet.resourceId.videoId") as? String {
                       videoObj.videoID = videoIDText
                    }
                    if let videoTitleText = video.valueForKeyPath("snippet.title") as? String {
                        videoObj.videoTitle = videoTitleText
                    }
                    
                    if let snippetDescription = video.valueForKeyPath("snippet.description") as? String {
                        videoObj.videoDescription = snippetDescription
                        self.parseDescription(videoObj, description: snippetDescription)
                    }
                    if let thumbnailURL = video.valueForKeyPath("snippet.thumbnails.medium.url") as? String {
                        videoObj.videoThumbnailUrl = thumbnailURL
                    }
                    
                    
                    arrayOfVideos.append(videoObj)
                    
                    
                }
                if (filter == "FEATURED") {
                    self.videoArrayFeatured = arrayOfVideos
                }
                else {
                    self.videoArrayAll = arrayOfVideos
                }
                
                if (self.delegate != nil) {
                    self.delegate!.dataReady(filter)
                }
            }
        }
    }
    
    func parseDescription(videoObj : Video, description : String) {
        if (description.containsString("Speaker: ") && description.containsString("Date: ")) {
            let parsedArray = description.componentsSeparatedByString("Date: ")
            if (parsedArray.count == 2) {
                let speakerName = parsedArray[0].componentsSeparatedByString("Speaker: ")
                if (speakerName.count == 2) {
                    
                    videoObj.videoSpeaker = speakerName[1].substringToIndex(speakerName[1].endIndex.predecessor())
                    let sampleDate = "03/23/16"
                    
                    let dateString = parsedArray[1].substringWithRange(sampleDate.startIndex..<sampleDate.endIndex)
                    let remainingDescription = parsedArray[1].substringWithRange(sampleDate.endIndex..<parsedArray[1].endIndex)
                    
                    videoObj.videoDescription = String(String(remainingDescription.characters.dropFirst()).characters.dropFirst())
                    videoObj.videoDate = dateString
                }
            }
        }
    }
    
    func getVideos() -> [Video] {
        var videos = [Video]()
        
        //Create Video object
        let video1 = Video()
        
        //Assign Properties
        video1.videoID = "48kekFLZkXU"
        video1.videoTitle = "How To Make a YouTube Video App - Ep 03 - Creating the Video Data"
        video1.videoDescription = "In this series, I'll show you guys how to build a video app that plays YouTube videos!"
        
        //Append it to video array
        videos.append(video1)
        
        //Create Video object
        let video2 = Video()
        
        //Assign Properties
        video2.videoID = "mlzu_DXtG80"
        video2.videoTitle = "How To Make a YouTube Video App - Ep 05 - Video Thumbnails"
        video2.videoDescription = "In this series, I'll show you guys how to build a video app that plays YouTube videos!"
        
        //Append it to video array
        videos.append(video2)
        
        
        
        //return array
        return videos
    }
    
}

