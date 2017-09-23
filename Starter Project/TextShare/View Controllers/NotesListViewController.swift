//
//  NotesListViewController.swift
//  TextShare
//
//  Created by Manav Gabhawala on 9/21/17.
//  Copyright © 2017 Manav Gabhawala. All rights reserved.
//

import UIKit
import MultipeerConnectivity

class NotesListViewController: UIViewController
{
	@IBOutlet var tableView: UITableView!
	@IBOutlet var noNotesLabel: UILabel!


	// MARK: - View Controller Lifecycle
	override func viewDidLoad()
	{
		super.viewDidLoad()

		navigationItem.largeTitleDisplayMode = .always

	}

	override func viewWillAppear(_ animated: Bool)
	{
		super.viewWillAppear(animated)
	}

	override func viewDidDisappear(_ animated: Bool)
	{
		super.viewDidDisappear(animated)
	}

	// MARK: - Actions
	@IBAction func addNote(_: UIBarButtonItem)
	{
	}
}
extension NotesListViewController: UITableViewDataSource, UITableViewDelegate
{
	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
	{
		return 0
	}
	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
	{
		return UITableViewCell()
	}
	func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
	{
	}
	func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]?
	{
		return nil
	}
}
extension NotesListViewController: MCSessionDelegate
{
	func session(_ session: MCSession, peer peerID: MCPeerID, didChange state: MCSessionState)
	{
	}

	func session(_ session: MCSession, didReceive data: Data, fromPeer peerID: MCPeerID)
	{
		// Nothing
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
