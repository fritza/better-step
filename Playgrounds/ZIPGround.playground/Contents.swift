import Foundation



let p_yyyy_mm_dd: DateFormatter = {
    let retval = DateFormatter()
    retval.dateFormat = "yyyy-MM-dd"
    return retval
}()

let p_yyyy_mm_dd_hm_ss: DateFormatter = {
    let retval = DateFormatter()
    retval.dateFormat = "yyyy-MM-dd_hh:mm:ss"
    return retval
}()


extension Date {
    public var ymd: String {
        p_yyyy_mm_dd.string(from: self)
    }
    public var ymd_hms: String {
        p_yyyy_mm_dd_hm_ss.string(from: self)
    }
}

Date().ymd
Date().ymd_hms


