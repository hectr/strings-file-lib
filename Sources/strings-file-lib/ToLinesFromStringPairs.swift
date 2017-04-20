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

public func toLines(from stringPairs: [StringPair]) -> [Line] {
    return stringPairs.reduce([]) { result, stringPair in
        return result + toLines(from: stringPair)
    }
}

public func toLines(from stringPairs: [[StringPair]], withConflictMarker: ConflictMarkerInfo, failOnError: Bool = false) -> [Line] {
    return stringPairs.reduce([Line]()) { result, stringPairs in
        assert(stringPairs.count <= 2)
        assert(stringPairs.count >= 1)
        if let currentPair = stringPairs.first, let otherPair = stringPairs.last, stringPairs.count == 2 {
            verbose("Reporting conflict in \(currentPair.key)")
            var ret: [Line] = result
            ret = ret + [withConflictMarker.startConflictMarker]
            ret = ret + toLines(from: currentPair)
            ret = ret + [withConflictMarker.continueConflictMarker]
            ret = ret + toLines(from: otherPair)
            ret = ret + [withConflictMarker.finishConflictMarker]
            return ret
        } else if let stringPair = stringPairs.first, stringPairs.count == 1 {
            return result
                + toLines(from: stringPair)
        } else if stringPairs.count == 0 {
            warning("Skipping empty entry", isFatalError: failOnError)
            return result
        } else {
            warning("Skipping entry with too many string-pairs (\(stringPairs.count))", isFatalError: failOnError)
            stringPairs.forEach { warning("\t- \($0.key)", isFatalError: failOnError) }
            return result
        }
    }
}
