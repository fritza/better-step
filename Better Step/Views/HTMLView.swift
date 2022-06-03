//
//  HTMLView.swift
//  HTML Pager
//
//  Created by Fritz Anderson on 5/2/22.
//

import SwiftUI
import WebKit

// FIXME: To support the Preview, provide a container view.

struct HTMLView: UIViewRepresentable {
    typealias UIViewType = WKWebView
    let pageContent: String
    let contentParent: URL?

    init(content: String, parentDirectory parent: URL? = nil) {
        self.pageContent = content
        if let parent = parent {
            contentParent = parent
        }
        else {
            contentParent = Bundle.main.bundleURL
        }
    }

    func makeUIView(context: Context) -> WKWebView {
        let view = WKWebView(frame: .zero)
        return view
    }

    func updateUIView(_ uiView: WKWebView, context: Context) {
        uiView.loadHTMLString(pageContent,
                              baseURL: contentParent)
    }
}

struct HTMLView_Previews: PreviewProvider {
    static func sourceURL(_ fileName: String) -> URL? {
        return Bundle.main
            .url(forResource: fileName, withExtension: nil)!
    }

//    static let fileNames = [ "page1.html", "page2.html", "page3.html", "page4.html", ]
//    static var index = 0
//    static func increment() {
//        defer { index = (index+1) % fileNames.count }

    static var previews: some View {
        VStack {
//            Button("Other") {
//                increment()
//            }
//            Divider()

            // FIXME: Add an owning HTMLDisplayView
            // HTMLView(content: HTMLDisplayView.noHTML)
            EmptyView()
        }
    }
}
