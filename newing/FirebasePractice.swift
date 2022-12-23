import Foundation
import Firebase

class FirebasePractice {
    
//    static let shared = FirebasePractice()
//
//    var currentUser = UserDefaults.standard.object(forKey: "")
//    var db: Firestore!
//    var articleRef: CollectionReference!
//
//    init() {
//        // [START setup]
//        let settings = FirestoreSettings()
//
//        Firestore.firestore().settings = settings
//
//        // [END setup]
//        db = Firestore.firestore()
//
//        articleRef = db.collection("saved_article")
//    }
    
//    func addPost(personRequest request: ArticleItem) {
//
//        var ref: DocumentReference? = nil
//
//        do {
//            ref = articleRef.document()
//
//            guard let ref = ref else {
//                print("Reference is not exist.")
//                return
//            }
//
//            // 사용자 uid 추가
//            guard let currentUser = currentUser else {
//                return
//            }
//
//            var request = request
//            request.authorUID = currentUser.uid
//
//            try ref.setData(from: request) { err in
//                if let err = err {
//                    print("Firestore>> Error adding document: \(err)")
//                    return
//                }
//
//                print("Firestore>> Document added with ID: \(ref.documentID)")
//            }
//        } catch  {
//            print("Firestore>> Error from addPost-setData: ", error)
//        }
//    }
}

//struct ArticleItem: Codable {
//
//    // @DocumentID가 붙은 경우 Read시 해당 문서의 ID를 자동으로 할당
//    @DocumentID var documentID: String?
//
//    // @ServerTimestamp가 붙은 경우 Create, Update시 서버 시간을 자동으로 입력함 (FirebaseFirestoreSwift 디펜던시 필요)
//    @ServerTimestamp var serverTS: Timestamp?
//
//    var title: String
//
//    // 왼쪽: Swift 내에서 사용하는 변수이름 / 오른쪽: Firebase에서 사용하는 변수이름
//    enum CodingKeys: String, CodingKey {
//        case documentID = "document_id"
//        case serverTS = "server_ts"
//
//        case title, userId
//    }
//}
