//
//  AWPlayer+.swift
//  Plum
//
//  Created by Adam Wienconek on 10/10/2019.
//  Copyright © 2019 adam.wienconek. All rights reserved.
//

import UIKit

extension AWPlayer {
    
    public enum QueueIdentifier {
        case all
        case album(String)
        case artist(String)
        case playlist(String)
    }
    
    /*
     - setOriginal
     - check if contains
        T:
            alert
            
        F:
            
     */
    func setQueue(items: [AWTrack], description: String? = nil, identifier: QueueIdentifier? = nil, onContains: ((Int, AlertViewModel) -> Void)?) {
        
        func normal() {
            nowPlayingItem = nil
            setOriginalQueue(with: items, description: description, identifier: identifier)
            setQueue()
            setNowPlayingItem(at: 0)
            play()
        }
        
        if isPlaying,
            items.count > 1,
            items.count != originalQueue.count,
            !originalQueue.elementsEqual(items, by: { track, element -> Bool in
            return track.equals(element)
        }),
            let closure = onContains,
            let item = nowPlayingItem,
            let index = items.firstIndex(where: { $0.equals(item) }) {
            /* Item found and queue will be switched */
            
            let message: String
            
            switch identifier {
            case .all, .none:
                message = LocalizedStringKey.nowPlayingFoundGenericMessage.localized
            case .album(_):
                message = LocalizedStringKey.nowPlayingFoundAlbumMessage.localized
            case .artist(_):
                message = LocalizedStringKey.nowPlayingFoundArtistMessage.localized
            case .playlist(_):
                message = LocalizedStringKey.nowPlayingFoundPlaylistMessage.localized
            }
            
            let actions: [UIAlertAction] = [
                UIAlertAction(title: LocalizedStringKey.nowPlayingFoundContinueOption.localized, style: .default, handler: { _ in
                    self.setOriginalQueue(with: items, description: description, identifier: identifier)
                    self.setQueue()
                }),
                UIAlertAction(title: LocalizedStringKey.nowPlayingFoundStartOverOption.localized, style: .default, handler: { _ in
                    normal()
                }),
                .cancel
            ]
            
            let model = AlertViewModel(title: nil, message: message, actions: actions, style: .actionSheet)
            closure(index, model)
        } else {
            normal()
        }
        
    }
}
