//
//  NotificationService.swift
//  NotificationServiceExtension
//
//  Created by 전예린 on 11/30/24.
//

import UserNotifications

class NotificationService: UNNotificationServiceExtension {

    var contentHandler: ((UNNotificationContent) -> Void)?
        var bestAttemptContent: UNMutableNotificationContent?

        override func didReceive(_ request: UNNotificationRequest, withContentHandler contentHandler: @escaping (UNNotificationContent) -> Void) {
            self.contentHandler = contentHandler
            bestAttemptContent = (request.content.mutableCopy() as? UNMutableNotificationContent)

            if let bestAttemptContent = bestAttemptContent, let imageUrlString = request.content.userInfo["image_url"] as? String, let imageUrl = URL(string: imageUrlString) {
                downloadImage(from: imageUrl) { localUrl in
                    if let localUrl = localUrl {
                        do {
                            let attachment = try UNNotificationAttachment(identifier: "image", url: localUrl, options: nil)
                            bestAttemptContent.attachments = [attachment]
                        } catch {
                            print("Failed to create attachment: \(error)")
                        }
                    }
                    contentHandler(bestAttemptContent)
                }
            } else {
                contentHandler(request.content)
            }
        }

        override func serviceExtensionTimeWillExpire() {
            if let contentHandler = contentHandler, let bestAttemptContent = bestAttemptContent {
                contentHandler(bestAttemptContent)
            }
        }

        private func downloadImage(from url: URL, completion: @escaping (URL?) -> Void) {
            let task = URLSession.shared.downloadTask(with: url) { tempUrl, _, _ in
                completion(tempUrl)
            }
            task.resume()
        }
}
