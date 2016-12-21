//
//  String+Localizable.swift
//  PartyPrint
//
//  Created by TrongNK on 10/22/16.
//  Copyright © 2016 DNP. All rights reserved.
//

import UIKit

extension String {
    
    var localized: String {
        return NSLocalizedString(self, tableName: nil, bundle: Bundle.main, value: "", comment: "")
    }
    
    func localizedWithComment(comment: String) -> String {
        return NSLocalizedString(self, tableName: nil, bundle: Bundle.main, value: "", comment: comment)
    }
    
    func localizedWithTableName(_ tableName: String? = nil, bundle: Bundle = Bundle.main, value: String = "", comment: String = "") -> String {
        return NSLocalizedString(self, tableName: tableName, bundle: bundle, value: "", comment: comment)
    }
}
