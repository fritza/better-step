//
//  ActivityUIController.swift
//  G Bars
//
//  Created by Fritz Anderson on 8/17/22.
//

import SwiftUI

/// `UIViewControllerRepresentable`  implementation of `UIActivityViewController`
struct ActivityUIController: UIViewControllerRepresentable {
    typealias Context = UIViewControllerRepresentableContext<ActivityUIController>
    typealias ActivityCallback = UIActivityViewController.CompletionWithItemsHandler
    typealias Activity = UIActivity.ActivityType

    @State var activityItems: [Any]
//    static let activities: [Activity] = [.airDrop, .copyToPasteboard, .mail, .print]
//    var applicationActivities: [UIActivity]? = (Self.activities as! [UIActivity])
//        var applicationActivities: [UIActivity]? = [

    func makeUIViewController(context: Context) -> UIActivityViewController {
        let retval =  UIActivityViewController(
            activityItems: activityItems,
            applicationActivities: nil
        )
        return retval
    }

    func updateUIViewController(_ uiViewController: UIViewControllerType, context: Context) { }

    init(data: Data, text: String) {
        activityItems = [data, text]
    }

    init(url: URL, text: String) {
        activityItems = [url, text]
    }
}


