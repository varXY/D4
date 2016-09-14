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
	var mainVC: MainViewController!

	func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
		window = UIWindow(frame: UIScreen.main.bounds)
		window?.backgroundColor = UIColor.black
		window?.layer.cornerRadius = globalRadius
		window?.clipsToBounds = true

		// MARK: Shortcut

		var shouldPerformAdditionalDelegateHandling = true

		if let shortcutItem = launchOptions?[UIApplicationLaunchOptionsKey.shortcutItem] as? UIApplicationShortcutItem {
			launchedShortcutItem = shortcutItem
			shouldPerformAdditionalDelegateHandling = false
		}

		if let shortcutItems = application.shortcutItems , shortcutItems.isEmpty {
			let shortcut1 = UIApplicationShortcutItem(type: ShortcutIdentifier.First.type, localizedTitle: "写故事", localizedSubtitle: nil, icon: UIApplicationShortcutIcon(type: .add), userInfo: [
				AppDelegate.applicationShortcutUserInfoIconKey: UIApplicationShortcutIconType.play.rawValue
				])
			application.shortcutItems = [shortcut1]
		}

		// MARK: Base

		mainVC = MainViewController()
		let navi = UINavigationController(rootViewController: mainVC)
		navi.view.layer.cornerRadius = globalRadius
		window?.rootViewController = navi
		window?.makeKeyAndVisible()

		try! AVAudioSession.sharedInstance().setCategory(AVAudioSessionCategoryAmbient)

		// MARK: Network
		AVOSCloud.setApplicationId("X61IrFz0Nl3uECb2PqyN7SjL-gzGzoHsz", clientKey: "9BkN2LTqw0D8VspjK92A2tIu")
//		AVAnalytics.trackAppOpenedWithLaunchOptions(launchOptions)

		return shouldPerformAdditionalDelegateHandling
	}

	func application(_ application: UIApplication, didReceive notification: UILocalNotification) {
		if !mainVC.isViewLoaded { mainVC.viewDidLoad() }

		if mainVC.presentedViewController != nil {
			if mainVC.presentedViewController!.isKind(of: DetailViewController.self) {
				mainVC.presentedViewController?.dismiss(animated: true, completion: nil)

				if mainVC.topViewIndex != 0 {
					delay(seconds: 1.0, completion: {
						self.mainVC.gotoPage(UIBarButtonItem())
					})
				}

				return
			}
		}

		if mainVC.topViewIndex != 0 {
			mainVC.gotoPage(UIBarButtonItem())
		}


	}

	func applicationWillResignActive(_ application: UIApplication) {
	}

	func applicationDidEnterBackground(_ application: UIApplication) {
		mainVC.xyScrollView.writeView.saveContent()
	}

	func applicationWillEnterForeground(_ application: UIApplication) {
		print(application.applicationState.rawValue)
		mainVC.changeBarStyleBaseOnTime()
		mainVC.reloadDailyStory()

		let notificationEnable = UIApplication.shared.currentUserNotificationSettings!.types != UIUserNotificationType()
		if notificationEnable { mainVC.xyScrollView.settingView.savedNotificationIndex = mainVC.getNotificationIndex() }
	}

	func applicationDidBecomeActive(_ application: UIApplication) {
		guard let shortcut = launchedShortcutItem else { return }
		let _ = handleShortCutItem(shortcut)
		launchedShortcutItem = nil
	}

	func application(_ application: UIApplication, didRegister notificationSettings: UIUserNotificationSettings) {
		let notificationEnable = UIApplication.shared.currentUserNotificationSettings!.types != UIUserNotificationType()
		if notificationEnable { mainVC.xyScrollView.settingView.savedNotificationIndex = mainVC.getNotificationIndex() }
	}

	func application(_ application: UIApplication, performActionFor shortcutItem: UIApplicationShortcutItem, completionHandler: @escaping (Bool) -> Void) {
		let handledShortCutItem = handleShortCutItem(shortcutItem)
		completionHandler(handledShortCutItem)
	}

	func applicationWillTerminate(_ application: UIApplication) {
		saveContext()
		mainVC.xyScrollView.writeView.saveContent()
	}


	// MARK: Shortcut

	enum ShortcutIdentifier: String {
		case First
		case Second
		case Third

		init?(fullType: String) {
			guard let last = fullType.components(separatedBy: ".").last else { return nil }
			self.init(rawValue: last)
		}

		var type: String {
			return Bundle.main.bundleIdentifier! + ".\(self.rawValue)"
		}
	}

	static let applicationShortcutUserInfoIconKey = "applicationShortcutUserInfoIconKey"

	var launchedShortcutItem: UIApplicationShortcutItem?

	func handleShortCutItem(_ shortcutItem: UIApplicationShortcutItem) -> Bool {
		AVOSCloud.setApplicationId("X61IrFz0Nl3uECb2PqyN7SjL-gzGzoHsz", clientKey: "9BkN2LTqw0D8VspjK92A2tIu")
		AVAnalytics.trackAppOpened(launchOptions: nil)
		
		var handled = false

		guard ShortcutIdentifier(fullType: shortcutItem.type) != nil else { return false }
		guard let shortCutType = shortcutItem.type as String? else { return false }

		switch (shortCutType) {
		case ShortcutIdentifier.First.type:
			if !mainVC.isViewLoaded { mainVC.viewDidLoad() }

			if mainVC.presentedViewController != nil {
				if mainVC.presentedViewController!.isKind(of: DetailViewController.self) {
					mainVC.presentedViewController?.dismiss(animated: true, completion: nil)

					if mainVC.topViewIndex != 0 {
						delay(seconds: 1.0, completion: {
							self.mainVC.gotoPage(UIBarButtonItem())
						})
					}

					break
				}
			}

			if mainVC.topViewIndex != 0 {
				mainVC.gotoPage(UIBarButtonItem())
			}

		default:
			break
		}

		handled = true
		
		return handled
	}

	// MARK: - Core Data stack

	lazy var applicationDocumentsDirectory: URL = {
	    let urls = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
	    return urls[urls.count-1]
	}()

	lazy var managedObjectModel: NSManagedObjectModel = {
	    let modelURL = Bundle.main.url(forResource: "D4", withExtension: "momd")!
	    return NSManagedObjectModel(contentsOf: modelURL)!
	}()

	lazy var persistentStoreCoordinator: NSPersistentStoreCoordinator = {
	    let coordinator = NSPersistentStoreCoordinator(managedObjectModel: self.managedObjectModel)
	    let url = self.applicationDocumentsDirectory.appendingPathComponent("SingleViewCoreData.sqlite")
	    var failureReason = "There was an error creating or loading the application's saved data."
	    do {
	        try coordinator.addPersistentStore(ofType: NSSQLiteStoreType, configurationName: nil, at: url, options: nil)
	    } catch {
	        var dict = [String: AnyObject]()
	        dict[NSLocalizedDescriptionKey] = "Failed to initialize the application's saved data" as AnyObject?
	        dict[NSLocalizedFailureReasonErrorKey] = failureReason as AnyObject?

	        dict[NSUnderlyingErrorKey] = error as NSError
	        let wrappedError = NSError(domain: "YOUR_ERROR_DOMAIN", code: 9999, userInfo: dict)
	        NSLog("Unresolved error \(wrappedError), \(wrappedError.userInfo)")
	        abort()
	    }
	    
	    return coordinator
	}()

	lazy var managedObjectContext: NSManagedObjectContext = {
	    let coordinator = self.persistentStoreCoordinator
	    var managedObjectContext = NSManagedObjectContext(concurrencyType: .mainQueueConcurrencyType)
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

