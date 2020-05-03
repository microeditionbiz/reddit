//
//  Formatter.swift
//  MEKit
//
//  Created by Pablo Ezequiel Romero Giovannoni on 24/11/2019.
//  Copyright © 2019 Pablo Ezequiel Romero Giovannoni. All rights reserved.
//

import Foundation

struct Formatter  {
    
    static let dateFormatter: DateFormatter = {
        var dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSS'Z'"
        return dateFormatter
    }()
    
    static let dateUIFormatter: DateFormatter = {
          var dateFormatter = DateFormatter()
          dateFormatter.dateFormat = "yyyy-MM-dd HH:mm"
          return dateFormatter
    }()

}
