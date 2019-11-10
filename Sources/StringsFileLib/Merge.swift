// Copyright (c) 2017 Hèctor Marquès Ranea
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.

import Foundation

public func merge(_ filesStrings: FilesStrings, into resultPath: Pathname) throws -> MergeResult {
    var hasConflicts    = false
    var result          = [[StringPair]]()
    
    let ancestor = try toDictionary(from: filesStrings.ancestor)
    let current  = try toDictionary(from: filesStrings.current)
    let other    = try toDictionary(from: filesStrings.other)

    var allKeys = Set<String>()
    ancestor.forEach { allKeys.insert($0.key) }
    current.forEach  { allKeys.insert($0.key) }
    other.forEach    { allKeys.insert($0.key) }
    let sortedKeys = allKeys.sorted { $0.localizedCaseInsensitiveCompare($1) == .orderedAscending }
    sortedKeys.forEach { key in
        let ancestorPair = ancestor[key]
        let currentPair  = current[key]
        let otherPair    = other[key]
        
        let ancestorValue = ancestorPair?.value
        let currentValue  = currentPair?.value
        let otherValue    = otherPair?.value
        
        if currentValue == otherValue {
            if let currentPair = currentPair, let otherPair = otherPair {
                if currentPair.comment == ancestorPair?.comment {
                    result.append([otherPair])
                } else if otherPair.comment == ancestorPair?.comment {
                    result.append([currentPair])
                } else if currentPair.comment == otherPair.comment {
                    result.append([currentPair])
                } else {
                    verbose("Discarding 'other' comment: \(otherPair.comment ?? "")")
                    verbose("\t- key: \(currentPair.key)")
                    verbose("\t- 'current' comment: \(currentPair.comment ?? "")")
                    result.append([currentPair])
                }
                
            } else if let resultPair = currentPair ?? otherPair {
                result.append([resultPair])
            } else {
                verbose("Removing string: \(key)")
            }
        } else if currentValue == ancestorValue {
            if let resultPair = otherPair {
                result.append([resultPair])
            } else {
                verbose("Removing string from 'current': \(key)")
            }
        } else if otherValue == ancestorValue {
            if let resultPair = currentPair {
                result.append([resultPair])
            } else {
                verbose("Removing string from 'other': \(key)")
            }
        } else {
            hasConflicts = true
            result.append([ currentPair ?? StringPair(key: "", value: "", comment: ""),
                            otherPair ?? StringPair(key: "", value: "", comment: "")])
        }
    }
    let mergeResult = MergeResult(
        isConflict: hasConflicts,
        stringPairs: result,
        path: resultPath)
    return mergeResult
}
