//------------------------------------------------------------------------------
//  UATextAttribute.swift
//------------------------------------------------------------------------------
import Cocoa
class UATextAttribute: NSObject {
    //属性付き文字列の属性
    class func attributes(name:String, size:CGFloat, color:NSColor)
        ->[NSAttributedStringKey:Any]{
            //属性
            var attributes:[NSAttributedStringKey:Any] = [:]
            //フォント名
            var fontName:String = name
            if name == "" {
                fontName = "Arial"
            }
            //フォント
            let font:NSFont = NSFont.init(name:fontName, size:size)
                ?? NSFont.systemFont(ofSize: 12)
            attributes[.font] = font
            //文字色
            attributes[.foregroundColor] = color
            return attributes
    }
    //文字列装飾属性（デフォルト）
    class func attributes()
        ->[NSAttributedStringKey:Any]{
            return self.attributes(name: "", size: 12,
                                   color: NSColor.black)
    }
    //文字列装飾属性（フォントサイズ指定）
    class func attributes(size:CGFloat)
        ->[NSAttributedStringKey:Any]{
            return self.attributes(name: "", size: size,
                                   color: NSColor.black)
    }
    //文字列装飾属性（文字色指定）
    class func attributes(color:NSColor)
        ->[NSAttributedStringKey:Any]{
            return self.attributes(name: "", size: 12, color: color)
    }
    //文字列装飾属性（フォントサイズ、文字色指定）
    class func attributes(size:CGFloat, color:NSColor)
        ->[NSAttributedStringKey:Any]{
            return self.attributes(name: "", size: size, color: color)
    }
    //属性付き文字列
    class func string(_ string:String, name:String, size:CGFloat,
                      color:NSColor) ->NSMutableAttributedString{
        //文字列
        let atrString = NSMutableAttributedString(string: string)
        //フォント名
        var fontName:String = name
        if name == "" {
            fontName = "Arial"
        }
        let font = NSFont.init(name:fontName, size:size)
            ??  NSFont.systemFont(ofSize: 12)
        atrString.addAttributes([.font:font],
                                range:NSMakeRange(0, atrString.length))
        //文字色
        atrString.addAttributes([.foregroundColor:color],
                                range:NSMakeRange(0, atrString.length))
        return atrString
    }
    //修飾文字列（フォントサイズ、文字色指定）
    class func string(_ string:String, size:CGFloat, color:NSColor)
        ->NSMutableAttributedString{
            return self.string(string, name: "", size: size, color: color)
    }
    //修飾文字列（フォントサイズ）
    class func string(_ string:String, size:CGFloat)
        ->NSMutableAttributedString{
            return self.string(string, name: "", size: size,
                               color: NSColor.black)
    }
    //修飾文字列を中央揃えにする
    class func centered(atrString:NSMutableAttributedString)
        ->NSMutableAttributedString{
            let pStyle = NSMutableParagraphStyle()
            pStyle.alignment = NSTextAlignment.center
            atrString.addAttributes([.paragraphStyle:pStyle],
                                    range:NSMakeRange(0, atrString.length))
            return atrString
    }
}
