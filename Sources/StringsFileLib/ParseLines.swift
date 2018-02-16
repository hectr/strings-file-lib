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
import RegexMatcher

public func parse(lines: [Line], skipInvalidLines: Bool = true) throws -> [StringPair] {
    var tokens = [StringPair]()
    var iterator = lines.makeIterator()
    var nextLine = iterator.next()
    var lastComment: Comment? = nil
    while nextLine != nil {
        guard let line = nextLine else { break }
        guard !line.isEmpty else { nextLine = iterator.next(); continue }
        if let comment = parse(comment: line, iterator: iterator) {
            if let lastComment = lastComment {
                if skipInvalidLines {
                    log("Replacing previous comment with: \(comment)")
                    log("\t- previous comment: \(lastComment)")
                } else {
                    throw buildError(.unsupportedMultiLineCommentError)
                }
            }
            lastComment = comment
        } else if let stringPair = parse(stringPair: line, comment: lastComment) {
            lastComment = nil
            tokens.append(stringPair)
        } else {
            if skipInvalidLines {
                verbose("Discarding line: \(line)")
            } else {
                throw buildError(.invalidLineError)
            }
        }
        nextLine = iterator.next()
    }
    return tokens
}

private func isEmpty(line: Line) -> Bool {
    let trimmedLine = line.trimmingCharacters(in: CharacterSet.whitespaces)
    return trimmedLine.characters.count == 0
}

private func parse(comment line: Line, iterator: IndexingIterator<[Line]>) -> Comment? {
    var comment: Comment? = nil
    let trimmedLine = line.trimmingCharacters(in: CharacterSet.whitespaces)
    if trimmedLine.hasPrefix("/") {
        if trimmedLine.hasPrefix("//") {
            log("Skipping comment candidate: \(trimmedLine)")
            log("\t- single-line comments are not supported")
        } else if trimmedLine.hasPrefix("/*") {
            if trimmedLine.hasSuffix("*/") {
                comment = trimmedLine
            } else {
                // FIXME: support multi-line comments
                log("Skipping comment candidate: \(trimmedLine)")
                log("\t- multi-line comments are not supported")
            }
        } else {
            log("Skipping comment candidate: \(trimmedLine)")
            log("\t- invlid comment prefix")
        }
    }
    return comment
}

private let stringPairRegex: Regex = "\\\"(?:\\\\\\\"|[^\\\"])*\\\"[:space:]*=[:space:]*\\\"(?:\\\\\\\"|[^\\\"])*\\\"[:space:]*;"
private let quotedStringRegex: Regex = "\\\"(?:\\\\\\\"|[^\\\"])*\\\""

private func parse(stringPair line: Line, comment: Comment? = nil) -> StringPair? {
    var pair: StringPair? = nil
    let trimmedLine = line.trimmingCharacters(in: CharacterSet.whitespaces)
    if trimmedLine.hasPrefix("\"") {
        if trimmedLine.hasSuffix(";")  {
            if stringPairRegex.matches(in: trimmedLine).count == 1 {
                let matches = quotedStringRegex.matches(in: trimmedLine)
                if let key = matches.first?.value, let value = matches.last?.value, matches.count == 2 {
                    pair = StringPair(key: key, value: value, comment: comment)
                } else {
                    log("Skipping string candidate: \(trimmedLine)")
                    log("\t- not matching string-pair regex")
                }
            } else {
                log("Skipping string candidate: \(trimmedLine)")
                log("\t- not matching full line regex")
            }
        } else {
            log("Skipping string candidate: \(trimmedLine)")
            log("\t- missing semicolon")
        }
    }
    return pair
}
