//
//  Prediction.swift
//  SalePrediction
//
//  Created by Felipe Menezes on 20/05/25.
//

import TensorFlowLite

enum SalePredictionError: Error {
    case sellerEncodedNotFound
    case cityEncodedNotFound
    case predictionError(Error)
}

let daysOfWeek = [
    "Sunday", "Monday", "Tuesday", "Wednesday",
    "Thursday", "Friday", "Saturday"
]
struct DataSource {
    static var shared = DataSource()
    private init() {}
    let sellers: [SellerObj] = LabelDecoder<SellerObj>("seller_table").classes
    let sellerEncoded = LabelDecoder<String>("seller_classes")
    let priceEncoded = LabelDecoder<Double>("price_classes")
    let cityEncoded = LabelDecoder<String>("seller_city_classes")
    let paymetTypes = [
        "credit_card": 0,
        "boleto": 1,
        "voucher": 2,
        "debit_card": 3
    ]
}

class SalePrediction: ObservableObject {
    private let modelName = "modelo_recomendacao"
    private var interpreter: Interpreter
    private let source = DataSource.shared
    init() {
        let modelPath = Bundle.main.path(forResource: modelName, ofType: "tflite")!
        do {
            interpreter = try Interpreter(modelPath: modelPath)
            try interpreter.allocateTensors()
        } catch {
            fatalError("could not open model \(error)")
        }
    }

    func predict(sellerId: String,
                 hour: Int,
                 dayOfWeek: Int,
                 city: String,
                 payment: Int) throws -> [Double] {
        do {
            guard let sellerId = source.sellerEncoded.value(of: sellerId) else { throw SalePredictionError.sellerEncodedNotFound }
            guard let cityId = source.cityEncoded.value(of: city) else { throw SalePredictionError.cityEncodedNotFound  }
            print("sellerID: \(sellerId), cityId: \(cityId)")
            
            let inputs: [[Float32]] = [
                [Float32(payment)],
                [Float32(hour)],
                [Float32(sellerId)],
                [Float32(dayOfWeek)],
                [Float32(cityId)]
            ]
            for (i, inputArray) in inputs.enumerated() {
                let inputData = Data(copyingBufferOf: inputArray)
                try interpreter.copy(inputData, toInputAt: i)
            }
            
            try interpreter.invoke()
            let outputTensor = try interpreter.output(at: 0)
            let probabilities: [Float32] = outputTensor.data.toArray(type: Float32.self)
            //print("prob: \(probabilities)")
            let topN = 3
            let sortedIndices = probabilities
                .enumerated()
                .sorted(by: { $0.element > $1.element })
                .prefix(topN)
                .map { $0.offset }

            let decodedValues = sortedIndices.compactMap { source.priceEncoded.decode(index: $0) }
            return decodedValues
        } catch {
           throw SalePredictionError.predictionError(error)
        }
    }
}

extension Data {
    init<T>(copyingBufferOf array: [T]) {
        self = array.withUnsafeBufferPointer {
            Data(buffer: $0)
        }
    }

    func toArray<T>(type: T.Type) -> [T] where T: Numeric {
        let count = self.count / MemoryLayout<T>.stride
        return self.withUnsafeBytes {
            Array(UnsafeBufferPointer<T>(start: $0.bindMemory(to: T.self).baseAddress!, count: count))
        }
    }
}
