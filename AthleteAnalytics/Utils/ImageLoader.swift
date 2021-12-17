//
//  AsyncImageBinder.swift
//  AthleteAnalytics
//
//  Created by Aidan Lee on 12/17/21.
//

import Foundation
import Combine
import SwiftUI

class ImageLoader: ObservableObject {
    @Published var image: UIImage?
    private let url: URL

    init(url: URL) {
        self.url = url
    }

    deinit {
        cancel()
    }
    private var cancellable: AnyCancellable?
    
    func load(url: URL) {
        if let image: UIImage = CacheManager.shared[url.absoluteString] {
            self.image = image
            return
        }
        cancellable = URLSession.shared.dataTaskPublisher(for: url)
            .map { UIImage(data: $0.data) }
            .handleEvents(receiveOutput: { CacheManager.shared[url.absoluteString] = $0 })
            .replaceError(with: nil)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] in self?.image = $0 }
    }

    func cancel() {
        cancellable?.cancel()
    }
}
