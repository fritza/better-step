import SwiftUI
//import Better_Step
//import ZIPFoundation

/*
struct TField: View {
    @Binding var string: String
    
    init(_ str: Binding<String>) {
        _string = str
    }
    
    var body: some View {
        VStack {
            Text("Content = \(string)")
            Text("For rent")
        }
    }
}


struct StringShower: View {
    @State var result: String
    
    var body: some View {
        VStack {
//            Text("Result = \(result)")
            Divider()
            TField($result)
        }
    }
}
*/
struct BoneSimple: View {
    @State var editable: String = "S"
    var body: some View {
        VStack {
            Text(editable)
            Text("For rent. Again.")
        }
    }
}

//let theView = StringShower(result: "initial")
//    .frame(width: 340, height: 340)

let theView = BoneSimple(editable: "BoneString")
    .frame(width: 340, height: 340)


import PlaygroundSupport
PlaygroundPage.current.needsIndefiniteExecution = true

PlaygroundPage.current.setLiveView(theView)
