// Playground - noun: a place where people can play

import Cocoa

var lat="40"
var lon="-74"

var baseUrl=NSURL(string: "http://api.openweathermap.org/data/2.5/")!
var currentUrl=NSURL(string: "weather?lat=\(lat)&lon=\(lon)", relativeToURL: baseUrl)!
var predictUrl=NSURL(string: "forecast/daily?lat=\(lat)&lon=\(lon)&cnt=10&mode=json", relativeToURL: baseUrl)!
