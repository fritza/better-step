//
//  WalkInstructionBase.swift
//  Async Accel
//
//  Created by Fritz Anderson on 4/7/22.
//

import SwiftUI


/// A `View` that hosts a series of pages for user instruction.
///
/// The "pages" are presented by `InstructionPageView` from content in an array of `InstructionElement`. `Self.instructionPages` loads them from the main `Bundle` by iterating `.txt` files in a bundle subdirectory.
///
/// The page content is parsed from that file into `InstructionElement`s; see `InstructionElement.swift` for further information.
struct WalkInstructionBase: View {
    /// An array (representing all pages) of arrays of `InstructionElement` (representing page content).
    ///
    /// The array is initialized from `.txt` files in a named directory. If it can't be found, it's a fatal error.
    static let instructionPages: [[InstructionElement]] = {
        do {
            return try InstructionElement.elements(withExtension: "txt", subdirectory: "WalkResources")
        }
        catch {
            fatalError()
        }
    }()

    @State private var counter: Int = 0

    var nextButton: some View {
        Button("Next") {
            if (0..<Self.instructionPages.count)
                .contains(counter+1) {
                self.counter += 1
            }
        }
        .disabled(counter >= Self.instructionPages.count-1)
    }

    var prevButton: some View {
        Button("Back") {
            if counter > 0 { counter -= 1 }
        }
        .disabled(counter <= 0)
    }


    var body: some View {
        NavigationView {
            VStack(spacing: 24) {
                InstructionPageView(content: Self.instructionPages[counter])
                // FIXME: in this case, use the title as the navigation title.
                    .navigationTitle("Welcome")
                    .padding()
            }
            .toolbar {
// TODO: Replace with ToolbarItem
                ToolbarItemGroup(placement: .navigationBarLeading) {
                    self.prevButton
                    gearBarItem()
                }
// TODO: Replace with ToolbarItem
                ToolbarItemGroup(placement: .navigationBarTrailing) {
                    Button("Next") {
                        self.nextButton
                    }
                }
            }
            .onAppear {
                assert(counter <= Self.instructionPages.count,
                       "Out of range: \(counter), limit is \(Self.instructionPages.count)")
            }
            Button("Okay!") {
                // TODO: Incomplete
            }
        }
        Spacer()
    }
}

struct WalkInstructionBase_Previews: PreviewProvider {
    static var previews: some View {
        WalkInstructionBase()
    }
}
