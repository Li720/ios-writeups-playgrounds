//
//  ViewController.swift
//  Arc-Memory-Project
//
//  Created by Li Sheng Tai on 2017-09-15.
//  Copyright © 2017 lst. All rights reserved.
//

import UIKit



class ViewController: UIViewController {
    
    
    let valQueue = DispatchQueue(label: "com.nineIX.arc-mem.val", qos: DispatchQoS.background, attributes: DispatchQueue.Attributes.concurrent, autoreleaseFrequency: DispatchQueue.AutoreleaseFrequency.never)
    var valBreak = false;
    
    let refQueue = DispatchQueue(label: "com.nineIX.arc-mem.ref", qos: DispatchQoS.background, attributes: DispatchQueue.Attributes.concurrent, autoreleaseFrequency: DispatchQueue.AutoreleaseFrequency.never)
    var refBreak = false;
    
    @IBAction func endValQueue(_ sender: Any) {
        self.valBreak = true;
    }
    @IBAction func createValueTypes() {
        struct ValType {
            let data: Int
        }
        
        valQueue.async {
            var vals:[ValType] = []
            for index in 0...9999 {
                vals.append(ValType(data:index))
            }
            while true {
                print(vals.count)
                if self.valBreak {
                    self.valBreak = false
                    break;
                }
            }
        }
    }
    
    @IBAction func endrefQueue(_ sender: Any) {
        self.refBreak = true;
    }
    @IBAction func createRefTypes() {
        class RefType {
            let data: Int
            init(data: Int) {
                self.data = data
            }
        }
        refQueue.async {
            var refs:[RefType] = []
            for index in 0...9999 {
                 refs.append(RefType(data:index))
            }
            while true {
                print(refs.count)
                if self.refBreak {
                    self.refBreak = false
                    break;
                }
            }
        }
    }
}

