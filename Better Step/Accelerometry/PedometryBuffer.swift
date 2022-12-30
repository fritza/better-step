//
//  PedometryBuffer.swift
//  Better Step
//
//  Created by Fritz Anderson on 12/30/22.
//

import Foundation

/// Receives ``StepsOnDate`` records,, and when the expected number is received, pass the completed CSV data to the client.
actor PedometryBuffer: ReportingPhase {
    typealias SuccessValue = Data
    let completion : ClosureType
    
    let capacity: Int
    var buffer  : [StepsOnDate]
    
    /// Initialize a ``PedometryBuffer`` for a given number of days, with a callback once that number of daily steps (``StepsOnDate``) are receivved.
    /// - Parameters:
    ///   - capacity: The number of days to report on
    ///   - completion: A closure accepting `Result<Data,Error>` with the data for a CSV file of the step records.
    init(capacity: Int,
         completion: @escaping ClosureType) {
        self.capacity = capacity
        buffer = []
        self.completion = completion
    }
    
    /// The complete contents of the result CSV file, as a `String`.
    private var csvContent: String {
        let lineOne = [
            "phase", "subject", "date", "Count"
        ]
            .joined(separator: ",")
        
        let csvLines =
        buffer
            .sorted()
            .map(\.csvLine)
        let concat = [lineOne] + csvLines
        return concat.joined(separator: "\r\n")
    }
    
    /// The complete contents of the result CSV file, as `Data`.
    private var csvData: Data {
        csvContent.data(using: .utf8)!
    }
    
    /// On the main actor/thread/queue, receive the completed CSV content and pass it through the client's completin closure.
    @MainActor
    private func publish() {
        Task {
            let content = await csvData
            completion(ResultValue.success(content))
        }
    }
    
    /// Add a ``StepsOnDate`` to the buffer contents. When the requisite number of days is recorded, sort the records, reduce them to CSV data, and return them (through ``publish``) to the client.
    /// - Parameter datum: <#datum description#>
    func insert(datum: StepsOnDate) {
        buffer.append(datum)
        
        if buffer.count == capacity {
            Task {
                await publish()
            }
        }
    }
}
