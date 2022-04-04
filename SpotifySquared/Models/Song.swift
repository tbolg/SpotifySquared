//
//  Song.swift
//  SpotifySquared
//
//  Created by Tomas Bolger on 28/3/2022.
//

import Foundation

struct Song {
    var name: String
    var album: String
    var artist: String
    var albumArtworkUrl: String
    var isPlaying: Bool
    var duration: Double
    
    init() {
        self.name = ""
        self.album = ""
        self.artist = ""
        self.albumArtworkUrl = ""
        self.isPlaying = false
        self.duration = 0
    }
    
    init(
        name: String,
        album: String,
        artist: String,
        albumArtworkUrl: String,
        isPlaying: Bool,
        duration: Double
    ) {
        self.name = name
        self.album = album
        self.artist = artist
        self.albumArtworkUrl = albumArtworkUrl
        self.isPlaying = isPlaying
        self.duration = 0
    }
    
}
