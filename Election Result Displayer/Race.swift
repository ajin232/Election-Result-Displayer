//
//  Race.swift
//  Election Result Displayer
//
//  Created by Andrew on 5/28/25.
//

import Foundation

struct Race: Hashable{
    // custom data type to store election race data
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
    
    var winner: String;
    
    var menuname: String{
        return String(index) + ") " + demname + " vs. " + gopname + " (" + racename + ")"
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(index)
        hasher.combine(racename)
    }
    
    func convert() -> RaceString{
        return RaceString(racename: self.racename, index: self.index, demname: self.demname, dempercent: String(self.dempercent), demvotes: String(self.demvotes), dempic: self.dempic, gopname: self.gopname, goppercent: String(self.goppercent), gopvotes: String(self.gopvotes), goppic: self.goppic, winner: self.winner);
    }
}

class RaceString: Hashable, ObservableObject{
    static func == (lhs: RaceString, rhs: RaceString) -> Bool {
        return (lhs.racename == rhs.racename && lhs.index == rhs.index && lhs.demname == rhs.demname && lhs.gopname == rhs.gopname)
    }
    
    @Published var racename: String;
    @Published var index: Int;
    
    @Published var demname: String;
    @Published var dempercent: String;
    @Published var demvotes: String;
    @Published var dempic: String;
    
    @Published var gopname: String;
    @Published var goppercent: String;
    @Published var gopvotes: String;
    @Published var goppic: String;
    
    @Published var winner: String;
    
    var menuname: String{
        return String(index) + ") " + demname + " vs. " + gopname + " (" + racename + ")"
    }
    
    init(racename: String, index: Int, demname: String, dempercent: String, demvotes: String, dempic: String, gopname: String, goppercent: String, gopvotes: String, goppic: String, winner: String){
        self.racename = racename;
        self.index = index;
        self.demname = demname;
        self.dempercent = dempercent;
        self.demvotes = demvotes;
        self.dempic = dempic;
        self.gopname = gopname;
        self.goppercent = goppercent;
        self.gopvotes = gopvotes;
        self.goppic = goppic;
        self.winner = winner;
    }
    func hash(into hasher: inout Hasher) {
        hasher.combine(index)
        hasher.combine(racename)
    }
    func convert() -> Race?{
        if Float(self.dempercent) == nil || Int(self.demvotes) == nil || Float(self.goppercent) == nil || Int(self.gopvotes) == nil{
            return nil;
        }
        return Race(racename: self.racename, index: Int(self.index), demname: self.demname, dempercent: Float(self.dempercent)!, demvotes: Int(self.demvotes)!, dempic: self.dempic, gopname: self.gopname, goppercent: Float(self.goppercent)!, gopvotes: Int(self.gopvotes)!, goppic: self.goppic, winner: self.winner);
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
    private var placeholder: Race = Race(racename: "Sample Election", index: 0, demname: "Democrat Name", dempercent: 50, demvotes: 10000, dempic: "", gopname: "Republican Name", goppercent: 50, gopvotes: 10000, goppic: "", winner: "N");
    
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
