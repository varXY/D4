//
//  Array+.swift
//  30ZF
//
//  Created by 文川术 on 3/31/16.
//  Copyright © 2016 myname. All rights reserved.
//

import Foundation

extension Array {

	// 批量删除数字中的元素
	mutating func removeAtIndexes(incs: [Int]) {
		incs.sort(>).forEach { removeAtIndex($0) }
	}

}
