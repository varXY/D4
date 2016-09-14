//
//  StoryTableView.swift
//  D4
//
//  Created by 文川术 on 4/1/16.
//  Copyright © 2016 xiaoyao. All rights reserved.
//

import UIKit

enum StoryTableViewScrollType {
	case up, down
}

protocol StoryTableViewDelegate: class {
	func didSelectedStory(_ storyIndex: Int)
}

class StoryTableView: UITableView, CoreDataAndStory {

	var storys: [Story]!

	var headerView: UIView!
	var footerView: UIView!

	var netOrLocalStory = -1

	weak var SDelegate: StoryTableViewDelegate?

	init(frame: CGRect, storys: [Story]) {
		self.storys = storys
		super.init(frame: frame, style: .plain)
		contentOffset.y = -20
		layer.cornerRadius = globalRadius
		clipsToBounds = true
		backgroundColor = UIColor.clear
		separatorStyle = .none
		dataSource = self
		delegate = self
		isExclusiveTouch = true

		headerView = UIView(frame: CGRect(x: 0, y: 0, width: ScreenWidth, height: 20))
		headerView.backgroundColor = UIColor.clear
		tableHeaderView = headerView

		footerView = UIView(frame: CGRect(x: 0, y: 0, width: ScreenWidth, height: 44))
		footerView.backgroundColor = UIColor.clear
		tableFooterView = footerView

		load100DailyStorys { (storys) in
			if storys.count != 0 { self.storys = storys }
		}
	}

	func loading(_ loading: Bool) {
		let distance: CGFloat = storys.count == 0 ? 70 : 50

		if loading && frame.origin.y == 0 {
			frame.origin.y += distance
		}

		if !loading && frame.origin.y == distance {
			UIView.animate(withDuration: 0.3, animations: {
				self.frame.origin.y -= distance
				}, completion: { (_) in
			})
		}
	}

	func insertNewStory(_ story: Story) {
		if storys.count != 0 {
			storys.insert(story, at: 0)
			let indexPath = IndexPath(row: 0, section: 0)
			scrollToRow(at: indexPath, at: .middle, animated: true)
			insertRows(at: [indexPath], with: .top)
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

	func numberOfSections(in tableView: UITableView) -> Int {
		return 1
	}

	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		let number = storys.count != 0 ? storys.count : 1
		backgroundColor = number > 9 ? UIColor.clear : MyColor.code(5).BTColors[0]
		return number
	}

	func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
		return 50
	}

	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let style = netOrLocalStory != 1 ? UITableViewCellStyle.default : UITableViewCellStyle.value1
		let reuseIdentifier = netOrLocalStory != 1 ? "DefaultCell" : "Value1Cell"
		var cell: UITableViewCell! = tableView.dequeueReusableCell(withIdentifier: reuseIdentifier)
		if cell == nil { cell = UITableViewCell(style: style, reuseIdentifier: reuseIdentifier) }
		cell.textLabel?.font = UIFont.systemFont(ofSize: 17)

		if storys.count != 0 {
			cell.selectedBackgroundView = UIView()
			cell.selectedBackgroundView?.backgroundColor = UIColor.white

			let colorCode = storys[(indexPath as NSIndexPath).row].colors[0]
			cell.backgroundColor = MyColor.code(colorCode).BTColors[0]
			cell.textLabel?.textColor = MyColor.code(colorCode).BTColors[1]
			cell.textLabel!.text = storys[(indexPath as NSIndexPath).row].sentences[0]

			cell.detailTextLabel?.text = storys[(indexPath as NSIndexPath).row].date.string(.MMddyy)
			cell.detailTextLabel?.textColor = MyColor.code(colorCode).BTColors[1]
			cell.detailTextLabel?.alpha = 0.4

		} else {
			cell = UITableViewCell(style: .default, reuseIdentifier: "EmptyCell")
			cell.backgroundColor = UIColor.clear
			cell.textLabel?.textColor = UIColor.white
			var text = "故事需要下载"
			if netOrLocalStory == 0 { text = "网络故障 无法加载" }
			if netOrLocalStory == 1 { text = "没有故事 右滑添加" }
			cell.textLabel?.text = text
			cell.textLabel?.textAlignment = .center
		}

		return cell
	}

	func tableView(_ tableView: UITableView, shouldHighlightRowAt indexPath: IndexPath) -> Bool {
		if storys.count == 0 { return false }
		let cell = tableView.cellForRow(at: indexPath)
		let colorCode = storys[(indexPath as NSIndexPath).row].colors[0]
		cell?.textLabel?.textColor = MyColor.code(colorCode).BTColors[0]
		return true
	}

	func tableView(_ tableView: UITableView, didUnhighlightRowAt indexPath: IndexPath) {
		let cell = tableView.cellForRow(at: indexPath)
		let colorCode = storys[(indexPath as NSIndexPath).row].colors[0]
		cell?.textLabel?.textColor = MyColor.code(colorCode).BTColors[1]
	}

	func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
		return storys.count != 0 ? indexPath : nil
	}

	func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		SDelegate?.didSelectedStory((indexPath as NSIndexPath).row)
		delay(seconds: 0.5) { tableView.deselectRow(at: indexPath, animated: true) }
	}

	func tableView(_ tableView: UITableView, willDeselectRowAt indexPath: IndexPath) -> IndexPath? {
		return indexPath
	}
}
