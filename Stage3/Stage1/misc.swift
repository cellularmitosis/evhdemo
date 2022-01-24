//
//  misc.swift
//  Stage1
//
//  Created by Jason Pepas on 1/21/22.
//

import Foundation


/// If debug build, crash immediately.  If production build, print an error and attempt to continue.
/// This should only be used for "developer errors" / "unreachable" code, not expected runtime errors.
func semiFatalError(_ message: String) {
    #if DEBUG
    fatalError(message)
    #else
    print("❌❌❌ semiFatalError: \(message)")
    #endif
}
