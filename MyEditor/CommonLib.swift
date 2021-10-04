//---- CommonLib.swift ----
import Foundation
//------------------------------------------------------------------------------
// String 拡張
// String.rangeメソッドでテキスト検索を行い、結果をNSrangeオブジェクトの配列として返す。
// String.nsRanges(of:options:locale:) -> ranges(of:options:locale:) ->
// range(of:options:range:locale:) -> NSRange.init(_:in:) -> [NSRange] という流れ
//------------------------------------------------------------------------------
extension String {
    func nsRange(from range: Range<String.Index>) -> NSRange {
        return NSRange.init(range, in: self) //これが肝のようだ extentionのもよう
    }
    func ranges(of searchString: String,
                options mask: NSString.CompareOptions = [],
                locale: Locale? = nil) -> [Range<String.Index>] {
        var ranges: [Range<String.Index>] = []
        while let range = range(of: searchString,
                                options: mask,
                                range: (ranges.last?.upperBound ?? startIndex)..<endIndex,
                                locale: locale)
        {
            ranges.append(range)
        }
        return ranges
    }
    func nsRanges(of searchString: String,
                  options mask: NSString.CompareOptions = [],
                  locale: Locale? = nil) -> [NSRange] {
        let ranges = self.ranges(of: searchString, options: mask, locale: locale)
        return ranges.map { nsRange(from: $0) }
    }
}
//------------------------------------------------------------------------------
// 構造体
//------------------------------------------------------------------------------
//サブウィンドウ情報
struct SubWindowInfo {
    var object: SubWindowController?    //ウィンドウオブジェクト
    var status: Bool                    //オブジェクトの有無
    var index: Int                      //順序番号
    var active: Bool                    //アクティブウィンドウ
}
//日付情報の構造体
struct DateOfDiary {
    var year: Int
    var month: Int
    var day: Int
    var yobi: String
    init() {
        self.year = 0; self.month = 0; self.day = 0; self.yobi = "";
    }
    init(_ year: Int, _ month: Int, _ day: Int, _ yobi: String){
        self.year = year; self.month = month; self.day = day; self.yobi = yobi;
    }
    var ymd: Int{
        get {
            return year * 10000 + month * 100 + day
        }
    }
    //比較演算子
    static func ==(lhs: DateOfDiary, rhs: DateOfDiary) -> Bool{
        if lhs.year == rhs.year && lhs.month == rhs.month && lhs.day == rhs.day{
            return true
        }
        return false
    }
}
//------------------------------------------------------------------------------
// プロトコル宣言
//------------------------------------------------------------------------------
//サブウィンドウの制御
protocol SubWindowDelegate: class {
    func windowClose(_ sender: SubWindowController)
    func windowActivate(_ sender: SubWindowController)
    func windowDeactivate(_ sender: SubWindowController)
}
//ドキュメント表示モードの変更
protocol DisplayDocumentsDelegate: class {
    func redisplayCalendar()
}
//------------------------------------------------------------------------------
// 共通関数ライブラリ
//------------------------------------------------------------------------------
class CommonLib {
    //入力
    static func readFromFile(date: DateOfDiary)->NSMutableAttributedString{
        let path = String(format:"%@%@%d%@",
                          NSHomeDirectory(), "/MyDiary/", date.ymd, ".txt")
        if FileManager.default.fileExists(atPath: path){
            do{
                let text = try String.init(contentsOf: URL.init(fileURLWithPath: path))
                let attrText = NSMutableAttributedString.init(string: text)
                return attrText
            }catch{
                print(error)
                return NSMutableAttributedString.init(string: "")
            }
        }else{
            return NSMutableAttributedString.init(string: "")
        }
    }
    //出力
    static func writeToFile(_ text: String, date: DateOfDiary){
        let outURL = URL.init(fileURLWithPath: String(format:"%@%@%d%@",
                                                      NSHomeDirectory(), "/MyDiary/", date.ymd, ".txt"))
        do{
            try text.write(to: outURL, atomically: true, encoding: String.Encoding.utf8)
        }catch{
            print(error)
            return
        }
    }
    //記録のある日付のファイル名（整数値yyyymmdd）を返す。
    static func fileNamesWithContents(_ start: Int, _ end: Int)->[Int]{
        var names:[Int] = []
        let url = URL.init(fileURLWithPath: String(format: "%@%@",
                                                   NSHomeDirectory(), "/MyDiary/"))
        let fm = FileManager.default
        guard let urlNames = try? fm.contentsOfDirectory(at: url,
                               includingPropertiesForKeys: [],
                               options: []) else{
            return names
        }
        for url in urlNames{
            let name =  url.deletingPathExtension().lastPathComponent
            guard let nameInt = Int(name) else {
                continue
            }
            if nameInt >= start && nameInt <= end{
                let path = url.path
                let attr = try? fm.attributesOfItem(atPath: path)
                if let fileSize = attr?[.size] as? UInt64{
                    if fileSize > 0{
                        names.append(nameInt)
                    }
                }
            }
        }
        return names
    }
    
    
    
}

