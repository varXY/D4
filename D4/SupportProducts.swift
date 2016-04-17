//
//  SupportProducts.swift
//  P3
//
//  Created by 文川术 on 2/23/16.
//  Copyright © 2016 myname. All rights reserved.
//

import Foundation


// Use enum as a simple namespace.  (It has no cases so you can't instantiate it.)
public enum SupportProducts {

	/// TODO:  Change this to whatever you set on iTunes connect
	private static let Prefix = "com.xiaoyao.StoryOfDay."

	/// MARK: - Supported Product Identifiers
	public static let SupportOne = Prefix + "SupportOne"



	// All of the products assembled into a set of product identifiers.
	private static let productIdentifiers: Set<ProductIdentifier> = [
		SupportProducts.SupportOne,
		]

	/// Static instance of IAPHelper that for rage products.
	public static let store = IAPHelper(productIdentifiers: SupportProducts.productIdentifiers)
}

/// Return the resourcename for the product identifier.
func resourceNameForProductIdentifier(productIdentifier: String) -> String? {
	return productIdentifier.componentsSeparatedByString(".").last
}