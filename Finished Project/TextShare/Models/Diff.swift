//
//  Diff.swift
//  TextShare
//
//  Created by Manav Gabhawala on 9/21/17.
//  Copyright © 2017 Manav Gabhawala. All rights reserved.
//

import Foundation

struct Diff
{
	enum DiffType: UInt8
	{
		case add = 0
		case delete
		case edit
		case cursor
	}

	var location: Int
	var length: Int
	var type: DiffType

	var data: Data
	{
		var buffer = Array<UInt8>(repeating: 0, count: MemoryLayout<Diff>.size)
		var copy = self
		copy.length = copy.length.bigEndian
		copy.location = copy.location.bigEndian
		memcpy(&buffer, &copy, MemoryLayout<Diff>.size)
		return Data(bytes: buffer)
	}
}
extension Diff
{
	init(_ data: Data)
	{
		assert(data.count >= MemoryLayout<Diff>.size)
		location = 0
		length = 0
		type = .add
		data.withUnsafeBytes { (pointer: UnsafePointer<Diff>) in
			location = Int(bigEndian: pointer.pointee.location)
			length = Int(bigEndian: pointer.pointee.length)
			type = pointer.pointee.type
		}
	}
}
