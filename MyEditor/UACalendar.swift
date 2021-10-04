//------------------------------------------------------------------------------
//  UACalendar.swift
//------------------------------------------------------------------------------
import Cocoa
class UACalendar: NSObject {
    private(set) var daysOfCalender: Int = 0        //日数（前月と翌月の一部を含む）
    private(set) var currentDateIndex: Int = 0      //当月当日
    private(set) var firstDayIndex: Int = 0         //当月1日
    private(set) var lastDayIndex: Int = 0          //当月末日
    
    var holidays: Dictionary = [String: String]()
    var dateList = [UACalenderDate]()
    let dtUtil:UADateUtil
    var firstDateOfThisMonth:Date
    //イニシャライザ
    override init() {
        //日付ユーティリティ
        dtUtil = UADateUtil.dateManager
        firstDateOfThisMonth = dtUtil.firstDate(date: Date())
        //スーパークラスの初期化
        super.init()
        //休日ファイルを読み込む
        if let path = Bundle.main.path(forResource: "holiday", ofType: "json"){
            do {
                let url:URL = URL.init(fileURLWithPath: path)
                let data = try Data.init(contentsOf: url)
                let jsonData = try JSONSerialization.jsonObject(with: data)
                if  let dictionary = jsonData as? Dictionary<String, String>{
                    holidays = dictionary
                    /*
                    for (key, value) in holidays{
                        print(String(format: "%@:%@", key, value))
                    }
                    */
                }else{
                    print("休日ファイルを読み込めません")
                    return
                }
            }catch{
                print("休日ファイルを読み込めません")
            }
        }
        //当月のカレンダーを作成する
        self.createDateList()
    }
    //カレンダーを作成する
    func createCalender(addMonth:Int){
        firstDateOfThisMonth = dtUtil.date(date: firstDateOfThisMonth, addMonths: addMonth)
        self.createDateList()
    }
    //当年を返す
    var year:Int{
        get{
            return dtUtil.intYear(date: firstDateOfThisMonth)
        }
    }
    //当年（和暦）を返す
    var yearOfWareki:Array<String> {
        get{
            return dtUtil.yearOfWareki(date: firstDateOfThisMonth)
        }
    }
    //当月を返す
    var month:Int{
        get{
            return dtUtil.intMonth(date: firstDateOfThisMonth)
        }
    }
    //指定のインデックスの年月日を返す
    func yearMonthday(index: Int) -> Int {
        return dateList[index].year * 10000 +
               dateList[index].month * 100 +
               dateList[index].day
    }
    //指定のインデックスの年を返す
    func year(index: Int) -> Int {
        return dateList[index].year
    }
    //指定のインデックスの月を返す
    func month(index: Int) -> Int {
        return dateList[index].month
    }
    //指定のインデックスの日を返す
    func day(index: Int) -> Int {
        return dateList[index].day
    }
    //指定のインデックスの曜日（コード）を返す
    func weekday(index: Int) -> Int {
        return dateList[index].weekday
    }
    //指定のインデックスの曜日（漢字）を返す
    func yobi(index: Int) -> String {
        let youbis = ["日","月","火","水","木","金","土"]
        let weekday = dateList[index].weekday
        return youbis[weekday - 1]
    }
    
    //指定のインデックスの当月フラグを返す
    func thisMonthFlag(index: Int) -> Bool {
        return dateList[index].thisMonthFlag
    }
    //指定のインデックスの休日フラグを返す
    func holidayFlag(index: Int) -> Bool {
        return dateList[index].holidayFlag
    }
    //カレンダーの作成
    private func createDateList(){
        let format = DateFormatter()
        format.dateStyle = .medium
        
        dateList = [UACalenderDate]()
        let tableCnv = [7,1,2,3,4,5,6]
        //前月処理
        let weekOf1st = dtUtil.intWeekday(date: firstDateOfThisMonth)
        let preDays = tableCnv[weekOf1st - 1] - 1
        let preDate = dtUtil.date(date: firstDateOfThisMonth, addDays: -preDays)
        for i:Int in 0 ..< preDays{
            let udt = self.makeDate(date:dtUtil.date(date: preDate, addDays: i))
            udt.thisMonthFlag = false
            dateList.append(udt)
        }
        //当月処理
        let daysOfThisMonth = dtUtil.daysOfMonth(date: firstDateOfThisMonth)
        for i:Int in 0 ..< daysOfThisMonth{
            let udt = self.makeDate(date:dtUtil.date(date: firstDateOfThisMonth, addDays: i))
            udt.thisMonthFlag = true
            if i==0{
                udt.firstDayFlag = true
            }else{
                udt.firstDayFlag = false
            }
            if i==daysOfThisMonth-1{
                udt.lastDayFlag = true
            }else{
                udt.lastDayFlag = false
            }
            dateList.append(udt)
        }
        //翌月処理
        let firstDateNext = dtUtil.date(date: firstDateOfThisMonth, addMonths: 1)
        let nextDays = (7 - (dateList.count % 7)) % 7
        for i:Int in 0 ..< nextDays{
            let udt = self.makeDate(date:dtUtil.date(date: firstDateNext, addDays: i))
            udt.thisMonthFlag = false
            dateList.append(udt)
        }
        //各インデックスを求める
        currentDateIndex = -1;
        daysOfCalender = dateList.count
        for i:Int in 0 ..< daysOfCalender{
            if dateList[i].currentFlag{
                currentDateIndex = i
            }
            if dateList[i].firstDayFlag{
                firstDayIndex = i
            }
            if dateList[i].lastDayFlag{
                lastDayIndex = i
            }
        }
    }
    //日付オブジェクトを作成する
    func makeDate(date: Date)->UACalenderDate{
        let udt = UACalenderDate()
        udt.year = dtUtil.intYear(date: date)           //年
        udt.month = dtUtil.intMonth(date: date)         //月
        udt.day = dtUtil.intDay(date: date)             //日
        udt.weekday = dtUtil.intWeekday(date: date)     //曜日
        //現在日の判定
        if dtUtil.isEqualDate(date1: date, date2: Date()){
            udt.currentFlag = true
        }else{
            udt.currentFlag = false
        }
        //休日の判定
        udt.holidayFlag = false
        let strYMD = String(format:"%d", udt.year*10000 + udt.month*100 + udt.day)
        let holidayName : String? = holidays[strYMD]
        if holidayName != nil{
            udt.holidayFlag = true
        }
        return udt
    }
}
