//
//  MyFireStore.swift
//  newing
//
//  Created by Miyo Lee on 2022/12/28.
//
import Foundation
import FirebaseFirestore
import FirebaseFirestoreSwift

final class MyFirestore {
    
//    private var documentListener: ListenerRegistration?
    
    // db에 데이터 저장하는 메소드
    func save(_ article: Article, completion: ((Error?) -> Void)? = nil) {
        let collectionPath = "saved_article"
        let collectionListener = Firestore.firestore().collection(collectionPath)
        
        if var dictionary = article.asDictionary {  //article -> dictionary
            dictionary["dateTime"] = FieldValue.serverTimestamp()
            collectionListener.addDocument(data: dictionary) { error in
                completion?(error)
            }
        } else {
            print("decode error")
            return
        }
    }
    
    // 실시간으로 데이터를 가져오는 메소드
//    func subscribe(id: String, completion: @escaping (Result<[Article], FirestoreError>) -> Void) {
//        let collectionPath = "saved_article/\(id)"
//        removeListener()
//        let collectionListener = Firestore.firestore().collection(collectionPath)
//
//        documentListener = collectionListener
//            .addSnapshotListener { snapshot, error in
//                guard let snapshot = snapshot else {
//                    completion(.failure(FirestoreError.firestoreError(error)))
//                    return
//                }
//
//                var articles = [Article]()
//                snapshot.documentChanges.forEach { change in
//                    switch change.type {
//                    case .added, .modified:
//                        do {
//                            if let article = try change.document.data(as: Article?.self) {
//                                articles.append(article)
//                            }
//                        } catch {
//                            completion(.failure(.decodedError(error)))
//                        }
//                    default: break
//                    }
//                }
//                completion(.success(articles))
//            }
//    }
//
//    func removeListener() {
//        documentListener?.remove()
//    }
    
}
