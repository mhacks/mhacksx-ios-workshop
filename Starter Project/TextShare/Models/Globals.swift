//
//  Globals.swift
//  TextShare
//
//  Created by Manav Gabhawala on 9/21/17.
//  Copyright © 2017 Manav Gabhawala. All rights reserved.
//

import Foundation
import UIKit
import MultipeerConnectivity

enum Globals
{
	static let documentsContainer = try! FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
	static let notesDocument = documentsContainer.appendingPathComponent("Notes.json")


	static let selfPeer = MCPeerID(displayName: UIDevice.current.name)
	static let serviceName = "textshare"
}
extension UIColor
{
	static var random: UIColor
	{
		let hue = CGFloat(arc4random() % 256) / 256 // use 256 to get full range from 0.0 to 1.0
		let saturation = CGFloat(arc4random() % 128) / 256 + 0.6 // from 0.5 to 1.0 to stay away from white
		let brightness = CGFloat(arc4random() % 128) / 256 + 0.3 // from 0.5 to 1.0 to stay away from black

		return UIColor(hue: hue, saturation: saturation, brightness: brightness, alpha: 1)
	}
}
