//
//  AccSample+CoreDataClass.swift
//  mommk
//
//  Created by Fritz Anderson on 4/19/22.
//
//

import Foundation
import CoreData
import CoreMotion

/* FIXME: - Background saving
 I _think_ I want to do save()s in the background rather than have accelerometer collection stutter audio, timing, etc.

 Arrange for a MOC for AccSample saves.
 How can I be sure it propagates to the parent MOC? In time gone by, I manually did a parent.save() at the closing of a perform(AndWait). Is that really necessary?

 Alternative, have the main MOC _listen_ for child notifications. How 'bout that.

 Q: What comfort is there in NSManagedObject's async perform(_:) function? Can I use it for saves, or just for huge things like mass deletions?

 Use NSManagedObjectContext.ScheduledTaskType .enqueue (default is .immediate; what do they know that I don't?

perform(AndWait) takes a block in all cases. Tell the desired context to do what's in the block (presumably including save). There's no .immediate/.enqueue issue. They cannot rethrow! The block returns Void, and may not throw. The functions do not throw. perform returns void.

 perform(scheduleType) takes a block and is async. It can rethrow! Returns the value returned by the block.
 performAndWait(_:) same spelling, have to force types, takes a block, returns the result of the block.
 Both of these are iOS 15+ (meaning THIS YEAR'S (2021-22) OS).

 Q: To what extent am I forced to use the Async
 */

// MARK: - AccSample
@objc(AccSample)
public class AccSample: NSManagedObject {
    // MARK: Instantiation

    /// Insert a new `AccSample` given `x`, `y`, and `z` acceleration components.
    ///
    /// - Parameters:
    ///   - x: the _x_ component of the acceleration sample
    ///   - y: the _y_ component of the acceleration sample
    ///   - z: the _z_ component of the acceleration sample
    ///   - timestamp: The time of observation as a `TimeInterval` from “reference date” (`timeIntervalSinceReferenceDate`). Defaults to the moment of call.
    ///   - moc: The context to perform the insertion. Defaults to the `viewContext`.
    /// - Returns: A new, freshly-inserted accelerometry sample.
    /// - warning: Dereference of `nil` if the inserted object is not an `AccSample`. Can't Happen if the `NSPersistentContainer` is initialized.
    static func newSample(
        _ x: Double, _ y: Double, _ z: Double,
        timestamp: TimeInterval = Date().timeIntervalSinceReferenceDate,
        inContext moc: NSManagedObjectContext = CDGlobals.viewContext) -> AccSample {
            let object = NSEntityDescription
                .insertNewObject(forEntityName: "AccSample",
                                 into: moc)
        as! AccSample
        (object.x, object.y, object.z) = (x, y, z)
        object.timeSeconds = timestamp
        object.setMagnitude()

        return object
    }

    /// Insert a new `AccSample` given a `CMAcceleration` and a time-interval stamp
    /// - Parameters:
    ///   - acceleration: The acceleration to be recorded
    ///   - timestamp: The observation time, a `TimeInterval` since “reference date” (`timeIntervalSinceReferenceDate`)
    ///   - moc: The context to perform the insertion. Defaults to the `viewContext`.
    /// - Returns: A new, freshly-inserted accelerometry sample.
    static func newSample(_ acceleration: CMAcceleration,
        timestamp: TimeInterval = Date().timeIntervalSinceReferenceDate,
        inContext moc: NSManagedObjectContext = CDGlobals.viewContext) -> AccSample {
        return newSample(acceleration.x,
                         acceleration.y,
                         acceleration.z,
                         timestamp:timestamp,
                         inContext: moc)
    }


    // MARK: Transient magnitude

    /// Set the transient `magnitude` from the stored `x`, `y`, and `z`.
    func setMagnitude() {
        magnitude = sqrt(x*x + y*y + z*z)
    }

    // TODO: Might have to sort samples.
    //       AccSession.samples is an ordered set, but:
    //       that's by-insertion, which might happen out-of-order.
    // TODO: Consider offsetting timeSeconds to start from 0.0.
    //       Starting the session clock from zero makes sense,
    //       but may not be needed.
    // TODO: Insertion on the `viewContext` may be a Bad Idea.

    /// Set `magnitude` before notifying others of a save.
    public override func didSave() { setMagnitude(); super.didSave() }
    /// Set the `magnitude` of a rehydrated `AccSample`.
    public override func awakeFromFetch() { super.awakeFromFetch(); setMagnitude() }
    /// Set the `magnitude` of an `AccSample` recovered from a snapshot.
    public override func awake(fromSnapshotEvents events: NSSnapshotEventType) {

        super.awake(fromSnapshotEvents: events)
        setMagnitude() }


    // MARK: → CSV

    var subjectID: String? {
        return self.session?.subject?.subjectID
    }

    private var asComponents: String {
        guard let subject: Subject = try? Subject.fetchOne() else {
            assertionFailure("A Subject should be fetchable by now.")
            return "NO SUBJECT SET"
        }

        guard let subID = self.subjectID,
              subID == subject.subjectID! else {
            assertionFailure("\(#function): Fetching the singleton Subject and tracing the relationship path should turn out the same.")
            return "N/A"
            // This is for testing so far.
            // subID won't be used yet.
        }

        let id = subject.subjectID!
        let stamp = self.timeSeconds.pointEight
        let vector = [x, y, z].map { $0.pointEight }
        let elements = [id, stamp] + vector
        return elements.joined(separator: ",")
    }

    private var asMagnitude: String {
        guard let subject: Subject = try? Subject.fetchOne() else {
            return "NO SUBJECT SET"
        }

        guard let subID = self.subjectID,
              subID == subject.subjectID! else {
            assertionFailure("\(#function): Fetching the singleton Subject and tracing the relationship path should turn out the same.")
            return "N/A"
            // This is for testing so far.
            // subID won't be used yet.
        }


        let id = subject.subjectID!
        let stamp = self.timeSeconds.pointEight
        let magnitude = self.magnitude.pointEight
        return [id, stamp, magnitude].joined(separator: ",")
    }

    /// A `String` containing a line for a `.csv` file reporting on subject, timing, and acceleration.
    /// - Parameter mag: if `true`, report acceleration as a single magnitude; as vector components otherwise.
    /// - Returns: The csv line representing the data.
    func csvLine(asMagnitude mag: Bool) -> String {
        return mag ? asMagnitude : asComponents
    }
}
