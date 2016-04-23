import UIKit
import AFNetworking

let serverBaseURL = NSURL(string: "https://horvathtom.com/jp/api/")

class JapanizeClient : AFHTTPSessionManager {
  
  class var sharedInstance: JapanizeClient {
    struct Static {
      static let instance = JapanizeClient(baseURL: serverBaseURL)
    }
    return Static.instance
  }
  
  func book(completion: (book: Book?, error: NSError?) -> ()) {
    GET(
      "book",
      parameters: nil,
      progress: nil,
      success: { (operation: NSURLSessionDataTask!, response: AnyObject?) -> Void in
        let book = Book(dictionary: response as! NSDictionary)
        completion(book: book, error: nil)
      },
      failure: { (operation: NSURLSessionDataTask?, error: NSError!) -> Void in
        print("error getting book")
        completion(book: nil, error: error)
    })
  }
  
}
