//
//  RecordedAudio.swift
//  Pitch Perfect
//
//  Created by Jeffrey Isaray on 6/20/15.
//  Copyright (c) 2015 Jeff Isaray. All rights reserved.
//

import Foundation

//Our class used to save the audio file attributes: Url of the path and the title.
class RecordedAudio: NSObject{
    var filePathUrl: NSURL!
    var title: String!
    
    init(filePathUrl:NSURL,title:String){
        self.filePathUrl = filePathUrl
        self.title = title
        super.init()
    }
}
