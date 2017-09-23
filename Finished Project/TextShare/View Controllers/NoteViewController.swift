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

protocol NoteViewControllerDelegate: class
{
	func finished(with note: Note)
}

class NoteViewController: UIViewController
{
	var note: Note!
	weak var delegate: NoteViewControllerDelegate?

	var cursors = [MCPeerID: MultiCursorTextView.Cursor]()

	@IBOutlet var textView: MultiCursorTextView!
	@IBOutlet var peersLabel: UILabel!
	
	var session: MCSession!
	{
		didSet { session.delegate = self }
	}

	// MARK: - View Controller Lifecycle
	override func viewDidLoad()
	{
		navigationItem.largeTitleDisplayMode = .always
		navigationItem.title = note.title

		if session == nil
		{
			navigationItem.rightBarButtonItem = UIBarButtonItem(image: #imageLiteral(resourceName: "Add Person"), style: .plain, target: self, action: #selector(addPersonButtonTapped(_:)))
			session = MCSession(peer: Globals.selfPeer)

		}
		else
		{
			if let peer = session.connectedPeers.first
			{
				_ = try? session.send(initialData, toPeers: [peer], with: .reliable)
			}
		}

		textView.multicursorTextViewDelegate = self
		textView.text = note.text
		textView.dateLabel.text = note.detailedLastModified
	}
	override func viewWillAppear(_ animated: Bool)
	{
		super.viewWillAppear(animated)
		addKeyboardObservers()
		updatePeersLabelText()
	}
	override func viewDidDisappear(_ animated: Bool)
	{
		super.viewDidDisappear(animated)
		note.text = textView.text
		delegate?.finished(with: note)
		session.disconnect()
		removeKeyboardObservers()
	}

	private func removeAllCursors()
	{
		textView.removeAllCursors()
		cursors.removeAll()
	}

	@objc func addPersonButtonTapped(_: UIBarButtonItem)
	{
		let browser = MCBrowserViewController(serviceType: Globals.serviceName, session: session)
		browser.delegate = self
		present(browser, animated: true, completion: nil)
	}
	private func updatePeersLabelText()
	{
		let text: String
		switch session.connectedPeers.count
		{
		case 0:
			text = "Offline"
			removeAllCursors()
		case 1:
			text = "1 Peer"
		default:
			text = "\(session.connectedPeers.count) Peers"
		}
		DispatchQueue.main.async {
			self.peersLabel.text = text
		}
	}
}
extension NoteViewController: MultiCursorTextViewDelegate
{
	private func updateNote()
	{
		note.text = textView.text
		note.dateModified = Date()

		DispatchQueue.main.async {
			self.navigationItem.title = self.note.title
			self.textView.dateLabel.text = self.note.detailedLastModified
		}
	}
	func contentChanged(in textView: MultiCursorTextView, diff: Diff, string: String)
	{
		updateNote()
		if !session.connectedPeers.isEmpty
		{
			_ = try? session.send(diff.data + string.data(using: .utf8)!, toPeers: session.connectedPeers, with: .reliable)
		}

	}

	func cursorPositionChanged(in textView: MultiCursorTextView)
	{
		let diff = Diff(location: textView.selectedRange.location, length: textView.selectedRange.length, type: .cursor)
		if !session.connectedPeers.isEmpty
		{
			_ = try? session.send(diff.data, toPeers: session.connectedPeers, with: .reliable)
		}
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
		updatePeersLabelText()
		if state == .connected
		{
			let cursor = MultiCursorTextView.Cursor(cursorOwner: String(peerID.displayName.split(separator: " ").first ?? "Unknown"), color: UIColor.random)
			cursors[peerID] = cursor
			textView?.add(cursor: cursor)
		}
		else if state == .notConnected
		{
			guard let cursor = cursors[peerID]
				else { return }
			textView?.remove(cursor: cursor)
			cursors[peerID] = nil
		}
	}

	func session(_ session: MCSession, didReceive data: Data, fromPeer peerID: MCPeerID)
	{
		DispatchQueue.main.async {
			self.handle(data: data, recievedFrom: peerID)
		}
	}
	private func handle(data: Data, recievedFrom peerID: MCPeerID)
	{
		guard data != initialData
		else {
			let text = textView.text!
			let initialDiff = Diff(location: 0, length: text.count, type: .add)
			_ = try? session.send(initialDiff.data + text.data(using: .utf8)!, toPeers: [peerID], with: .reliable)
			return
		}
		let diff = Diff(data)
		let string = String(data: data[MemoryLayout<Diff>.size...], encoding: .utf8) ?? ""
		switch diff.type
		{
		case .add:
			textView.textStorage.replaceCharacters(in: NSRange(location: diff.location, length: 0), with: string)
		case .delete:
			textView.textStorage.replaceCharacters(in: NSRange(location: diff.location, length: diff.length), with: "")
		case .edit:
			textView.textStorage.replaceCharacters(in: NSRange(location: diff.location, length: diff.length), with: string)
		case .cursor:
			if cursors[peerID] == nil
			{
				session(session, peer: peerID, didChange: .connected)
			}
			cursors[peerID]?.textRange = NSRange(location: diff.location, length: diff.length)
		}

		textView.font = UIFont.preferredFont(forTextStyle: .body)

		if diff.type != .cursor
		{
			updateNote()
		}

		// Cursor updates
		if textView.selectedRange.location != NSNotFound && diff.location < (textView.selectedRange.location + textView.selectedRange.length)
		{
			let selected = textView.selectedRange.location..<(textView.selectedRange.location + textView.selectedRange.length)
			let diffRange = diff.location..<(diff.location + diff.length)
			if diff.type == .add
			{
				if diffRange.startIndex < selected.startIndex
				{
					textView.selectedRange.location += diff.length
				}
				else
				{
					textView.selectedRange.length += diff.length
				}
			}
			else if diff.type == .delete
			{
				if diffRange.endIndex < selected.startIndex
				{
					textView.selectedRange.location -= diff.length
				}
				else if diffRange.startIndex < selected.startIndex
				{
					textView.selectedRange.location = diffRange.startIndex
					textView.selectedRange.length = 0
				}
				else
				{
					textView.selectedRange.length = 0
				}
			}
			else if diff.type == .edit && diff.length != string.count
			{
				if diffRange.endIndex < selected.startIndex
				{
					textView.selectedRange.location += (string.count - diff.length)
				}
				else
				{
					textView.selectedRange.location = diffRange.startIndex
					textView.selectedRange.length = 0
				}
			}
			textView.setNeedsDisplay()
		}
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
		guard let keyboardEndFrame = notification.userInfo?[UIKeyboardFrameEndUserInfoKey] as? CGRect else { return }
		let keyboardFrame = self.view.convert(keyboardEndFrame, from: self.view.window)

		switch notification.name
		{
		case .UIKeyboardDidShow:
			// Only runs once
			NotificationCenter.default.removeObserver(self, name: .UIKeyboardDidShow, object: nil)
		case .UIKeyboardDidChangeFrame, .UIKeyboardWillShow:
			if (keyboardFrame.origin.y + keyboardFrame.size.height) > view.frame.size.height
			{
				textView.contentInset.bottom = 0.0
			}
			else
			{
				textView.contentInset.bottom = keyboardEndFrame.height
			}
		case .UIKeyboardWillHide:
			textView.contentInset.bottom = 0.0
		default:
			break
		}
		textView.scrollIndicatorInsets = textView.contentInset
	}
}
