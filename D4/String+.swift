//
//  String+en:decode.swift
//  HEICHE
//
//  Created by Bobo on 15/12/21.
//  Copyright © 2015年 farawei. All rights reserved.
//

import Foundation

extension String {

	// 获取本地化后的String
	var localized: String! {
		let localizedString = NSLocalizedString(self, comment: "")
		return localizedString
	}

	// 前面加＋号，针对数字。
	mutating func addPositiveMark() {
		self = "+" + self
	}

	// 加密和解密URL
    func URLEncodedString() -> String? {
        let customAllowedSet =  CharacterSet.urlQueryAllowed
        let escapedString = self.addingPercentEncoding(withAllowedCharacters: customAllowedSet)
        return escapedString
    }
    
    func URLDecodeString() -> String? {
        let decodedString = self.removingPercentEncoding
        return decodedString
    }

	// 把.POST时的参数变成.GET时的一串字符
    static func queryStringFromParameters(_ parameters: Dictionary<String,String>) -> String? {
        if (parameters.count == 0)
        {
            return nil
        }
        var queryString : String? = nil
        for (key, value) in parameters {
            if let encodedKey = key.URLEncodedString() {
                if let encodedValue = value.URLEncodedString() {
                    if queryString == nil
                    {
                        queryString = "?"
                    }
                    else
                    {
                        queryString! += "&"
                    }
                    queryString! += encodedKey + "=" + encodedValue
                }
            }
        }
        return queryString
    }
}
