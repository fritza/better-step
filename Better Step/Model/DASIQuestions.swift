//
//  DASIQuestions.swift
//  Better Step
//
//  Created by Fritz Anderson on 12/28/21.
//

import Foundation

enum AnswerState: String, Codable, Equatable {
    case unknown, yes, no
}

struct DASIQuestion: Identifiable, Codable, Comparable {
    let id: Int
    let text: String
    let identifier: String
    let score: Double

    static let questions: [DASIQuestion] = {
        guard let dasiURL = Bundle.main.url(
            forResource: "DASIQuestions", withExtension: "json") else {
            preconditionFailure("Could not find DASIQuestions.json")
        }
        let dasiData = try! Data(contentsOf: dasiURL)
        return try! JSONDecoder().decode([DASIQuestion].self, from: dasiData)
    }()

    static func with(id index: Int) -> DASIQuestion {
        precondition((0..<questions.count).contains(index),
                     "Question index \(index) out of bounds.")
        return questions[index]
    }

    static func == (lhs: DASIQuestion, rhs: DASIQuestion) -> Bool { lhs.id == rhs.id }
    static func <  (lhs: DASIQuestion, rhs: DASIQuestion) -> Bool { lhs.id <  rhs.id }
}

struct DASIResponse: Identifiable, Codable, Comparable {
    let id: Int
    let response: AnswerState

    var score: Double {
        let question = DASIQuestion.with(id: self.id)
        return (response == .yes) ? question.score : 0
    }

    static let emptyResponses: [DASIResponse] = {
        let retval =  DASIQuestion.questions
            .map { DASIResponse(id: $0.id, response: .unknown) }

        return retval
    }()

    static func == (lhs: DASIResponse, rhs: DASIResponse) -> Bool { lhs.id == rhs.id }
    static func <  (lhs: DASIResponse, rhs: DASIResponse) -> Bool { lhs.id <  rhs.id }
}

// A DASI report is an array of all DASI responses, verify it'e all IDs, all consecutive.

final class DASIReport: ObservableObject, Codable {
    let subjectID: String
    public private(set) var timestamp: Date
    public private(set) var answers: [DASIResponse]

    init(forSubject subjectID: String) {
        self.subjectID = subjectID
        timestamp = Date()
        answers = DASIResponse.emptyResponses
    }

    var score: Double {
        guard !answers.isEmpty else { return 0.0 }
        let retval = answers.reduce(0.0) { sum, response in
            return sum + response.score
        }
        return retval
    }

    func responseForQuestion(id: Int) -> AnswerState {
        guard let theResponse = answers.first(where: { $0.id == id }) else {
            return .unknown
        }
        return theResponse.response
    }

    func respondToQuestion(_ questionID: Int,
                           with state: AnswerState) {
        let newResponse = DASIResponse(id: questionID,
                                       response: state)
        answers.removeAll { $0 == newResponse }
        answers.append(newResponse)
        answers.sort()

        timestamp = Date()
    }

    func resetQuestion(id questionID: Int) {
        answers.removeAll { $0.id == questionID }
    }

    func reset() { answers.removeAll() }
}
