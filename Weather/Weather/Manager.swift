//
//  Current.swift
//  Weather
//
//  Created by Siyuan Peng on 11/2/14.
//  Copyright (c) 2014 Siyuan Peng. All rights reserved.
//

import Foundation

enum Mode{
    case current
    case forecast
}

protocol ManagerDelegate{
    func success()
    func fail()
}

struct ForecastParseResult{
    
    //must init optional array, then object can be added in the array, or the whole array will be nil
    var date: [String]?=[]
    var tempMax: [Int]=[]
    var tempMin: [Int]=[]
    var place: String?
    var desc: [String]?=[]
    
    init(weatherDic: NSDictionary){
        let city=weatherDic["city"] as NSDictionary
        place=city["name"] as? String
        
        let list: [NSDictionary]=weatherDic["list"] as [NSDictionary]
        for day in list{
            let timeOriginal=day["dt"] as Int
            date?.append(getDate(timeOriginal))
            
            let temp=day["temp"] as NSDictionary
            tempMax.append(Int((temp["max"] as Float)-273.15))
            tempMin.append(Int((temp["min"] as Float)-273.15))
            
            let weather: [NSDictionary]=day["weather"] as [NSDictionary]
            desc?.append((weather[0]["description"] as String))
        }
    }
    
    func getDate(unixTime: Int)->String{
        
        // println(unixTime) 1415300400
        let timeInSeconds=NSTimeInterval(unixTime)
        // println(timeInSeconds) 1415300400.0
        let GMTTimestamp=NSDate(timeIntervalSince1970: timeInSeconds)
        // println(GMTTimestamp) 2014-11-06 19:00:00 +0000
        let dateFormatter=NSDateFormatter()
        dateFormatter.dateStyle=NSDateFormatterStyle.MediumStyle
        
        return dateFormatter.stringFromDate(GMTTimestamp)
    }
}

struct CurrentParseResult {
    
    var time: String?
    var temp: Int=0
    var tempMax: Int=0
    var tempMin: Int=0
    var place: String?
    var desc: String?
    
    init(weatherDic: NSDictionary){
        //println(weatherDic)
        
        let main=weatherDic["main"] as NSDictionary
        temp=Int((main["temp"] as Float)-273.15)
        tempMax=Int((main["temp_max"] as Float)-273.15)
        tempMin=Int((main["temp_min"] as Float)-273.15)
        
        let timeOriginal=weatherDic["dt"] as Int
        time=getTime(timeOriginal)
        
        place=(weatherDic["name"] as String)
        
        let weather: [NSDictionary]=weatherDic["weather"] as [NSDictionary]
        desc=(weather[0]["description"] as String).capitalizedString
    }
    
    func getTime(unixTime: Int)->String{
        let dateFormatter=NSDateFormatter()
        
        let timeInSeconds=NSTimeInterval(unixTime)
        let GMTTimestamp=NSDate(timeIntervalSince1970: timeInSeconds)
        dateFormatter.timeStyle=NSDateFormatterStyle.ShortStyle
        //dateFormatter.dateStyle=NSDateFormatterStyle.LongStyle
        
        return dateFormatter.stringFromDate(GMTTimestamp)
    }
}

class Manager{
    init(mode: Mode){
        self.mode=mode
    }
    
    var mode: Mode?
    var delegate: ManagerDelegate?
    var current: CurrentParseResult?
    var forecast: ForecastParseResult?
    var url: NSURL?
    
    func asyncFetchData(#lat: String, lon: String){
        
        let baseUrl=NSURL(string: "http://api.openweathermap.org/data/2.5/")!
        
        if mode==Mode.current{
            url=NSURL(string: "weather?lat=\(lat)&lon=\(lon)", relativeToURL: baseUrl)
        }else{
            url=NSURL(string: "forecast/daily?lat=\(lat)&lon=\(lon)&cnt=10&mode=json", relativeToURL: baseUrl)
        }
        
        //using async method to send and retrive the data
        let sharedSession=NSURLSession.sharedSession()
        let downloadTask: NSURLSessionDownloadTask=sharedSession.downloadTaskWithURL(url!, completionHandler: {(location: NSURL!, response: NSURLResponse!, error: NSError!) -> Void in
            
            //location is the temp file as the method's description says, using NSString to read this file whose content is the JSON data
            //var urlContents=NSString(contentsOfURL: location, encoding: NSUTF8StringEncoding, error: nil)
            //println(urlContents)
            if (error==nil){
                let dataObject=NSData(contentsOfURL: location)!
                let weatherDic: NSDictionary=NSJSONSerialization.JSONObjectWithData(dataObject, options: nil, error: nil) as NSDictionary
                if self.mode==Mode.current{
                    self.current=CurrentParseResult(weatherDic: weatherDic)
                }else{
                    self.forecast=ForecastParseResult(weatherDic: weatherDic)
                }
                
                // call the main thread to execute the code in the closure immediately, or we will wait until the async method finish
                dispatch_async(dispatch_get_main_queue(), { () -> Void in
                    //                    self.navigationItem.title="\(curr.place!)"
                    if let d=self.delegate{
                        d.success()
                    }
                })
            }else{
                if let d=self.delegate{
                    d.fail()
                }
            }
        })
        downloadTask.resume()
    }
}




