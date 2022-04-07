//
//  WalkInstructionBase.swift
//  Async Accel
//
//  Created by Fritz Anderson on 4/7/22.
//

import SwiftUI

struct WalkInstructionBase: View {
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
            if counter >= Self.instructionPages.count {
                Text("Out of range: \(counter), limit is \(Self.instructionPages.count)")
            }
            else {
                VStack(spacing: 24) {
                    InstructionPageView(content: Self.instructionPages[counter])
                    // FIXME: in this case, use the title as the navigation title.
                        .navigationTitle("Welcome")
                        .padding()
                        .toolbar {
                            ToolbarItem(id: "Next", placement: .navigationBarTrailing, showsByDefault: true) {
                                self.nextButton
                            }
                            ToolbarItem(id: "Prev", placement: .navigationBarLeading, showsByDefault: true) {
                                self.prevButton
                            }
                    }
                    Button("Okay!") {

                    }
                }
            }
Spacer()
        }
    }
}

struct WalkInstructionBase_Previews: PreviewProvider {
    static var previews: some View {
        WalkInstructionBase()
    }
}
