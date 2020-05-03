//
//  Date+Extension.swift
//  RedditFeed
//
//  Created by Pablo Ezequiel Romero Giovannoni on 03/05/2020.
//  Copyright © 2020 Microedition.biz. All rights reserved.
//

import Foundation

extension Date {
    
    var pastDateDescription: String {
        let timeInterval = Date().timeIntervalSince(self)
        
        let justCreatedSeconds = TimeInterval(40.0)
        let secondsPerMinute = TimeInterval(60.0)
       
        if timeInterval < justCreatedSeconds {
            return NSLocalizedString("A few seconds ago", comment: "")
        } else if timeInterval < secondsPerMinute {
            return NSLocalizedString("Less than a minute ago", comment: "")
        } else {
            let minutesAgo = floor(timeInterval / secondsPerMinute)
            let minutesPerHour = TimeInterval(60.0)
            
            if minutesAgo < minutesPerHour {
                return (minutesAgo == 1 ?
                    String(format: "%.0f %@", minutesAgo, NSLocalizedString("minute ago", comment: "")) :
                    String(format: "%.0f minutes ago", minutesAgo, NSLocalizedString("minutes ago", comment: "")))
            } else {
                let hoursAgo = floor(minutesAgo / minutesPerHour)
                let hoursPerDay = TimeInterval(24.0)
                
                if hoursAgo < hoursPerDay {
                    return (hoursAgo == 1 ?
                        String(format: "%.0f %@", hoursAgo, NSLocalizedString("hour ago", comment: "")) :
                        String(format: "%.0f %@", hoursAgo, NSLocalizedString("", comment: "hours ago")))
                    
                } else {
                    let daysAgo = floor(hoursAgo / hoursPerDay)
                    let daysPerMonth = TimeInterval(30.0)
                    
                    if daysAgo < daysPerMonth {
                        return (daysAgo == 1 ?
                            String(format: "%.0f %@", daysAgo, NSLocalizedString("", comment: "day ago")) :
                            String(format: "%.0f %@", daysAgo, NSLocalizedString("", comment: "days ago")))
                    } else {
                        let monthsAgo = floor(daysAgo / daysPerMonth)
                        let monthsPerYear = TimeInterval(12.0)
                        
                        if monthsAgo < monthsPerYear {
                            return (monthsAgo == 1 ?
                                String(format: "%.0f %@", monthsAgo, NSLocalizedString("month ago", comment: "")) :
                                String(format: "%.0f %@", monthsAgo, NSLocalizedString("months ago", comment: "")))
                        } else {
                            let yearsAgo = floor(monthsAgo / monthsPerYear)
                            
                            return (yearsAgo == 1 ?
                                String(format: "%.0f %@", yearsAgo, NSLocalizedString("year ago", comment: "")) :
                                String(format: "%.0f %@", yearsAgo, NSLocalizedString("years ago", comment: "")))
                        }
                    }
                }
            }
        }
    }
    
}
