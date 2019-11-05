//
//  NavigationController.swift
//  CarList
//
//  Created by Иван Медведев on 10/10/2019.
//  Copyright © 2019 Medvedev. All rights reserved.
//

import UIKit

final class GradientNavigationController: UINavigationController
{

	override func viewDidLoad() {
		super.viewDidLoad()
	}

	func setGradient(size: CGSize) {
		let gradient = CAGradientLayer()
		gradient.startPoint = CGPoint(x: 0, y: 0)
		gradient.endPoint = CGPoint(x: 0, y: 1)
		gradient.colors = [
			UIColor(red: 9 / 255, green: 48 / 255, blue: 40 / 255, alpha: 1.0).cgColor,
			UIColor( red: 35 / 255, green: 122 / 255, blue: 87 / 255, alpha: 1.0).cgColor,
		]
		var frame = CGRect()
		frame.origin.y = 0
		frame.origin.x = 0
		frame.size.height = size.height
		frame.size.width = size.width
		gradient.frame = frame
		UIGraphicsBeginImageContext(gradient.frame.size)
		//swiftlint:disable:next force_unwrapping
		gradient.render(in: UIGraphicsGetCurrentContext()!)
		let outputImage = UIGraphicsGetImageFromCurrentImageContext()
		UIGraphicsEndImageContext()
		if let outputImage = outputImage {
			self.navigationBar.barTintColor = UIColor(patternImage: outputImage)
		}
		else {
			return
		}
	}

	func updateGradient() {
		let navBarHeight = self.navigationBar.frame.size.height
		let statusBarHeight = UIApplication.shared.statusBarFrame.height
		let heightAdjustment: CGFloat = 2
		let gradientHeight = navBarHeight + statusBarHeight + heightAdjustment
		self.setGradient(size: CGSize(width: UIScreen.main.bounds.size.width, height: gradientHeight))
	}
}
