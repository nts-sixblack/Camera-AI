//
//  PhotoPersistenceService.swift
//  Camera
//
//  Handles saving photos to the Photo Library.
//

import Photos
import UIKit

final class PhotoPersistenceService {

  init() {}

  /// Saves photo data to the main photo library
  func save(data: Data) async throws {
    return try await withCheckedThrowingContinuation { continuation in
      PHPhotoLibrary.shared().performChanges {
        let request = PHAssetCreationRequest.forAsset()
        // Use creationRequestForAsset(from:) if we had an image, but for Data:
        request.addResource(with: .photo, data: data, options: nil)
      } completionHandler: { success, error in
        if success {
          continuation.resume()
        } else {
          continuation.resume(throwing: error ?? CameraError.persistenceFailed)
        }
      }
    }
  }
}
