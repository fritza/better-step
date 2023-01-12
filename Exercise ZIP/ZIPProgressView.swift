//
//  ZIPProgressView.swift
//  Exercise ZIP
//
//  Created by Fritz Anderson on 1/11/23.
//

import SwiftUI

struct ZIPProgressView: View {
    
    @State var shouldShowActivity = false
    // Why is this a @State? It's a struct, that's why.
    @State var activityController: ActivityUIController!
    @State var activityURL: URL?

    func saveTheData() throws -> URL {
        var docsURL = FileManager.default.applicationDocsDirectory
        docsURL.appendPathComponent("Activity", conformingTo: .data)
        docsURL.appendPathExtension("zip")
        
        try FileManager.default
            .deleteAndCreate(at: docsURL, contents: result)
        
        return docsURL
    }
    
    enum ZippingState: String, Hashable {
        case idle, work, finish, fail
    }
    @State var condition: ZippingState = .idle
    @State var result: Data = Data() {
        didSet {
            if !result.isEmpty {
                // If it _is_ empty, should delete thd file,
                // but that's not happening on this schedule.
                self.activityURL = try! saveTheData()
                shouldShowActivity = true
            }
        }
    }
    
    var pList: [Piffle] = []
    init(pList: [Piffle]) {
        self.pList = pList
    }
    
    func createArchive() {
        Task {
            // MainActor.shared?
            do {
                self.condition = .work
                await Task.yield()
                let arch = try ZipFactory()
                for p in pList {
                    try arch.add(piffle: p)
                }
                await Task.yield()
                self.result = try arch.data()
                self.condition = .finish
            }
            catch {
                self.condition = .fail
                self.result = Data()
                await Task.yield()
                print("Got an error in", #function)
                preconditionFailure("Got an error in \(#function)")
            }
        }
    }

    var body: some View {
        VStack {
            Spacer()
            Text("Zipping (\(condition.rawValue))…").font(.largeTitle)
            Spacer()
            switch condition {
            case .fail:
                Text("Failed").font(.largeTitle).foregroundColor(.red)
            case .finish:
                Text("Done! \(result.count) bytes").font(.largeTitle).foregroundColor(.green)
            case .idle:
                Text("Idle").font(.largeTitle).foregroundColor(.gray)
            case .work:
                Text("Working…").font(.largeTitle).foregroundColor(.pink)
            }
            Spacer()
        }
        
        Spacer()
        Button(action: {
            shouldShowActivity = true
        },
               label: {
            Label("Save", systemImage: "figure.wrestling")
        })
        .sheet(isPresented: $shouldShowActivity,
               content: {
            // WARNING: no check for activityURL == nil
            ActivityUIController(url: activityURL)
                .presentationDetents([.medium])
            
            // FIXME:
#warning("Repeating on the same calendar day overwrites the outpput directory")
        })

        
        .onAppear {
            createArchive()
        }

        
        .navigationTitle("Building…")
    }
}

struct ZIPProgressView_Previews: PreviewProvider {
    static var previews: some View {
        ZIPProgressView(pList:
            [Piffle(name: "Dummy",
                    content: "Never mind.")]
        )
        .padding()
    }
}
