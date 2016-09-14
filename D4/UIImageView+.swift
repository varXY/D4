//
//  UIImageView+DownloadImage.swift
//  StoreSearch
//
//  Created by 文川术 on 15/8/13.
//  Copyright (c) 2015年 xiaoyao. All rights reserved.
//

import UIKit

extension UIImageView {

	func loadImageWithURl(_ url: URL) -> URLSessionDownloadTask {

		// 下载完成之前，显示载入指示圈
		let indicator = UIActivityIndicatorView(activityIndicatorStyle: .gray)
		indicator.startAnimating()
		indicator.frame = self.bounds
		self.addSubview(indicator)

		let session = URLSession.shared

		let downloadTask = session.downloadTask(with: url, completionHandler: { [weak self] url, response, error in
			if error == nil && url != nil {
				if let data = try? Data(contentsOf: url!) {
					if let image = UIImage(data: data) {
						DispatchQueue.main.async {
							if let strongSelf = self {
								indicator.removeFromSuperview()
								strongSelf.image = image
							}
						}
					}
				}
			}
			})

		// After creating the download task you call resume() to start it, and then return the
		// NSURLSessionDownloadTask object to the caller. Why return it? That gives the app the opportunity
		// to call cancel() on the download task.

		downloadTask.resume()
		return downloadTask
	}
}
