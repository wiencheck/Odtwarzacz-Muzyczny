//
//  LocalizedStringKeys.swift
//  Plum 2
//
//  Created by Adam Wienconek on 03.06.2018.
//  Copyright © 2018 Adam Wienconek. All rights reserved.
//

import Foundation

extension String {
    func localized(bundle: Bundle = .main, tableName: LanguageTableKey = .english) -> String {
        return NSLocalizedString(self, tableName: tableName.rawValue, value: "**\(self)**", comment: "")
    }
}

protocol Localizable {
    var localized: String {get}
}

extension Localizable where Self: RawRepresentable, Self.RawValue == String {
    var localized: String {
        return self.rawValue.localized(tableName: .polish)
    }
    
}

enum LocalizedStringKey: String, Localizable {
    
    case unknownCase
    
    // MARK: Grouping
    case songs
    case albums
    case artists
    case playlists
    case playlist
    case folders
    case favourites
    case settings
    case fullVersion
    
    // MARK: zzz
    case unknownArtist
    case unknownTitle
    case unknownAlbum
    case unknownPlaylist
    case noLyrics
    case artist
    case album
    case search
    case options
    case more
    case showMore
    case showLess
    case pickSongs
    case goToAlbum
    case goToArtist
    case goToPlaylist
    
    // MARK: Sorting options
    case sorting
    case titleAscending
    case titleDescending
    case ratingAscending
    case ratingDescending
    case tracksAscending
    case tracksDescending
    case albumsAscending
    case albumsDescending
    case albumAscending
    case albumDescending
    case artistAscending
    case artistDescending
    case typeAscending
    case typeDescending
    case addedAscending
    case addedDescending
    case yearAscending
    case yearDescending
    
    case lessThan
    case moreThan
    
    case today
    case yesterday
    case thisWeek
    case lastWeek
    case thisMonth
    case lastMonth
    case halfYear
    case thisYear
    case lastYear
    case moreYear
    
    // MARK: Layout and appearance
    case grid
    case darkMode
    case showRating
    
    // MARK: User communication
    case errorOccurred
    case errorOccurredExpand
    case areYouSure
    case miniplayerWelcome
    case miniplayerPick
    case yes
    case no
    case cancel
    case proceed
    case shouldShuffleItems
    case shouldContinuePlaying
    case doShuffle
    case shuffle
    case willBePlayedNext
    case willBePlayedLast
    case searchScopeLibrary
    case searchScopeCurrentScreen
    case backButtonTitle
    case expand
    case compact
    case noFavouritesMessage
    case wasAddedToFavourites
    case wasRemovedFromFavourites
    case addedToPlaylist
    case rootSetAsHome
    case mediaPickerPickItems
    case nowPlayingFoundGenericMessage
    case nowPlayingFoundArtistMessage
    case nowPlayingFoundContinueOption
    case nowPlayingFoundAlbumMessage
    case nowPlayingFoundPlaylistMessage
    case nowPlayingFoundStartOverOption
    case markAsRead
    case allSongs
    case artistImageDownload
    case artistImagePick
    case artistImagePaste
    case artistImageRemove
    case addToPlaylist
    case addSongToPlaylist
    case playlistPickerPrompt
    case excludeFromQueue
    case nowPlayingAddPlaylist
    case nowPlayingLyrics
    case nowPlayingRating
    case playlistDescriptionCreatedBy
    case playlistSmartDescription
    case playlistGeniusDescription
    case loading
    case variousArtists
    case miniplayerEmptyMessage
    case albumSetPrimary
    case delete
    case clear
    case openSettings
    case spotifyLoggedInMessage
    case spotifyLoggedOutMessage
    case sourcedPlaylistDescription
    case restartAppToTakeEffect
    case addSongToPlaylistFirst
    case addSongToPlaylistSecond
    
    case emptyViewTitle
    case emptyViewMessage
    case emptyFavouritesTitle
    case emptyFavouritesMessage
    
    case favouriteTracksPlaylistTitle
    case favouriteTracksPlaylistDescription
    
    case addToFavouritesButtonTitle
    case removeFromFavouritesButtonTitle
    case addToLibraryButtonTitle
    case removeFromLibraryButtonTitle
    
    // MARK: Loading
    case loadingPlaylist
    case loadingiTunes
    case loggingSpotify
    case loadingSpotify
    
    // MARK: Feedback and review
    case areYouEnjoyingMessage
    case openReddit
    case openTwitter
    case openAppStore
    case openMail
    case leaveFeedback
    case leaveFeedbackMessage
    case leaveReview
    
    // MARK: Playlist Attributes
    case playlistAttributeFolder
    case playlistAttributeGenius
    case playlistAttributeSmart
    case playlistAttributeShared
    case playlistAttributePrivate
    case playlistAttributeSourced
    
    case showRecentlyAddedSectionOption
    case recentlyAddedSectionTitle
    case showAlbumsAboveThreshold
    case showArtistsAboveThreshold
    
    // MARK: Onboarding
    case swipeLeftToBegin
    case setAsPrimarySwitchDescription
    
    case onboardingSourcesTitle
    case onboardingSourcesText
    case onboardingSourcesSpotifyFooter
    case onboardingSourcesiTunesFooter
    
    case onboardingHintsTitle
    case onboardingHintsText
    case onboardingSwitchText
    
    case onboardingPurchaseTitle
    case onboardingPurchaseText
    case onboardingPurchaseTitleSuccess
    case onboardingPurchaseTextSuccess
    case onboardingPurchasePrimaryButton
    case onboardingPurchaseSecondaryButton
    
    case onboardingFinitoTitle
    case onboardingFinitoText
    case onboardingFinitoHintText
    case onboardingFinitoPrimaryButton
    case onboardingFinitoSecondaryButton
    
    case iTunesDescription
    case iTunesPrimaryDescription
    case iTunesPrimaryButtonTitle
    case iTunesSuccessButtonTitle
    case iTunesFailureButtonTitle
    
    case spotifyDescription
    case spotifyPrimaryDescription
    case spotifyPrimaryButtonTitle
    case spotifyLoggingButtonTitle
    case spotifySuccessButtonTitle
    case spotifyFailureButtonTitle
    
    case showTutorialsSwitchDescription
    case showTutorialsDescription
    
    case launchButtonTitle
    case quickSettingsButtonTitle
    
    // MARK: Settings
    case unlockedMessage
    case spotlightSettings
    case otherSettings
    case appearanceSettings
    case sourcesSettings
    
    // MARK: Spotlight Settings
    case shouldIndexSongs
    case shouldIndexAlbums
    case shouldIndexPlaylists
    case shouldIndexArtists
    case shouldIndexFooter
    case lastSpotlightUpdate
    case indexSpotlight
    case indexSpotlightFooter
    
    // MARK: Appearance Settings
    case gridSectionTitle
    case albumsGridOptionTitle
    case artistsGridOptionTitle
    case playlistsGridOptionTitle
    case gridSectionFooter
    case biggerCellsOptionTitle
    case biggerCellsFooter
    case colorizeOptionTitle
    case colorizeFooter
    case colorizeRandomOptionTitle
    case colorizeRandomFooter
    case detailedHeadersOptionTitle
    case detailedHeadersFooter
    case themeSectionTitle
    case tintColorFooter
    
    // MARK: Other settings
    case resetTutorialsButtonTitle
    case resetTutorialsFooter
    case reduceDataOptionTitle
    case reduceDataFooter
    case swipeGestureFooter
    case swipeGestureOptionTitle
    case downloadBiosOptionTitle
    case downloadBiosFooter
    case clearCacheOptionTitle
    case clearCacheButtonTitle
    case clearCacheFooter
    case clearCacheAlertMessage
    
    // MARK: Sources settings
    case audioQualityOptionTitle
    case audioQualityFooter
    case audioQualityLow
    case audioQualityMedium
    case audioQualityHigh
    case primarySourceOptionTitle
    case primarySourceFooter
    
    // MARK: Spotify
    case spotifyAllowInAppMessage
    case spotifyOpenApp
    case openInSpotify
    
    // MARK: Purchases
    case thankYouForPurchaseTitle
    case thankYouForPurchaseDetail
    case restore
    case unlockFor
    case featuresLockedTitle
    case featuresLockedMessage
    case goToUnlockScreen
    case donateTiny
    case donateSmall
    case donateMedium
    case donateBig
    case donateEnourmous
    case donateCellTitle
    case donateMessageTitle
    case donateMessageDescription
    case donateCancel
    case donateSuccessTitle
    case donateSuccessMessage
    
    // MARK: Full features
    case fullVersionUnlockTitle
    case fullFeatureGridTitle
    case fullFeatureGridDescription
    case fullFeatureSpotlightTitle
    case fullFeatureSpotlightDescription
    case fullFeatureThemeTitle
    case fullFeatureThemeDescription
    case fullFeatureTintTitle
    case fullFeatureTintDescription
    case fullFeatureLastFmTitle
    case fullFeatureLastFmDescription
    
    // MARK: Queue
    case playNow
    case addNext
    case addLast
    case nowPlaying
    case previous
    case upNext
    case userQueue
    case queue
    case editing
    case remove
    case number_selected
    case outOf
    case tracksRemaining
    case endOfQueue
    
    // MARK: Welcome screen
    case libraryNotDeterminedMessage
    case libraryNotDeterminedButtonTitle
    case libraryDeniedMessage
    case libraryDeniedButtonTitle
    
    // MARK: Plurarization
    case singleSong
    case multipleSongs
    case singleAlbum
    case multipleAlbums
    case singleArtist
    case multiplePlaylists
    
    case proTip
    // MARK: Tutorials
    enum Tutorial: String, Localizable {
        case longPressOnCellForMoreOptions
        case pressOnArtworkForMoreOptions
        case pressOnArtistImageToChangeIt
        case pressOnArtistNameToOpenArtistPage
        case pressOnSongWhileMusicIsPlayingToShowQueueOptions
        case pressAndDragSongToReorderQueue
        case pressHeartButtonToAddToFavourite
        case useSearchInPlaylist
        case pressReturnInSearchToPerformActionOnFirstElement
        case pullToRefresh
        case swipeUpForQueue
        case pressAlbumNameToOpenScreen
        case pressBioToExpand
        case swipeBioToDelete
    }
    
    func pluralForm(for count: Int) -> String {
        var c = count
        var dictKey = ""
        if count > 14 {
            dictKey += "*"
            c = count % 10
        }
        dictKey += "\(c)\(self.rawValue)"
        return dictKey.localized(tableName: .polish)
    }
    
    static func addSongToPlaylist(name: String) -> String {
        return "\(LocalizedStringKey.addSongToPlaylistFirst.localized) \"\(name)\" \(LocalizedStringKey.addSongToPlaylistSecond.localized)"
    }
}

extension LocalizedStringKey: CustomStringConvertible {
    var description: String {
        return self.localized
    }
}
