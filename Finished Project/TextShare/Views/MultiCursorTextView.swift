//
//  MultiCursorTextView.swift
//  TextShare
//
//  Created by Manav Gabhawala on 9/21/17.
//  Copyright © 2017 Manav Gabhawala. All rights reserved.
//

import UIKit

protocol MultiCursorTextViewDelegate: class
{
	func contentChanged(in textView: MultiCursorTextView, diff: Diff, string: String)
	func cursorPositionChanged(in textView: MultiCursorTextView)
}

class MultiCursorTextView: UITextView, UITextViewDelegate
{
	class Cursor
	{
		var textRange = NSRange()
		{
			didSet
			{
				updateViews()
				textView?.setNeedsDisplay()
			}
		}

		var cursorOwner: String
		let bezierPath = UIBezierPath()
		var rectForOwner = CGRect.zero
		var selectionViews = [UIView]()
		private static let selectionViewsAlpha: CGFloat = 0.3
		static let textAttributes = [NSAttributedStringKey.font: UIFont.systemFont(ofSize: 10.0), NSAttributedStringKey.foregroundColor: UIColor.white]

		weak var textView: MultiCursorTextView?

		var color: UIColor
		{
			didSet
			{
				selectionViews.forEach { $0.backgroundColor = color.withAlphaComponent(Cursor.selectionViewsAlpha) }
			}
		}


		init(cursorOwner: String, color: UIColor)
		{
			self.cursorOwner = cursorOwner
			self.color = color
		}

		func updateViews()
		{
			selectionViews.forEach { $0.removeFromSuperview() }
			selectionViews.removeAll()
			guard let layoutManager = textView?.layoutManager, let textContainer = textView?.textContainer, let inset = textView?.textContainerInset
				else { return }
			let glyphRange = layoutManager.glyphRange(forCharacterRange: textRange, actualCharacterRange: nil)
			var topRect: CGRect?
			layoutManager.enumerateEnclosingRects(forGlyphRange: glyphRange, withinSelectedGlyphRange: glyphRange, in: textContainer, using: { rect, _ in

				var frame = rect
				frame.origin.x += inset.left
				frame.origin.y += inset.top

				let alpha: CGFloat
				if glyphRange.length == 0
				{
					frame.size.width = 2.0
					alpha = 1.0
				}
				else
				{
					alpha = Cursor.selectionViewsAlpha
				}

				if topRect == nil || frame.origin.y < topRect!.origin.y
				{
					topRect = frame
				}

				let view = UIView(frame: frame)
				view.backgroundColor = self.color.withAlphaComponent(alpha)

				self.selectionViews.append(view)
			})
			self.selectionViews.forEach { textView?.addSubview($0) }

			guard let topMostRect = topRect
				else { return }

			bezierPath.removeAllPoints()
			var point = CGPoint(x: topMostRect.midX, y: topMostRect.minY)
			bezierPath.move(to: point)

			let angle = CGFloat.pi / 6 // 30 degrees
			let sideLength: CGFloat = 10.0
			let triangleHeight = sideLength * cos(angle)
			point.x -= sideLength * sin(angle)
			point.y -= triangleHeight

			bezierPath.addLine(to: point)

			point.x += sideLength

			bezierPath.addLine(to: point)
			bezierPath.close()

			let textSize = cursorOwner.size(withAttributes: Cursor.textAttributes)
			let textPadding: CGFloat = 4.0

			var textRect = CGRect(x: max(topMostRect.midX - (textSize.width / 2) - textPadding, textPadding),
			                      y: max(topMostRect.minY - triangleHeight - textSize.height - (textPadding * 2), 0),
			                      width: textSize.width + (textPadding * 2),
			                      height: textSize.height + (textPadding * 2))

			if textRect.maxX > (textView?.frame.maxX ?? CGFloat.infinity)
			{
				textRect.origin.x -= (textRect.maxX - textView!.frame.maxX)
				textRect.origin.x -= textPadding
			}

			rectForOwner = CGRect(x: textRect.minX + textPadding, y: textRect.minY + textPadding, width: textSize.width, height: textSize.height)
			let roundedRect = UIBezierPath(roundedRect: textRect, cornerRadius: textPadding)
			bezierPath.append(roundedRect)
		}
	}

	private(set) var cursors = [Cursor]()

	weak var multicursorTextViewDelegate: MultiCursorTextViewDelegate?
	let dateLabel = UILabel()
	var showCursorOwners = true
	{
		didSet
		{
			setNeedsDisplay()
		}
	}

	override init(frame: CGRect, textContainer: NSTextContainer?)
	{
		super.init(frame: frame, textContainer: textContainer)
	}

	required init?(coder aDecoder: NSCoder)
	{
		super.init(coder: aDecoder)
		commonInit()
	}

	private func commonInit()
	{
		delegate = self
		backgroundColor = UIColor(patternImage: #imageLiteral(resourceName: "Paper Texture"))

		dateLabel.translatesAutoresizingMaskIntoConstraints = false
		addSubview(dateLabel)

		NSLayoutConstraint.activate([dateLabel.topAnchor.constraint(equalTo: topAnchor, constant: 10.0), dateLabel.centerXAnchor.constraint(equalTo: centerXAnchor)])

		dateLabel.font = UIFont.preferredFont(forTextStyle: .subheadline)
		dateLabel.textColor = UIColor.gray

		textContainerInset.top += 30
		textContainerInset.left = 10
		textContainerInset.right = 10
	}

	func add(cursor: Cursor)
	{
		cursor.textView = self
		cursors.append(cursor)
	}
	func remove(cursor: Cursor)
	{
		guard let index = cursors.index(where: { $0 === cursor })
			else { return }
		cursors.remove(at: index)
	}
	func removeAllCursors()
	{
		cursors.removeAll()
	}

	override func draw(_ rect: CGRect)
	{
		super.draw(rect)

		guard showCursorOwners
			else { return }

		cursors.forEach {
			let fillColor = $0.color.withAlphaComponent(1.0)
			fillColor.setFill()
			$0.bezierPath.fill(with: .normal, alpha: 1.0)
			$0.cursorOwner.draw(in: $0.rectForOwner, withAttributes: MultiCursorTextView.Cursor.textAttributes)
		}
	}

	func textViewDidChange(_ textView: UITextView)
	{
		cursors.forEach { $0.updateViews() }
		setNeedsDisplay()
	}
	func scrollViewDidScroll(_ scrollView: UIScrollView)
	{
		cursors.forEach { $0.updateViews() }
		setNeedsDisplay()
	}

	func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool
	{
		let type: Diff.DiffType
		if range.length == 0 && !text.isEmpty
		{
			type = .add
		}
		else if range.length > 0 && text.isEmpty
		{
			type = .delete
		}
		else
		{
			type = .edit
		}

		let diff = Diff(location: range.location, length: range.length, type: type)
		multicursorTextViewDelegate?.contentChanged(in: self, diff: diff, string: text)
		return true
	}
	func textViewDidChangeSelection(_ textView: UITextView)
	{
		multicursorTextViewDelegate?.cursorPositionChanged(in: self)
	}
}


