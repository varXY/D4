//
//  StoryTableView.swift
//  D4
//
//  Created by 文川术 on 4/1/16.
//  Copyright © 2016 xiaoyao. All rights reserved.
//

import Foundation
import UIKit

enum StoryTableViewScrollType {
	case Up, Down
}

protocol StoryTableViewDelegate: class {
	func storyTableViewDidScroll(scrollType: StoryTableViewScrollType)
}

class StoryTableView: UITableView {

	var storys: [Story] {
		didSet {
			reloadData()
		}
	}

	weak var customDelegate: StoryTableViewDelegate?

	init(frame: CGRect, storys: [Story]) {
		self.storys = storys
		super.init(frame: frame, style: .Plain)
		contentOffset.y = -20
		backgroundColor = UIColor.clearColor()
		separatorStyle = .None
		dataSource = self
		delegate = self
		exclusiveTouch = true

	}

	required init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}

	
}

extension StoryTableView: UITableViewDataSource, UITableViewDelegate {

	func numberOfSectionsInTableView(tableView: UITableView) -> Int {
		return 1
	}

	func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return storys.count
	}

	func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
		return 50
	}

	func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
		let cell = UITableViewCell(style: .Default, reuseIdentifier: "cell")
		let colorCode = storys[indexPath.row].colors[0]
		cell.backgroundColor = MyColor.code(colorCode).BTColors[0]
		cell.textLabel?.textColor = MyColor.code(colorCode).BTColors[1]
		let date = storys[indexPath.row].date
		let string = dateFormatter.stringFromDate(date)
		cell.textLabel!.text = string

		return cell
	}
}

extension StoryTableView: UIScrollViewDelegate {

	func scrollViewWillEndDragging(scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
			let translation = scrollView.panGestureRecognizer.translationInView(scrollView.superview)
			if translation.y < -20 {
				customDelegate?.storyTableViewDidScroll(.Down)
			} else if translation.y > 20{
				customDelegate?.storyTableViewDidScroll(.Up)
			}

	}

}