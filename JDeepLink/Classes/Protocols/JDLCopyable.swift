//
//  JPLCopyable.swift
//  yilegou
//
//  Created by Jasper on 2020/8/18.
//  Copyright © 2020 uutequan. All rights reserved.
//

import Foundation

protocol JDLCopyable: AnyObject {
    func copy() -> Self
}
