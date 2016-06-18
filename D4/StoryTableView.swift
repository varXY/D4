//
//  StoryTableView.swift
//  D4
//
//  Created by 文川术 on 4/1/16.
//  Copyright © 2016 xiaoyao. All rights reserved.
//

import UIKit

enum StoryTableViewScrollType {
	case Up, Down
}

protocol StoryTableViewDelegate: class {
	func didSelectedStory(storyIndex: Int)
}

class StoryTableView: UITableView, CoreDataAndStory {

	var storys: [Story]!

	var headerView: UIView!
	var footerView: UIView!

	var netOrLocalStory = -1
//	var willDisplayCellAnimate = false

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

		headerView = UIView(frame: CGRectMake(0, 0, ScreenWidth, 20))
		headerView.backgroundColor = UIColor.clearColor()
		tableHeaderView = headerView

		footerView = UIView(frame: CGRectMake(0, 0, ScreenWidth, 44))
		footerView.backgroundColor = UIColor.clearColor()
		tableFooterView = footerView

		load100DailyStorys { (storys) in
			if storys.count != 0 {
				self.storys = storys
			}
		}
	}

	override func reloadData() {
//		willDisplayCellAnimate = false
		super.reloadData()
	}

	func loading(loading: Bool) {
		let distance: CGFloat = storys.count == 0 ? 70 : 50

		if loading && frame.origin.y == 0 {
			frame.origin.y += distance
		}

		if !loading && frame.origin.y == distance {
			UIView.animateWithDuration(0.3, animations: {
				self.frame.origin.y -= distance
				}, completion: { (_) in
			})
		}
	}

	func insertNewStory(story: Story) {
		if storys.count != 0 {
			storys.insert(story, atIndex: 0)
			let indexPath = NSIndexPath(forRow: 0, inSection: 0)
			scrollToRowAtIndexPath(indexPath, atScrollPosition: .Middle, animated: true)
			insertRowsAtIndexPaths([indexPath], withRowAnimation: .Top)
		} else {
			storys.append(story)
			reloadData()
		}

	}

	required init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}

	
}

extension StoryTableView: UITableViewDataSource, UITableViewDelegate, UIScrollViewDelegate {

	func scrollViewDidScroll(scrollView: UIScrollView) {
//		willDisplayCellAnimate = scrollView.contentOffset != CGPointMake(0, 0)
	}

	func numberOfSectionsInTableView(tableView: UITableView) -> Int {
		return 1
	}

	func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		let number = storys.count != 0 ? storys.count : 1
		backgroundColor = number > 9 ? UIColor.clearColor() : MyColor.code(5).BTColors[0]
		return number
	}

	func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
		return 50
	}

	func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
		let style = netOrLocalStory != 1 ? UITableViewCellStyle.Default : UITableViewCellStyle.Value1
		let reuseIdentifier = netOrLocalStory != 1 ? "DefaultCell" : "Value1Cell"
		var cell: UITableViewCell! = tableView.dequeueReusableCellWithIdentifier(reuseIdentifier)
		if cell == nil { cell = UITableViewCell(style: style, reuseIdentifier: reuseIdentifier) }
		cell.textLabel?.font = UIFont.systemFontOfSize(17)

		if storys.count != 0 {
			cell.selectedBackgroundView = UIView()
			cell.selectedBackgroundView?.backgroundColor = UIColor.whiteColor()

			let colorCode = storys[indexPath.row].colors[0]
			cell.backgroundColor = MyColor.code(colorCode).BTColors[0]
			cell.textLabel?.textColor = MyColor.code(colorCode).BTColors[1]
			cell.textLabel!.text = storys[indexPath.row].sentences[0]

			cell.detailTextLabel?.text = storys[indexPath.row].date.string(.MMddyy)
			cell.detailTextLabel?.textColor = MyColor.code(colorCode).BTColors[1]
			cell.detailTextLabel?.alpha = 0.4

		} else {
			cell = UITableViewCell(style: .Default, reuseIdentifier: "EmptyCell")
			cell.backgroundColor = UIColor.clearColor()
			cell.textLabel?.textColor = UIColor.whiteColor()
			var text = "故事需要下载"
			if netOrLocalStory == 0 { text = "网络故障 无法加载" }
			if netOrLocalStory == 1 { text = "没有故事 右滑添加" }
			cell.textLabel?.text = text
			cell.textLabel?.textAlignment = .Center
		}

		return cell
	}

	func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
//		if willDisplayCellAnimate {
//			cell.transform = CGAffineTransformMakeScale(0.85, 0.85)
//			UIView.performSystemAnimation(.Delete, onViews: [], options: [], animations: {
//				cell.transform = CGAffineTransformIdentity
//				}, completion: nil)
//		}
	}

	func tableView(tableView: UITableView, shouldHighlightRowAtIndexPath indexPath: NSIndexPath) -> Bool {
		if storys.count != 0 {
			let cell = tableView.cellForRowAtIndexPath(indexPath)
			let colorCode = storys[indexPath.row].colors[0]
			cell?.textLabel?.textColor = MyColor.code(colorCode).BTColors[0]
			return true
		} else {
			return false
		}
	}

	func tableView(tableView: UITableView, didUnhighlightRowAtIndexPath indexPath: NSIndexPath) {
		let cell = tableView.cellForRowAtIndexPath(indexPath)
		let colorCode = storys[indexPath.row].colors[0]
		cell?.textLabel?.textColor = MyColor.code(colorCode).BTColors[1]
	}

	func tableView(tableView: UITableView, willSelectRowAtIndexPath indexPath: NSIndexPath) -> NSIndexPath? {
		return storys.count != 0 ? indexPath : nil
	}

	func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
		SDelegate?.didSelectedStory(indexPath.row)
		delay(seconds: 0.5) { 
			tableView.deselectRowAtIndexPath(indexPath, animated: true)
		}
	}

	func tableView(tableView: UITableView, willDeselectRowAtIndexPath indexPath: NSIndexPath) -> NSIndexPath? {
		return indexPath
	}
}
