//
//  AppDelegate.swift
//  D4
//
//  Created by 文川术 on 3/30/16.
//  Copyright © 2016 xiaoyao. All rights reserved.
//

import UIKit
import CoreData
import AVOSCloud
import AVFoundation

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

	var window: UIWindow?

	func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
		window = UIWindow(frame: UIScreen.mainScreen().bounds)
		window?.backgroundColor = UIColor.blackColor()
		window?.layer.cornerRadius = globalRadius
		window?.clipsToBounds = true

		// MARK: Shortcut

		var shouldPerformAdditionalDelegateHandling = true

		if let shortcutItem = launchOptions?[UIApplicationLaunchOptionsShortcutItemKey] as? UIApplicationShortcutItem {
			launchedShortcutItem = shortcutItem
			shouldPerformAdditionalDelegateHandling = false
		}

		if let shortcutItems = application.shortcutItems where shortcutItems.isEmpty {
			let shortcut1 = UIApplicationShortcutItem(type: ShortcutIdentifier.First.type, localizedTitle: "写故事", localizedSubtitle: nil, icon: UIApplicationShortcutIcon(type: .Compose), userInfo: [
				AppDelegate.applicationShortcutUserInfoIconKey: UIApplicationShortcutIconType.Play.rawValue
				])
			application.shortcutItems = [shortcut1]
		}

		// MARK: Base

		let mainVC = MainViewController()
		let navi = UINavigationController(rootViewController: mainVC)
		navi.view.layer.cornerRadius = globalRadius
		window?.rootViewController = navi
		window?.makeKeyAndVisible()

		try! AVAudioSession.sharedInstance().setCategory(AVAudioSessionCategoryAmbient)

		// MARK: Network
		AVOSCloud.setApplicationId("X61IrFz0Nl3uECb2PqyN7SjL-gzGzoHsz", clientKey: "9BkN2LTqw0D8VspjK92A2tIu")
		AVAnalytics.trackAppOpenedWithLaunchOptions(launchOptions)

		return shouldPerformAdditionalDelegateHandling
	}

	func application(application: UIApplication, didReceiveLocalNotification notification: UILocalNotification) {
		print(#function)
	}

	func applicationWillResignActive(application: UIApplication) {
	}

	func applicationDidEnterBackground(application: UIApplication) {
		guard let navi = window?.rootViewController as? UINavigationController else { return }
		guard let mainVC = navi.topViewController as? MainViewController else { return }
		mainVC.xyScrollView.writeView.saveContent()
	}

	func applicationWillEnterForeground(application: UIApplication) {
		guard let navi = window?.rootViewController as? UINavigationController else { return }
		guard let mainVC = navi.topViewController as? MainViewController else { return }
		mainVC.changeBarStyleBaseOnTime()
		mainVC.reloadDailyStory()
	}

	func applicationDidBecomeActive(application: UIApplication) {
		guard let shortcut = launchedShortcutItem else { return }
		handleShortCutItem(shortcut)
		launchedShortcutItem = nil
	}

	func application(application: UIApplication, performActionForShortcutItem shortcutItem: UIApplicationShortcutItem, completionHandler: (Bool) -> Void) {
		let handledShortCutItem = handleShortCutItem(shortcutItem)
		completionHandler(handledShortCutItem)
	}

	func applicationWillTerminate(application: UIApplication) {
		saveContext()

		guard let navi = window?.rootViewController as? UINavigationController else { return }
		guard let mainVC = navi.topViewController as? MainViewController else { return }
		mainVC.xyScrollView.writeView.saveContent()
	}


	// MARK: Shortcut

	enum ShortcutIdentifier: String {
		case First
		case Second
		case Third

		init?(fullType: String) {
			guard let last = fullType.componentsSeparatedByString(".").last else { return nil }

			self.init(rawValue: last)
		}

		var type: String {
			return NSBundle.mainBundle().bundleIdentifier! + ".\(self.rawValue)"
		}
	}

	static let applicationShortcutUserInfoIconKey = "applicationShortcutUserInfoIconKey"

	var launchedShortcutItem: UIApplicationShortcutItem?

	func handleShortCutItem(shortcutItem: UIApplicationShortcutItem) -> Bool {
		AVOSCloud.setApplicationId("X61IrFz0Nl3uECb2PqyN7SjL-gzGzoHsz", clientKey: "9BkN2LTqw0D8VspjK92A2tIu")
		AVAnalytics.trackAppOpenedWithLaunchOptions(nil)
		
		var handled = false

		guard let controller = window!.rootViewController as! UINavigationController? else { return false }
		guard let mainVC = controller.viewControllers[0] as? MainViewController else { return false }

		guard ShortcutIdentifier(fullType: shortcutItem.type) != nil else { return false }

		guard let shortCutType = shortcutItem.type as String? else { return false }

		switch (shortCutType) {
		case ShortcutIdentifier.First.type:
			mainVC.viewDidLoad()
			if mainVC.presentedViewController != nil {
				mainVC.presentedViewController?.dismissViewControllerAnimated(true, completion: nil)
				delay(seconds: 0.8) { mainVC.gotoPage(UIBarButtonItem()) }
			} else {
				mainVC.gotoPage(UIBarButtonItem())
			}

		default:
			break
		}

		handled = true
		
		return handled
	}

	// MARK: - Core Data stack

	lazy var applicationDocumentsDirectory: NSURL = {
	    let urls = NSFileManager.defaultManager().URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask)
	    return urls[urls.count-1]
	}()

	lazy var managedObjectModel: NSManagedObjectModel = {
	    let modelURL = NSBundle.mainBundle().URLForResource("D4", withExtension: "momd")!
	    return NSManagedObjectModel(contentsOfURL: modelURL)!
	}()

	lazy var persistentStoreCoordinator: NSPersistentStoreCoordinator = {
	    let coordinator = NSPersistentStoreCoordinator(managedObjectModel: self.managedObjectModel)
	    let url = self.applicationDocumentsDirectory.URLByAppendingPathComponent("SingleViewCoreData.sqlite")
	    var failureReason = "There was an error creating or loading the application's saved data."
	    do {
	        try coordinator.addPersistentStoreWithType(NSSQLiteStoreType, configuration: nil, URL: url, options: nil)
	    } catch {
	        var dict = [String: AnyObject]()
	        dict[NSLocalizedDescriptionKey] = "Failed to initialize the application's saved data"
	        dict[NSLocalizedFailureReasonErrorKey] = failureReason

	        dict[NSUnderlyingErrorKey] = error as NSError
	        let wrappedError = NSError(domain: "YOUR_ERROR_DOMAIN", code: 9999, userInfo: dict)
	        NSLog("Unresolved error \(wrappedError), \(wrappedError.userInfo)")
	        abort()
	    }
	    
	    return coordinator
	}()

	lazy var managedObjectContext: NSManagedObjectContext = {
	    let coordinator = self.persistentStoreCoordinator
	    var managedObjectContext = NSManagedObjectContext(concurrencyType: .MainQueueConcurrencyType)
	    managedObjectContext.persistentStoreCoordinator = coordinator
	    return managedObjectContext
	}()

	// MARK: - Core Data Saving support

	func saveContext () {
	    if managedObjectContext.hasChanges {
	        do {
	            try managedObjectContext.save()
	        } catch {
	            let nserror = error as NSError
	            NSLog("Unresolved error \(nserror), \(nserror.userInfo)")
	            abort()
	        }
	    }
	}

}

