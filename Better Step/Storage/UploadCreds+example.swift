#if API_DEV
    // Use for internal test and development
    static let lastPassName = "Step Test Files API"
    static let uploadString ="https://steptestfilesdev.uchicago.edu/api/upload"
    static let userID       = "iosuser"
    static let password     = "Daf4Df24fshfg"
#elseif BETA_API
    // Use for TestFlight
    static let lastPassName = "Step Test Files API"
    static let uploadString = "https://steptestfilesstage.uchicago.edu/api/upload"
    static let userID       = "iosuser"
    static let password     = "Daf4Df24fshfg"
#else
    // Public-release (production server)
    static let lastPassName = "Step Test Files API (PROD)"
    static let uploadString = "https://steptestfiles.edu/api/upload"
    static let userID       = "iosuser"
    static let password     = "#jd89DFa882%"
#endif


/*
    Per pezzutidyer, 19-Jan-2023
 */

[8:47 AM] Rose M Pezzuti Dyer
good morning! here we go:
 
The lastpass names are "Step Test Files API (dev and stage)" and "Step Test Files API (PROD)".  User IDs and passwords are unchanged (although updated recently because of LastPass leaks).
 
The base URLs are https://steptestfilesdev.uchicago.edu, https://steptestfilesstage.uchicago.edu, and https://steptestfiles.uchicago.edu.
 
The full upload URL should be the base URL + '/api/upload'. that's for dev, stage and prod.
 
Humans should go to the base URL to see the web site. The web site makes the user log in so he can download files.
Web Login Service - Loading Session Information


