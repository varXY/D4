//
//  ViewController.swift
//  D4
//
//  Created by 文川术 on 3/30/16.
//  Copyright © 2016 xiaoyao. All rights reserved.
//

import UIKit
import AVOSCloud

class ViewController: UIViewController {

	var testView: TestView!

	override func viewDidLoad() {
		super.viewDidLoad()
		view.backgroundColor = UIColor.whiteColor()
		
		testView = TestView(frame: view.bounds)
		view.addSubview(testView)

	}

	override func viewWillAppear(animated: Bool) {
		super.viewWillAppear(animated)

	}


	

}

