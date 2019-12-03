//
//  PlayerViewController.swift
//  Plum
//
//  Created by Adam Wienconek on 04/11/2019.
//  Copyright © 2019 adam.wienconek. All rights reserved.
//

import UIKit
import MediaPlayer

class PlayerViewController: UIViewController {
    
    private let viewModel = PlayerViewModel()
    
    @IBOutlet private weak var artworkImageView: UIImageView!
    
    // MARK: Buttons
    @IBOutlet weak var previousButton: UIButton? {
           didSet {
            previousButton?.addTarget(viewModel, action: #selector(PlayerViewModel.skipToPreviousTrack), for: .touchUpInside)
           }
       }
    @IBOutlet weak var playbackButton: UIButton? {
           didSet {
            playbackButton?.addTarget(viewModel, action: #selector(PlayerViewModel.togglePlayback), for: .touchUpInside)
           }
       }
    @IBOutlet weak var nextButton: UIButton? {
           didSet {
            nextButton?.addTarget(viewModel, action: #selector(PlayerViewModel.skipToNextTrack), for: .touchUpInside)
           }
       }
    @IBOutlet weak var repeatButton: UIButton? {
           didSet {
            repeatButton?.addTarget(viewModel, action: #selector(PlayerViewModel.toggleRepeatMode), for: .touchUpInside)
           }
       }
    @IBOutlet weak var shuffleButton: UIButton? {
           didSet {
            shuffleButton?.addTarget(viewModel, action: #selector(PlayerViewModel.toggleShuffleMode), for: .touchUpInside)
           }
       }
    @IBOutlet weak var routeButton: UIButton? {
        didSet {
            routeButton?.addTarget(self, action: #selector(routePressed), for: .touchUpInside)
        }
    }
    @IBOutlet var playbackButtons: [UIButton]?
    
    // MARK: Labels
    @IBOutlet weak var titleLabel: UILabel?
    @IBOutlet weak var albumLabel: UILabel?

    @IBOutlet weak var elapsedLabel: UILabel?
    @IBOutlet weak var remainingLabel: UILabel?
    
    // MARK: Sliders
    @IBOutlet weak var timeSlider: UISlider? {
        didSet {
            timeSlider?.addTarget(self, action: #selector(timeSliderChanged(_:)), for: .valueChanged)
            timeSlider?.isContinuous = false
            timeSlider?.addTapGesture()
        }
    }
    @IBOutlet weak var volumeView: MPVolumeView? {
        didSet {
            volumeView?.showsRouteButton = false
            volumeView?.slider?.addTapGesture()
        }
    }
    
    // MARK: Other
    @IBOutlet weak var sourceImageView: UIImageView?

    @IBOutlet weak var activityIndicator: UIActivityIndicatorView?
    
    internal lazy var playbackTimer = Timer.scheduledTimer(withTimeInterval: 0.05, repeats: true) { _ in
        self.updatePlaybackTime(time: self.viewModel.currentPlaybackTime)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        playbackTimer.fire()
        viewModel.delegate = self
    }
    
    deinit {
        playbackTimer.invalidate()
    }
    
    // MARK: Required methods
    func nowPlayingModelDidChange(model: PlayerViewModel.NowPlayingModel) {
            DispatchQueue.main.async {
                self.timeSlider?.maximumValue = Float(model.duration)
                self.titleLabel?.setText(model.title)
                self.albumLabel?.setText(model.album + "" + model.artist)
                if let image = model.image {
                    self.artworkImageView.image = image
                } else if let url = model.imageUrl {
                    self.artworkImageView.af_setImage(withURL: url)
                } else {
                    
                }
            }
        }
        
    func nextPlayingModelDidChange(model: PlayerViewModel.NextPlayingModel?) {
            // Empty
        }
    
    // MARK: Methods
    @objc internal func timeSliderChanged(_ sender: UISlider) {
        let newTime = TimeInterval(sender.value)
        viewModel.didChangeTimeSlider(newTime: newTime)
    }
    
    @objc private func routePressed() {
        let mp = volumeView ?? MPVolumeView()
        mp.showRoutePicker()
    }
        
}

extension PlayerViewController: PlayerViewModelDelegate {
    func playbackStateDidChange(state: PlaybackState) {
        DispatchQueue.main.async {
            switch state {
            case .fetching:
                self.playbackButton?.alpha = 0
                self.activityIndicator?.startAnimating()
                self.playbackButtons?.forEach({ $0.isEnabled = false })
            case .initial:
                self.playbackButton?.alpha = 1
                self.activityIndicator?.stopAnimating()
                self.playbackButtons?.forEach({ $0.isEnabled = false })
            default:
                self.playbackButton?.alpha = 1
                self.activityIndicator?.stopAnimating()
                self.playbackButtons?.forEach({ $0.isEnabled = true })
                self.playbackButton?.setImage(UIImage.image(for: state), for: .normal)
            }
        }
    }
    
    func shuffleStateDidChange(enabled: Bool) {
        DispatchQueue.main.async {
            self.repeatButton?.isSelected = enabled
        }
    }
    
    func repeatModeDidChange(mode: RepeatMode) {
        DispatchQueue.main.async {
            let selected = mode != .none
            self.repeatButton?.isSelected = selected
            self.repeatButton?.setTitle(mode.description, for: .normal)
        }
    }
    
    func audioRouteDidChange(route: AudioOutputRoute) {
        DispatchQueue.main.async {
            let title = route.name
            self.routeButton?.setTitle(title, for: .normal)
        }
    }
    
    func updatePlaybackTime(time: TimeInterval) {
        guard let timeSlider = timeSlider else { return }
        DispatchQueue.main.async {
            if timeSlider.isTracking {
                self.elapsedLabel?.text = TimeInterval(timeSlider.value).asString
                self.remainingLabel?.text = "-" + TimeInterval(timeSlider.maximumValue - timeSlider.value).asString
            } else {
                self.elapsedLabel?.text = time.asString
                self.remainingLabel?.text = "-" + (TimeInterval(timeSlider.maximumValue) - time).asString
                self.timeSlider?.value = Float(time)
            }
        }
    }
}

extension UIImage {
    class func image(for playbackState: PlaybackState) -> UIImage {
        switch playbackState {
            case .playing, .fetching:
            return UIImage(systemName: "pause.fill")!
            default:
            return UIImage(systemName: "play.fill")!
        }
    }
}
