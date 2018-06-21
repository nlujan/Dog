//
//  String+capitalized.swift
//  Dog
//
//  Created by Naim Lujan on 6/21/18.
//  Copyright © 2018 Naim Lujan. All rights reserved.
//

import Foundation

extension String {
    func capitalizedFirstLetter() -> String {
        return prefix(1).capitalized + dropFirst()
    }
}
