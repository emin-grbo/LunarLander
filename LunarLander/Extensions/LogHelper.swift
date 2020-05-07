//
//  LogHelper.swift
//  LunarLander
//
//  Created by Emin Roblack on 15/04/2020.
//  Copyright © 2020 Emin Roblack. All rights reserved.
//

import Foundation

enum log {
    case ln(_: String)
    case obj(_: String, _: Any)
    case error(_: Error)
    case url(_: String)
    case any(_: Any)
    case date(_: NSDate)
}

postfix operator /

postfix func / (target: log?) {
    guard let target = target else { return }
    
    func log<T>(_ emoji: String, _ string: String = "", _ object: T) {
        print(emoji + "\(string)→" + " " + "\(object)")
    }
    
    switch target {
    case .ln(let line):
        log("✏️", "", line)
        
    case .obj(let string, let obj):
        log("📦", string, obj)
        
    case .error(let error):
        log("❗️❗️❗️", "", error)
        
    case .url(let url):
        log("🔗", "", url)
        
    case .any(let any):
        log("⚪️", "", any)
        
    case .date(let date):
        log("⏰", "", date)
    }
}

