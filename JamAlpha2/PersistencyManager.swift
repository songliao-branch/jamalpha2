//
//  PersistencyManager.swift
//  JamAlpha2
//
//  Created by Song Liao on 5/29/15.
//  Copyright (c) 2015 Song Liao. All rights reserved.
//

import Foundation

class PersistencyManager: NSObject{
    
    private var artists = [Artist]()
    
    override init(){
        
        let theATeam = Song(title: "The A Team")
        let drunk = Song(title: "Drunk")
        let UNI = Song(title: "UNI")
        let grade8 = Song(title: "Grade8")
        let smallBump = Song(title: "Small Bump")
        let this = Song(title: "This")
        let legoHouse = Song(title:"Lego House")
        let kissMe = Song(title: "Kiss Me")
        let giveMeLove = Song(title: "Give Me Love")
        let songs1 = [theATeam,drunk,UNI,grade8,smallBump,this,legoHouse,kissMe,giveMeLove]
        let plus = Album(name: "+", songs: songs1)
        
        let one = Song(title: "One")
        let mess = Song(title: "mess")
        let sing = Song(title: "Sing")
        let dont = Song(title: "Don't")
        let nina = Song(title: "Nina")
        let photograph = Song(title: "Photograph")
        let bloodstream = Song(title: "Bloodstream")
        let sea = Song(title:"Tenerife Sea")
        let runnaway = Song(title: "Runnaway")
        let theman = Song(title: "The Man")
        let songs2 = [one,mess,sing,dont,nina,photograph,bloodstream,sea,runnaway,theman]
        let multiply = Album(name: "X", songs: songs2)
        
        let albs = [plus,multiply]
        let ed = Artist(name: "Ed Sheeran", albums: albs)
        
        artists = [ed]

    }
    
    func getArtists() -> [Artist] {
        return self.artists
    }

}
