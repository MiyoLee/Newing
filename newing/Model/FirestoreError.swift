
import Foundation

enum FirestoreError: Error {
    case firestoreError(Error?)
    case decodedError(Error?)
}
