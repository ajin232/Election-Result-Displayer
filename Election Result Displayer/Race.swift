//
//  Race.swift
//  Election Result Displayer
//
//  Created by Andrew on 5/28/25.
//

import Foundation

struct Race: Hashable{
    var racename: String;
    var index: Int;
    
    var demname: String;
    var dempercent: Float;
    var demvotes: Int;
    var dempic: String;
    
    var gopname: String;
    var goppercent: Float;
    var gopvotes: Int;
    var goppic: String;
    
    var menuname: String{
        return String(index) + ") " + demname + " vs. " + gopname + " (" + racename + ")"
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(index)
        hasher.combine(racename)
    }
}

class ElectionData: ObservableObject{
    @Published var data: Array<Race>;
    
    init(){
        self.data = [Race]();
    }
    
    func replace(with input: Array<Race>){
        self.data.removeAll();
        self.data = input;
    }
    
    func flush(){
        self.data.removeAll();
    }
}


class CurrentRace: ObservableObject{
    @Published var race: Race;
    private var placeholder: Race = Race(racename: "Sample Election", index: 0, demname: "Democrat Name", dempercent: 50, demvotes: 10000, dempic: "", gopname: "Republican Name", goppercent: 50, gopvotes: 10000, goppic: "");
    
    init(){
        self.race = self.placeholder;
    }
    
    func replace(_ input: Race){
        self.race = input;
    }
    
    func flush(){
        self.race = self.placeholder;
    }
}
