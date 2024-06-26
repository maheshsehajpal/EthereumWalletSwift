// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/

import Foundation
import MozillaAppServices
import UIKit

/// A Firefox Suggest search suggestion. This struct is a Swiftier
/// representation of the Rust `Suggestion` enum.
public struct RustFirefoxSuggestion {
    public let title: String
    public let url: URL
    public let isSponsored: Bool
    public let iconImage: UIImage?
    public let fullKeyword: String

    internal init?(_ suggestion: Suggestion) {
        // This code is intentionally written as a chain of `if-case-let`s
        // instead of a `switch`, because we don't want new `Suggestion` cases
        // added in Rust to be source-breaking changes in Firefox. A `switch`
        // with a `default` or `@unknown default` case would emit a "default
        // will never be executed" warning, because Swift treats `Suggestion`
        // as frozen, since we can't build Application Services with library
        // evolution support.
        if case let .amp(title, urlString, _, iconBytes, fullKeyword, _, _, _, _, _, _) = suggestion {
            // This use of `URL(string:)` is OK; we don't need to use
            // `URL(string:encodingInvalidCharacters:)` here.
            guard let url = URL(string: urlString) else { return nil }
            self.title = title
            self.url = url
            self.isSponsored = true
            self.iconImage = iconBytes.flatMap { UIImage(data: Data($0)) }
            self.fullKeyword = fullKeyword
        } else if case let .wikipedia(title, urlString, iconBytes, fullKeyword) = suggestion {
            // This use of `URL(string:)` is OK.
            guard let url = URL(string: urlString) else { return nil }
            self.title = title
            self.url = url
            self.isSponsored = false
            self.iconImage = iconBytes.flatMap { UIImage(data: Data($0)) }
            self.fullKeyword = fullKeyword
        } else {
            return nil
        }
    }
}
