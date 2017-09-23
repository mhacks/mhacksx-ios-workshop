//
//  NoteViewController.swift
//  TextShare
//
//  Created by Manav Gabhawala on 9/21/17.
//  Copyright © 2017 Manav Gabhawala. All rights reserved.
//

import UIKit
import MultipeerConnectivity

private let initialData = "init".data(using: .utf8)!

class NoteViewController: UIViewController
{
	@IBOutlet var peersLabel: UILabel!

	// MARK: - View Controller Lifecycle
	override func viewDidLoad()
	{
		navigationItem.largeTitleDisplayMode = .always
	}
	override func viewWillAppear(_ animated: Bool)
	{
		super.viewWillAppear(animated)
		addKeyboardObservers()
	}
	override func viewDidDisappear(_ animated: Bool)
	{
		super.viewDidDisappear(animated)
		removeKeyboardObservers()
	}


	@objc func addPersonButtonTapped(_: UIBarButtonItem)
	{
	}
	private func updatePeersLabelText()
	{
	}
}

extension NoteViewController: MCSessionDelegate, MCBrowserViewControllerDelegate
{
	func browserViewControllerDidFinish(_ browserViewController: MCBrowserViewController)
	{
		dismiss(animated: true, completion: nil)
	}

	func browserViewControllerWasCancelled(_ browserViewController: MCBrowserViewController)
	{
		dismiss(animated: true, completion: nil)
	}

	func session(_ session: MCSession, peer peerID: MCPeerID, didChange state: MCSessionState)
	{
	}

	func session(_ session: MCSession, didReceive data: Data, fromPeer peerID: MCPeerID)
	{
		DispatchQueue.main.async {
			self.handle(data: data, recievedFrom: peerID)
		}
	}
	private func handle(data: Data, recievedFrom peerID: MCPeerID)
	{
	}

	func session(_ session: MCSession, didReceive stream: InputStream, withName streamName: String, fromPeer peerID: MCPeerID)
	{
		// Nothing
	}

	func session(_ session: MCSession, didStartReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, with progress: Progress)
	{
		// Nothing
	}

	func session(_ session: MCSession, didFinishReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, at localURL: URL?, withError error: Error?)
	{
		// Nothing
	}
}
extension NoteViewController
{
	private func addKeyboardObservers()
	{
		NotificationCenter.default.addObserver(self, selector: #selector(handleKeyboardDidChangeState), name: .UIKeyboardDidShow, object: nil)
		NotificationCenter.default.addObserver(self, selector: #selector(handleKeyboardDidChangeState), name: .UIKeyboardWillHide, object: nil)
		NotificationCenter.default.addObserver(self, selector: #selector(handleKeyboardDidChangeState), name: .UIKeyboardWillShow, object: nil)
		NotificationCenter.default.addObserver(self, selector: #selector(handleKeyboardDidChangeState), name: .UIKeyboardWillChangeFrame, object: nil)
	}
	private func removeKeyboardObservers()
	{
		NotificationCenter.default.removeObserver(self, name: .UIKeyboardWillHide, object: nil)
		NotificationCenter.default.removeObserver(self, name: .UIKeyboardWillShow, object: nil)
		NotificationCenter.default.removeObserver(self, name: .UIKeyboardWillChangeFrame, object: nil)
		NotificationCenter.default.removeObserver(self, name: .UIKeyboardDidShow, object: nil)
	}

	@objc func handleKeyboardDidChangeState(_ notification: Notification)
	{
		
		switch notification.name
		{
		case .UIKeyboardDidShow:
			// Only runs once
			NotificationCenter.default.removeObserver(self, name: .UIKeyboardDidShow, object: nil)
		case .UIKeyboardDidChangeFrame, .UIKeyboardWillShow:
			break
		case .UIKeyboardWillHide:
			break
		default:
			break
		}
	}
}
