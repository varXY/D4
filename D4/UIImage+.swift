//
//  UIImage+ColorImage.swift
//  HEICHE
//
//  Created by Bobo on 15/12/18.
//  Copyright © 2015年 farawei. All rights reserved.
//

import UIKit

extension UIImage {

	// 生成颜色图片
    class func imageWithColor(_ color: UIColor, rect: CGRect) -> UIImage {
        UIGraphicsBeginImageContext(rect.size)
        let context = UIGraphicsGetCurrentContext()
        
        context?.setFillColor(color.cgColor)
        context?.fill(rect)
        
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return image!
    }

	// 下载网络图片
	class func imageWithURL(_ url: URL, done: @escaping (UIImage) -> Void) {

		let session = URLSession.shared

		session.downloadTask(with: url, completionHandler: { url, response, error in
			if error == nil && url != nil {
				if let data = try? Data(contentsOf: url!) {
					if let image = UIImage(data: data) {
						DispatchQueue.main.async {
							done(image)
						}
					}
				}
			}
		})

	}
}
