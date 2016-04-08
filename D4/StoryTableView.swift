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
	func showOrHideToolbar(show: Bool)
	func didSelectedStory(storyIndex: Int, touchPoint: CGPoint)
}

class StoryTableView: UITableView {

	var storys: [Story]!

	var touchPoint: CGPoint!

	var headerView: UIView!

	weak var SDelegate: StoryTableViewDelegate?

	init(frame: CGRect, storys: [Story]) {
		self.storys = storys
		super.init(frame: frame, style: .Plain)
		contentOffset.y = -20
		layer.cornerRadius = globalRadius
		clipsToBounds = true
		backgroundColor = UIColor.clearColor()
		separatorStyle = .None
		dataSource = self
		delegate = self
		exclusiveTouch = true

		let headerView = UIView(frame: CGRectMake(0, 0, ScreenWidth, 20))
		headerView.backgroundColor = UIColor.clearColor()
		tableHeaderView = headerView
	}

	override func touchesShouldBegin(touches: Set<UITouch>, withEvent event: UIEvent?, inContentView view: UIView) -> Bool {
		guard let touch = touches.first else { return false }
		
		touchPoint = touch.locationInView(self)
		return true
	}

	func loading(loading: Bool) {
		if loading {
			self.frame.origin.y += 30

		} else {
			UIView.animateWithDuration(0.3, animations: {
				self.frame.origin.y -= 30
				}, completion: { (_) in
			})

		}
	}

	func insertNewStory(story: Story) {
		storys.insert(story, atIndex: 0)
		let indexPath = NSIndexPath(forRow: 0, inSection: 0)
		scrollToRowAtIndexPath(indexPath, atScrollPosition: .Middle, animated: true)
		
//		beginUpdates()
		insertRowsAtIndexPaths([indexPath], withRowAnimation: .Top)
//		endUpdates()
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
		cell.selectedBackgroundView = UIView()
		cell.selectedBackgroundView?.backgroundColor = UIColor.whiteColor()

		let colorCode = storys[indexPath.row].colors[0]
		cell.backgroundColor = MyColor.code(colorCode).BTColors[0]
		cell.textLabel?.textColor = MyColor.code(colorCode).BTColors[1]
		cell.textLabel!.text = storys[indexPath.row].sentences[0]
		
		return cell
	}

	func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {

	}

	func tableView(tableView: UITableView, shouldHighlightRowAtIndexPath indexPath: NSIndexPath) -> Bool {
		let cell = tableView.cellForRowAtIndexPath(indexPath)
		let colorCode = storys[indexPath.row].colors[0]
		cell?.textLabel?.textColor = MyColor.code(colorCode).BTColors[0]
		return true
	}

	func tableView(tableView: UITableView, didUnhighlightRowAtIndexPath indexPath: NSIndexPath) {
		let cell = tableView.cellForRowAtIndexPath(indexPath)
		let colorCode = storys[indexPath.row].colors[0]
		delay(seconds: 0.5) {
			cell?.textLabel?.alpha = 0.0
			cell!.textLabel?.textColor = MyColor.code(colorCode).BTColors[1]

			UIView.animateWithDuration(0.3, animations: {
				cell?.textLabel?.alpha = 1.0
			})
		}
	}

	func tableView(tableView: UITableView, willSelectRowAtIndexPath indexPath: NSIndexPath) -> NSIndexPath? {

		return indexPath
	}

	func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
		SDelegate?.didSelectedStory(indexPath.row, touchPoint: touchPoint)
		delay(seconds: 0.5) { 
			tableView.deselectRowAtIndexPath(indexPath, animated: true)
		}
	}

	func tableView(tableView: UITableView, willDeselectRowAtIndexPath indexPath: NSIndexPath) -> NSIndexPath? {

		return indexPath
	}
}

extension StoryTableView: UIScrollViewDelegate {

	func scrollViewWillEndDragging(scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
			let translation = self.panGestureRecognizer.translationInView(self.superview)
			if translation.y < -20 {
				SDelegate?.showOrHideToolbar(true)
			} else if translation.y > 20{
				SDelegate?.showOrHideToolbar(false)
			}

	}

}