//
//  EncodeHelper.swift
//  Whiteboard
//
//  Created by JJAYCHEN on 2020/6/1.
//

import Foundation

extension String {
    func encodeToCalendarID() -> String {
        let encodeDictionary: [String: String] = [
            "0": "A",
            "1": "t",
            "2": "M",
            "3": "x",
            "4": "n",
            "5": "U",
            "6": "e",
            "7": "d",
            "8": "2",
            "9": "7",
            "10": "Y",
            "11": "r",
            "12": "i",
            "13": "P",
            "14": "q",
            "15": "s",
            "16": "5",
            "17": "b",
            "18": "9",
            "19": "f",
        ]
        var result = ""

        if let lastCharacter = self.last,
            let lastValue = Int(String(lastCharacter)) {
            for i in self.indices {
                if let iValue = Int(self[i...i]) {
                    let mappedString = String(iValue + lastValue)
                    result.append(encodeDictionary[mappedString]!)
                }
            }
        }

        return result
    }

    func decodeToID() -> String {
        let decodeDictionary: [String: String] = [
            "A": "0",
            "t": "1",
            "M": "2",
            "x": "3",
            "n": "4",
            "U": "5",
            "e": "6",
            "d": "7",
            "2": "8",
            "7": "9",
            "Y": "10",
            "r": "11",
            "i": "12",
            "P": "13",
            "q": "14",
            "s": "15",
            "5": "16",
            "b": "17",
            "9": "18",
            "f": "19",
        ]
        var result = ""

        if let lastCharacter = self.last,
            let lastMappedString = decodeDictionary[String(lastCharacter)],
            let lastValue = Int(lastMappedString) {
            let offset = lastValue / 2
            for i in self.indices {
                if let mappedString = decodeDictionary[String(self[i...i])],
                    let mappedValue = Int(mappedString) {
                    let realValue = mappedValue - offset
                    result.append(String(realValue))
                }
            }
        }

        return result
    }
}
