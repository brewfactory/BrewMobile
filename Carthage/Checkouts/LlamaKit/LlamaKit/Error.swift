//
// Basic error handling
//

import Foundation

/// ErrorType defines an error, usable by Result. It doesn't have any
/// requirements. This gives it slightly more structure than an Any,
/// while still letting flatMap chain it for free.
public protocol ErrorType {}

extension NSError: ErrorType {}

public let ErrorFileKey = "LMErrorFile"
public let ErrorLineKey = "LMErrorLine"
