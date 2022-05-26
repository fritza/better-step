//
//  DASIQuestion+CoreDataClass.swift
//  mommk
//
//  Created by Fritz Anderson on 4/11/22.
//
//

import Foundation
import CoreData

/*
 You use refreshObject:mergeChanges: to manually refresh the properties—this causes the fetch request associated with this property to be executed again when the object fault is next fired.

 JUST USE THE FETCH TEMPLATES (.response)
 */

/// A decodable element of the input DASI-question `.json` file.
struct JSONQuestion: Decodable, Comparable, Hashable {
    public var id   : Int32
    public let text : String
    public let score: Double

    static func < (lhs: JSONQuestion, rhs: JSONQuestion) -> Bool {
        return lhs.id < rhs.id
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
        hasher.combine(text)
        hasher.combine(score)
    }
}

/// Managed object representation of a static question.
/// - note: This should be immutable under use. `mommk` creates a store that will be read-only when used.
@objc(DASIQuestion)
public class DASIQuestion: NSManagedObject {
    /// The `DASIResponse` that matches question IDs with this question.
    ///
    /// The returned object was the first one that fit the fetch request.
    /// - precondition: The store SHOULD NOT contain more than one response with the given question ID.
    /// - returns: The response if found; `nil` if not.
    var answer: DASIResponse? {
        let retval: DASIResponse? = DASIResponse
            .fetchOne(withTemplate: "withResponseID",
                      params: ["QUESTIONID": number as NSNumber],
                      in: self.managedObjectContext ?? CDGlobals.viewContext)
        return retval
    }

    /// The `DASIQuestion` with `number` one-greater than `self`; or `nil` if there's no such thing.
    var next: DASIQuestion? {
        let nextNumberedQuestions: [DASIQuestion] = //: [DASIQuestion] =
        DASIQuestion
            .fetchAllWith(
                template: "withQuestionID",
                params: ["QUESTIONNUMBER" : (number+1) as NSNumber])
        return nextNumberedQuestions.first
    }

    /// The `DASIQuestion` with `number` one-less than `self`; or `nil` if there's no such thing.
    var prev: DASIQuestion? {
        let nextNumberedQuestions: [DASIQuestion] = //: [DASIQuestion] =
        DASIQuestion
            .fetchAllWith(
                template: "withQuestionID",
                params: ["QUESTIONNUMBER" : (number-1) as NSNumber])
        return nextNumberedQuestions.first
    }

    /// Remove all instances of `DASIQuestion` from the managed-object context.
    ///
    /// Deletion is from the MOC, and is not yet committed to store.
    /// - Parameter moc: The MOC in which the deletion is to be performed.
    /// - throws: Errors from `moc.execute` for the deletion.
    static func clear(from moc: NSManagedObjectContext) throws {
        let fetch = NSFetchRequest<NSFetchRequestResult>(entityName: "DASIQuestion")
        let batchDelete = NSBatchDeleteRequest(fetchRequest: fetch)
        _ = try moc.execute(batchDelete)
    }

    /// Generate `DASIQuestion`s from a JSON listing, and insert them into the context.
    /// - Parameters:
    ///   - url: The URL for the question specs.
    ///   - moc: The managed-object context to receive the new instances.
    ///   - note: No attempt is made to remove existing questions from the store.
    static func load(from url: URL, into moc: NSManagedObjectContext, force: Bool = false) throws {

        if !DASIQuestion.isEmpty() {
            // There are items there already.
            if force { try DASIQuestion.clear(from: moc) }
                // Make it empty and proceed as new.
            else     { return                            }
                // The table is satisfactory as-is. Do nothing.
        }
        // One way or another, it's empty. Proceed as new.

        let data = try Data(contentsOf: url)
        let decoder = JSONDecoder()
        let list = try decoder.decode([JSONQuestion].self,
                                      from: data)
        for record in list {
           let object = NSEntityDescription.insertNewObject(forEntityName: "DASIQuestion",
                                                into: moc) as! DASIQuestion
            // TODO: Make that a guard.
            (object.number, object.text, object.score)
            = (record.id, record.text, record.score)
        }
    }

    /// The `DASIQuestion` that matches the question `number`.
    /// - Parameter id: The target question id
    /// - Returns: The matching `DASIQuestion`, `nil` if none exists.
    /// - throws: Core Data errors from the fetch.
    static func question(withID id: Int32) throws -> DASIQuestion? {
        let fetch = Self.fetchRequest()
        fetch.predicate = NSPredicate(format: "number == %d", id)
        let result = try CDGlobals.viewContext.fetch(fetch)
        return result.first
    }

    /// All `DASIQuestion`s that share a given answer.
    /// - Parameters:
    ///   - answer: The `ResonseLiteral` to look for.
    ///   - moc: The managed-object context to search.

    /// - Returns: An array of `DASIQuestion`s. If there are no matches, this will be empty.
    static func questions(
        withAnswer answer: ResponseLiteral,
        in moc: NSManagedObjectContext = CDGlobals.viewContext) -> [DASIQuestion] {
            let targetString = answer.description
            let allQuestions: [DASIQuestion] = DASIQuestion.all(in: moc)

            let answered = allQuestions.filter {
                question in
                guard let anyAnswer = question.answer,
                      let answerString = anyAnswer.answer else { return false }
                return answerString == targetString
            }

            // CAUTION: Written in haste; is the answered array correct?
            return answered
        }
}
