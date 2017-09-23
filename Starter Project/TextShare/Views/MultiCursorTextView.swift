//
//  MultiCursorTextView.swift
//  TextShare
//
//  Created by Manav Gabhawala on 9/21/17.
//  Copyright © 2017 Manav Gabhawala. All rights reserved.
//

import UIKit

class MultiCursorTextView: UITextView, UITextViewDelegate
{
	let dateLabel = UILabel()

	override init(frame: CGRect, textContainer: NSTextContainer?)
	{
		super.init(frame: frame, textContainer: textContainer)
		commonInit()
	}

	required init?(coder aDecoder: NSCoder)
	{
		super.init(coder: aDecoder)
		commonInit()
	}

	private func commonInit()
	{
		delegate = self

		textContainerInset.top += 30
		textContainerInset.left = 10
		textContainerInset.right = 10
	}


	func textViewDidChange(_ textView: UITextView)
	{

	}
	func scrollViewDidScroll(_ scrollView: UIScrollView)
	{

	}

	func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool
	{
		return true
	}
	func textViewDidChangeSelection(_ textView: UITextView)
	{

	}
}


