//------------------------------------------------------------------------------
//  FlippedView.swift
//------------------------------------------------------------------------------
import Cocoa

class FlippedView: UAContentView {
    //ビューのY軸の反転
    override var isFlipped:Bool {
        get {
            return true
        }
    }
 
}

