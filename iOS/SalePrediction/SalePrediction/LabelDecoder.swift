//
//  LabelDecoder.swift
//  SalePrediction
//
//  Created by Felipe Menezes on 09/06/25.
//
import Foundation

class LabelDecoder<T:Decodable & Equatable> {
    var classes: [T] = []

    init(_ source: String) {
        if let path = Bundle.main.path(forResource: source, ofType: "json"),
           let data = try? Data(contentsOf: URL(fileURLWithPath: path)),
           let decoded = try? JSONDecoder().decode([T].self, from: data) {
            self.classes = decoded
        }
    }

    func decode(index: Int) -> T? {
        guard index >= 0 && index < classes.count else { return nil }
        return classes[index]
    }

    func value(of value: T) -> Int32? {
        Int32(classes.indices(of: value).ranges.first?.lowerBound ?? 0)
    }
}
//
//class LabelValueDecoder {
//    private var classes: [Double] = []
//
//    init(_ source: String) {
//        if let path = Bundle.main.path(forResource: source, ofType: "json"),
//           let data = try? Data(contentsOf: URL(fileURLWithPath: path)),
//           let decoded = try? JSONDecoder().decode([Double].self, from: data) {
//            self.classes = decoded
//        }
//    }
//
//    func decode(index: Int) -> Double? {
//        guard index >= 0 && index < classes.count else { return nil }
//        return classes[index]
//    }
//
//    func value(of value: Double) -> Int32? {
//        Int32(classes.indices(of: value).ranges.first?.lowerBound ?? 0)
//    }
//}
