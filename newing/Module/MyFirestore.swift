import Foundation
import FirebaseFirestore
import FirebaseFirestoreSwift

final class MyFirestore {
    
    func saveArticle(_ article: Article, completion: ((Error?) -> Void)? = nil) {
        let collectionPath = "saved_article"
        let collectionListener = Firestore.firestore().collection(collectionPath)
        
        if var dictionary = article.asDictionary {  //article -> dictionary
            dictionary["dateTime"] = FieldValue.serverTimestamp()   //timestamp 형식에 맞게 변경
            collectionListener.addDocument(data: dictionary) { error in
                completion?(error)
            }
        } else {
            print("decode error")
            return
        }
    }
    
    func updateArticle(_ documentId: String, _ dic: Dictionary<String, Any?>, completion: ((Error?) -> Void)? = nil) {
        let collectionPath = "saved_article"
        let collectionListener = Firestore.firestore().collection(collectionPath)
        let docRef = collectionListener.document(documentId)
        
        docRef.updateData(dic) { error in
            completion?(error)
        }
    }
    
    func getArticle(_ documentId: String, completion: ((DocumentSnapshot?, Error?) -> Void)? = nil) {
        let collectionPath = "saved_article"
        let collectionListener = Firestore.firestore().collection(collectionPath)
        let docRef = collectionListener.document(documentId)
        
        docRef.getDocument { (document, error) in
            completion?(document, error)
//            if let document = document, document.exists {
//                let dataDescription = document.data().map(String.init(describing:)) ?? "nil"
//                print("Document data: \(dataDescription)")
//            } else {
//                print("Document does not exist")
//            }
        }
    }
}
