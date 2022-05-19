//
//  USurveyQuestion.swift
//  Better Step
//
//  Created by Fritz Anderson on 5/18/22.
//

import Foundation

// MARK: - USurveyQuestion
struct USurveyQuestion: Decodable, Hashable, Comparable {
    let id      : Int
    let text    : String

    init(id: Int, text: String) {
        (self.id, self.text) = (id, text)
    }

    static func < (lhs: USurveyQuestion, rhs: USurveyQuestion) -> Bool {
        lhs.id < rhs.id
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
        hasher.combine(text)
    }

    static let all: [USurveyQuestion] = {
        let decoder = JSONDecoder()
        let jsonURL = Bundle.main.url(forResource: "USurveyQuestions", withExtension: "json")!
        let data = try! Data(contentsOf: jsonURL)
        let retval = try! decoder.decode([USurveyQuestion].self,
                                         from: data)
        return retval
    }()

    static var count: Int { all.count }

    static func question(withID target: Int) -> USurveyQuestion {
        guard let responseArrayIndex = all.firstIndex(where: {
            $0.id == target
        }) else {
            preconditionFailure("\(#function) - target ID \(target) not found.")
        }
        return all[responseArrayIndex]
    }
}

// MARK: - SurveyResponses
final class SurveyResponses: ObservableObject {
    @Published var responses: [USurveyResponse] = []
    init() {
        responses = (1...USurveyQuestion.count)
            .map { USurveyResponse(id: $0) }
    }

    func respond(to id: Int, with answer: Int?) {
        guard let responseArrayIndex = responses.firstIndex(where: {
            $0.id == id
        }),
              (0..<USurveyQuestion.count).contains(responseArrayIndex)
        else {
            fatalError("\(#function) - id \(id) should have an index in (0..<\(USurveyQuestion.count))")
        }
        guard let answer = answer else {
            fatalError("\(#function) - nil answer")
        }

        let targetRange = (responseArrayIndex...responseArrayIndex)
        let newResponse = responses[responseArrayIndex]
            .with(answer: answer)
        responses.replaceSubrange(targetRange, with: [newResponse])
    }
}

// MARK: - USurveyResponse
/// A numeric response to this survey question.
///
/// The `id` in the pair is the user/recipient-assigned identifier for the question, not whatever index it might have in an array of questions.
struct USurveyResponse: Codable, Hashable, Comparable {
    let id       : Int
    let response : Int?

    init(id: Int, response: Int? = nil) {
        (self.id, self.response) = (id, response)
    }

    static func < (lhs: USurveyResponse, rhs: USurveyResponse) -> Bool {
        lhs.id < rhs.id
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
        hasher.combine(response)
    }

    func with(answer: Int) -> USurveyResponse {
        USurveyResponse(id: id, response: answer)
    }
    // So response
}





