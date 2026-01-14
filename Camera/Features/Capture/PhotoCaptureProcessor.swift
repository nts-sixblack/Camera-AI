//
//  PhotoCaptureProcessor.swift
//  Camera
//
//  Handles photo capture delegate callbacks.
//

import AVFoundation
import Foundation

final class PhotoCaptureProcessor: NSObject, AVCapturePhotoCaptureDelegate {

  private let completion: (Result<Data, Error>) -> Void

  init(completion: @escaping (Result<Data, Error>) -> Void) {
    self.completion = completion
  }

  func photoOutput(
    _ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?
  ) {
    if let error = error {
      completion(.failure(error))
      return
    }

    guard let data = photo.fileDataRepresentation() else {
      completion(.failure(CameraError.captureFailed))
      return
    }

    completion(.success(data))
  }
}

enum CameraError: Error {
  case captureFailed
  case persistenceFailed
}
