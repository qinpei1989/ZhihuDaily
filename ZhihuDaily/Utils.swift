//
//  Utils.swift
//  ZhihuDaily
//
//  Created by Pei Qin on 08/26/2017.
//  Copyright © 2017 Columbia University. All rights reserved.
//

import Foundation
import UIKit

class Utils {
    
    static func processHttpRequest(withURLString urlString: String, completion: @escaping (Any) -> Void) {
        let session = URLSession(configuration: URLSessionConfiguration.default)
        let url = URL(string: urlString)
        let dataTask = session.dataTask(with: url!) { (data, response, error) in
            if let jsonData = data {
                do {
                    let jsonObject = try JSONSerialization.jsonObject(with: jsonData, options: [])
                    DispatchQueue.main.async(execute: {
                        completion(jsonObject)
                    })
                } catch let error {
                    print("error creating JSON object: \(error)")
                }
            } else if let requestError = error {
                print("Error fetching data: \(requestError)")
            } else {
                print("Unexpected error with the request")
            }

        }
        dataTask.resume()
    }
    
    /* 将"20170829"转化为"8月29日 星期二" */
    static func constructCustomDateString(fromString date: String) -> String {
        let dateFormatter: DateFormatter = {
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyyMMdd"
            return formatter
        }()
        
        let date = dateFormatter.date(from: date)!
        let calendar = Calendar.current
        let month = calendar.component(.month, from: date)
        let day = calendar.component(.day, from: date)
        let weekday = Utils.weekdayStringFromInt(weekday: calendar.component(.weekday, from: date))!
        
        return "\(month)月\(day)日 星期\(weekday)"
    }
    
    static func weekdayStringFromInt(weekday day: Int) -> String? {
        var string: String?
        switch day {
        case 1:
            string = "日"
        case 2:
            string = "一"
        case 3:
            string = "二"
        case 4:
            string = "三"
        case 5:
            string = "四"
        case 6:
            string = "五"
        case 7:
            string = "六"
        default:
            string = nil
        }
        return string
    }
}
