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

	let advertiser = MCAdvertiserAssistant(serviceType: Globals.serviceName, discoveryInfo: nil, session: MCSession(peer: Globals.selfPeer))

	// MARK: - View Controller Lifecycle
	override func viewDidLoad()
	{
		super.viewDidLoad()

		navigationItem.largeTitleDisplayMode = .always

		tableView.backgroundColor = UIColor(patternImage: #imageLiteral(resourceName: "Paper Texture"))
		tableView.delegate = self
		tableView.dataSource = self
	}

	override func viewWillAppear(_ animated: Bool)
	{
		super.viewWillAppear(animated)
		toggleNoNotesLabelDisplay()
		Globals.notes.sort(by: { $0.dateModified > $1.dateModified })

		if let indexPath = tableView.indexPathForSelectedRow
		{
			transitionCoordinator?.animate(alongsideTransition: { context in
				self.tableView.deselectRow(at: indexPath, animated: animated)
			}, completion: { context in
				if context.isCancelled {
					self.tableView.selectRow(at: indexPath, animated: false, scrollPosition: .none)
				}
			})
		}
		tableView.reloadSections(IndexSet(integer: 0), with: .automatic)
		advertiser.session.delegate = self
		advertiser.start()
	}

	override func viewDidDisappear(_ animated: Bool)
	{
		super.viewDidDisappear(animated)
		advertiser.stop()
	}

	// MARK: - Actions
	@IBAction func addNote(_: UIBarButtonItem)
	{
		let controller = createNotesController()
		let note = Note(text: "", dateModified: Date())
		Globals.notes.append(note)
		controller.note = note
		navigationController?.pushViewController(controller, animated: true)
	}

	private func toggleNoNotesLabelDisplay()
	{
		noNotesLabel.isHidden = !Globals.notes.isEmpty
	}

	private func createNotesController() -> NoteViewController
	{
		let controller = storyboard!.instantiateViewController(withIdentifier: NoteViewController.description()) as! NoteViewController
		controller.delegate = self
		return controller
	}
}
extension NotesListViewController: UITableViewDataSource, UITableViewDelegate
{
	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
	{
		return Globals.notes.count
	}
	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
	{
		let cell = tableView.dequeueReusableCell(withIdentifier: NoteCell.description()) as! NoteCell
		cell.titleLabel.text = Globals.notes[indexPath.row].title
		if cell.titleLabel.text!.isEmpty
		{
			cell.titleLabel.text = "No Content"
		}
		cell.lastModifiedLabel.text = Globals.notes[indexPath.row].lastModified
		return cell
	}
	func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
	{
		let controller = createNotesController()
		controller.note = Globals.notes[indexPath.row]
		navigationController?.pushViewController(controller, animated: true)
	}
	func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]?
	{
		let action = UITableViewRowAction(style: .destructive, title: "Delete", handler: { action, indexPath in
			Globals.notes.remove(at: indexPath.row)
			tableView.deleteRows(at: [indexPath], with: .automatic)
			self.toggleNoNotesLabelDisplay()
		})
		return [action]
	}
}
extension NotesListViewController: NoteViewControllerDelegate
{
	func finished(with note: Note)
	{
		Globals.notes.sort(by: { $0.dateModified > $1.dateModified })
		tableView.reloadSections(IndexSet(integer: 0), with: .automatic)
	}
}
extension NotesListViewController: MCSessionDelegate
{
	func session(_ session: MCSession, peer peerID: MCPeerID, didChange state: MCSessionState)
	{
		print("State \(state.rawValue) for \(peerID) with name \(peerID.displayName)")
		if state == .connected
		{
			DispatchQueue.main.async {
				let controller = self.createNotesController()
				controller.note = Note(text: "", dateModified: Date())
				Globals.notes.append(controller.note)
				controller.session = session
				self.navigationController?.pushViewController(controller, animated: true)
			}
		}
	}

	func session(_ session: MCSession, didReceive data: Data, fromPeer peerID: MCPeerID)
	{
		assertionFailure("Recieved data")
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
