//
//  Diff.swift
//  Diff
//
//  Created by Sam Soffes on 4/12/16.
//  Copyright © 2016 Sam Soffes. All rights reserved.
//

public func diff(_ before: String, _ after: String) -> (CountableRange<Int>, String)? {
	let result = diff(before.map({String($0)}), after.map({String($0)}))
    return result.flatMap { ($0.0, $0.1.joined()) }
}

public func diff<T: Equatable>(_ before: [T], _ after: [T]) -> (CountableRange<Int>, [T])? {
	return diff(before, after, compare: ==)
}

public func diff<T>(_ before: [T], _ after: [T], compare: (T, T) -> Bool) -> (CountableRange<Int>, [T])? {
	let beforeCount = before.count
	let afterCount = after.count

	// Find start
	var commonStart = 0
	while commonStart < beforeCount && commonStart < afterCount && compare(before[commonStart], after[commonStart]) {
		commonStart += 1
	}

	// Find end
	var commonEnd = 0
	while commonEnd + commonStart < beforeCount && commonEnd + commonStart < afterCount && compare(before[beforeCount - 1 - commonEnd], after[afterCount - 1 - commonEnd]) {
		commonEnd += 1
	}
    
    // The return of this function is the range of blocks in the 'before' that were affected and
    // the list of the items that belong in that range to replace those affected.
    // [e.g. Delete the 'range' then insert the 'affected' items to apply the changes]

	// The structure 'shrunk' since the count before and the common set after are not the same.
    // [Note: Common start + common end must always be less than or equal to the full count]
    // Note:  shrink is different than removal, since you can shrink the structure and still both remove and insert.
	if beforeCount != commonStart + commonEnd {
		let range = commonStart..<(beforeCount - commonEnd)
		let intersection = commonStart..<(afterCount - commonEnd)
		return (range, Array(after[intersection]))
	}   // The structure 'grew' since there are more blocks at the end than there were in the beginning and the 'shrink' was not detected.
        // In this case, the identified blocks are 'insertions'
	else if afterCount != commonStart + commonEnd {
		let range = commonStart..<(afterCount - commonEnd)
		return (commonStart..<commonStart, Array(after[range]))
    } else {
        // Already equal
        return nil
    }
}
