//
//  IAPHelper.swift
//  inappragedemo
//
//  Created by Ray Fix on 5/1/15.
//  Copyright (c) 2015 Razeware LLC. All rights reserved.
//

import StoreKit

public let IAPHelperProductPurchasedNotification = "IAPHelperProductPurchasedNotification"

public typealias ProductIdentifier = String
public typealias RequestProductsCompletionHandler = (_ success: Bool, _ products: [SKProduct]) -> ()


open class IAPHelper : NSObject  {

	fileprivate let productIdentifiers: Set<ProductIdentifier>
	fileprivate var purchasedProductIdentifiers = Set<ProductIdentifier>()

	fileprivate var productsRequest: SKProductsRequest?
	fileprivate var completionHandler: RequestProductsCompletionHandler?


	public init(productIdentifiers: Set<ProductIdentifier>) {
		self.productIdentifiers = productIdentifiers
		super.init()
		SKPaymentQueue.default().add(self)
	}

	open func requestProductsWithCompletionHandler(_ handler: @escaping RequestProductsCompletionHandler) {
		completionHandler = handler
		productsRequest = SKProductsRequest(productIdentifiers: productIdentifiers)
		productsRequest?.delegate = self
		productsRequest?.start()
	}

	open func purchaseProduct(_ product: SKProduct) {
		print("Buying \(product.productIdentifier)")
		let payment = SKPayment(product: product)
		SKPaymentQueue.default().add(payment)
	}
  
	open func isProductPurchased(_ productIdentifier: ProductIdentifier) -> Bool {
		return false
	}
  
	open func restoreCompletedTransactions() {
	}

	open class func canMakePayments() -> Bool {
		return SKPaymentQueue.canMakePayments()
	}
}



extension IAPHelper: SKProductsRequestDelegate {

	public func productsRequest(_ request: SKProductsRequest, didReceive response: SKProductsResponse) {
		print("Loaded list of products")
		completionHandler!(true, response.products)
		clearRequest()

		for p in response.products {
			print("Found product: \(p.productIdentifier) \(p.localizedTitle) \(p.price.floatValue)")
		}
	}

	public func request(_ request: SKRequest, didFailWithError error: Error) {
		print("Failed to load list of products.")
		completionHandler!(false, [])
		print("Error: \(error)")
		clearRequest()
	}

	fileprivate func clearRequest() {
		productsRequest = nil
		completionHandler = nil
	}
}


extension IAPHelper: SKPaymentTransactionObserver {

	public func paymentQueue(_ queue: SKPaymentQueue, updatedTransactions transactions: [SKPaymentTransaction]) {
		for transaction in transactions {
			switch transaction.transactionState {
			case .purchased:
				completeTransaction(transaction)
				break
			case .failed:
				failedTransaction(transaction)
				break
			case .restored:
				restoreTransaction(transaction)
				break
			case .deferred:
				break
			case .purchasing:
				break
			}
		}
	}

	fileprivate func completeTransaction(_ transaction: SKPaymentTransaction) {
		print("completeTransaction...")
		provideContentForProductIdentifier(transaction.payment.productIdentifier)
		SKPaymentQueue.default().finishTransaction(transaction)
	}

	fileprivate func restoreTransaction(_ transaction: SKPaymentTransaction) {
		let productIdentifier = transaction.original?.payment.productIdentifier
		print("restoreTransaction... \(productIdentifier)")
		provideContentForProductIdentifier(productIdentifier!)
		SKPaymentQueue.default().restoreCompletedTransactions()
		SKPaymentQueue.default().finishTransaction(transaction)
	}

	fileprivate func provideContentForProductIdentifier(_ productIdentifier: String) {
		purchasedProductIdentifiers.insert(productIdentifier)
		Foundation.UserDefaults.standard.set(true, forKey: productIdentifier)
		Foundation.UserDefaults.standard.synchronize()
		NotificationCenter.default.post(name: Notification.Name(rawValue: IAPHelperProductPurchasedNotification), object: productIdentifier)
	}

	fileprivate func failedTransaction(_ transaction: SKPaymentTransaction) {
		print("failedTransaction...")
		if (transaction.error as! NSError).code != SKError.Code.paymentCancelled.rawValue {
			print("Transaction error: \(transaction.error!)")
		}
		SKPaymentQueue.default().finishTransaction(transaction)
	}
}















