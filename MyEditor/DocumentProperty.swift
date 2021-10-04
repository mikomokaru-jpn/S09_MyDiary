//---- DocumentProperty.swift ----
import Foundation
//ドキュメント属性
class DocumentProperty: NSObject {
    static let sharedInstance: DocumentProperty = DocumentProperty()
    var fontName: String    //フォント名
    var fontSize: Int       //フォントサイズ
    var regex: Bool         //正規表現による検索
    //イニシャライザ
    private override init() {
        self.fontName = "Osaka"
        self.fontSize = 14
        self.regex = false
    }
}
