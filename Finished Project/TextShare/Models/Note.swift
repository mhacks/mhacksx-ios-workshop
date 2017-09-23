//
//  Note.swift
//  TextShare
//
//  Created by Manav Gabhawala on 9/21/17.
//  Copyright © 2017 Manav Gabhawala. All rights reserved.
//

import Foundation

class Note: Codable
{
	var text: String
	var dateModified: Date

	var title: String
	{
		var title = ""
		text.enumerateSubstrings(in: text.startIndex..<text.endIndex, options: .bySentences, { sentence, sentenceRange, enclosingRange, stop in
			title = sentence ?? title
			stop = true
		})
		return title
	}

	var lastModified: String
	{
		let formatter = DateFormatter()
		if Calendar.current.isDateInToday(dateModified)
		{
			formatter.timeStyle = .short
		}
		else
		{
			formatter.dateStyle = .short
			formatter.doesRelativeDateFormatting = true
		}
		return formatter.string(from: dateModified)
	}

	var detailedLastModified: String
	{
		let formatter = DateFormatter()
		formatter.timeStyle = .short
		formatter.dateStyle = .short
		formatter.doesRelativeDateFormatting = true
		return formatter.string(from: dateModified)
	}

	init(text: String, dateModified: Date)
	{
		self.text = text
		self.dateModified = dateModified
	}
}
