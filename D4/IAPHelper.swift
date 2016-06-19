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
public typealias RequestProductsCompletionHandler = (success: Bool, products: [SKProduct]) -> ()


public class IAPHelper : NSObject  {

	private let productIdentifiers: Set<ProductIdentifier>
	private var purchasedProductIdentifiers = Set<ProductIdentifier>()

	private var productsRequest: SKProductsRequest?
	private var completionHandler: RequestProductsCompletionHandler?


	public init(productIdentifiers: Set<ProductIdentifier>) {
		self.productIdentifiers = productIdentifiers
		super.init()
		SKPaymentQueue.defaultQueue().addTransactionObserver(self)
	}

	public func requestProductsWithCompletionHandler(handler: RequestProductsCompletionHandler) {
		completionHandler = handler
		productsRequest = SKProductsRequest(productIdentifiers: productIdentifiers)
		productsRequest?.delegate = self
		productsRequest?.start()
	}

	public func purchaseProduct(product: SKProduct) {
		print("Buying \(product.productIdentifier)")
		let payment = SKPayment(product: product)
		SKPaymentQueue.defaultQueue().addPayment(payment)
	}
  
	public func isProductPurchased(productIdentifier: ProductIdentifier) -> Bool {
		return false
	}
  
	public func restoreCompletedTransactions() {
	}

	public class func canMakePayments() -> Bool {
		return SKPaymentQueue.canMakePayments()
	}
}



extension IAPHelper: SKProductsRequestDelegate {

	public func productsRequest(request: SKProductsRequest, didReceiveResponse response: SKProductsResponse) {
		print("Loaded list of products")
		completionHandler!(success: true, products: response.products)
		clearRequest()

		for p in response.products {
			print("Found product: \(p.productIdentifier) \(p.localizedTitle) \(p.price.floatValue)")
		}
	}

	public func request(request: SKRequest, didFailWithError error: NSError) {
		print("Failed to load list of products.")
		completionHandler!(success: false, products: [])
		print("Error: \(error)")
		clearRequest()
	}

	private func clearRequest() {
		productsRequest = nil
		completionHandler = nil
	}
}


extension IAPHelper: SKPaymentTransactionObserver {

	public func paymentQueue(queue: SKPaymentQueue, updatedTransactions transactions: [SKPaymentTransaction]) {
		for transaction in transactions {
			switch transaction.transactionState {
			case .Purchased:
				completeTransaction(transaction)
				break
			case .Failed:
				failedTransaction(transaction)
				break
			case .Restored:
				restoreTransaction(transaction)
				break
			case .Deferred:
				break
			case .Purchasing:
				break
			}
		}
	}

	private func completeTransaction(transaction: SKPaymentTransaction) {
		print("completeTransaction...")
		provideContentForProductIdentifier(transaction.payment.productIdentifier)
		SKPaymentQueue.defaultQueue().finishTransaction(transaction)
	}

	private func restoreTransaction(transaction: SKPaymentTransaction) {
		let productIdentifier = transaction.originalTransaction?.payment.productIdentifier
		print("restoreTransaction... \(productIdentifier)")
		provideContentForProductIdentifier(productIdentifier!)
		SKPaymentQueue.defaultQueue().restoreCompletedTransactions()
		SKPaymentQueue.defaultQueue().finishTransaction(transaction)
	}

	private func provideContentForProductIdentifier(productIdentifier: String) {
		purchasedProductIdentifiers.insert(productIdentifier)
		NSUserDefaults.standardUserDefaults().setBool(true, forKey: productIdentifier)
		NSUserDefaults.standardUserDefaults().synchronize()
		NSNotificationCenter.defaultCenter().postNotificationName(IAPHelperProductPurchasedNotification, object: productIdentifier)
	}

	private func failedTransaction(transaction: SKPaymentTransaction) {
		print("failedTransaction...")
		if transaction.error?.code != SKErrorCode.PaymentCancelled.rawValue {
			print("Transaction error: \(transaction.error!)")
		}
		SKPaymentQueue.defaultQueue().finishTransaction(transaction)
	}
}















