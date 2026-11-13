import Flutter
import Photos
import FBSDKCoreKit
import FBSDKShareKit
import Social
import MobileCoreServices



public class ShareUtil{

    public let SUCCESS: String = "SUCCESS"
    public let ERROR_APP_NOT_AVAILABLE: String = "ERROR_APP_NOT_AVAILABLE"
    public let ERROR_OPEN_FAILED: String = "ERROR_OPEN_FAILED"
    public let ERROR_FEATURE_NOT_AVAILABLE_FOR_THIS_VERSON: String = "ERROR_FEATURE_NOT_AVAILABLE_FOR_THIS_VERSON"
    public let ERROR: String = "ERROR"
    public let NOT_IMPLEMENTED: String = "NOT_IMPLEMENTED"

    // Keep the most recently dispatched SDK dialog alive while Facebook handles the app switch.
    private var facebookLinkDialog: ShareDialog?

    let argAttributionURL: String  = "attributionURL";
    let argImagePaths: String  = "imagePaths";
    let argImagePath: String  = "imagePath";
    let argbackgroundImage: String  = "backgroundImage";
    let argMessage: String  = "message";
    let argTitle: String  = "title";
    let argstickerImage: String  = "stickerImage";
    let argAppId: String  = "appId";
    let argBackgroundTopColor: String  = "backgroundTopColor";
    let argBackgroundBottomColor: String  = "backgroundBottomColor";
    let argImages: String  = "images";
    let argVideoFile: String  = "videoFile";



    public func getInstalledApps(result: @escaping FlutterResult){
        let apps = [["instagram","instagram"],["facebook-stories","facebook_stories"],["whatsapp","whatsapp"],["tg","telegram"],["fb-messenger","messenger"],["snssdk1233","tiktok"],["instagram-stories","instagram_stories"],["twitter","twitter"],["sms","message"]]
        var output:[String: Bool] = [:]
        for app in apps {
            if(UIApplication.shared.canOpenURL(URL(string:(app[0])+"://")!)){
                if(app[0] == "facebook-stories"){
                    output["facebook"] = true

                }
                output[app[1]] = true
            }else{
                output[app[1]] = false
            }
        }
        let tiktokAvailable = (output["tiktok"] ?? false) || canOpenUrl(appName: "snssdk1180")
        output["tiktok"] = tiktokAvailable
        output["snssdk1233"] = tiktokAvailable // Preserve the upstream result key for existing consumers.
        result(output)
    }

    public func canOpenUrl(appName:String) -> Bool{
         return UIApplication.shared.canOpenURL(URL(string:appName+"://")!)
    }



    public func shareToInstagramFeed(args : [String: Any?],result: @escaping FlutterResult) {
        let filePath = args[argImagePath] as? String
        if(!isImage(filePath: filePath!)) {
            return shareVideoToInstagramFeed(args: args, result:result)
        } else{
            return shareImageToInstagramFeed(args: args, result:result)
        }
    }

    func isImage(filePath:String)->Bool{
        let ext = NSURL(fileURLWithPath: filePath).pathExtension
        let uti = UTTypeCreatePreferredIdentifierForTag(
            kUTTagClassFilenameExtension,
            ext! as CFString,
            nil)
        if UTTypeConformsTo((uti?.takeRetainedValue())!, kUTTypeImage) {
            return true
        }
        return false
    }


    func shareVideoToInstagramFeed(args : [String: Any?],result: @escaping FlutterResult) {
        let videoFile = args[argImagePath] as? String
        let backgroundVideoUrl = URL(fileURLWithPath: videoFile!)
        let videoData = try? Data(contentsOf: backgroundVideoUrl) as NSData

        getLibraryPermissionIfNecessary { granted in

            guard granted else {
                result(self.ERROR)
                return
            }
        }

        PHPhotoLibrary.shared().performChanges({

            let documentsPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0];
            let filePath = "\(documentsPath)/\(Date().description).mp4"

            videoData!.write(toFile: filePath, atomically: true)
            PHAssetChangeRequest.creationRequestForAssetFromVideo(atFileURL: URL(fileURLWithPath: filePath))
        },
        completionHandler: { success, error in

            if success {

                let fetchOptions = PHFetchOptions()

                fetchOptions.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)]

                let fetchResult = PHAsset.fetchAssets(with: .video, options: fetchOptions)

                if let lastAsset = fetchResult.firstObject {

                    let localIdentifier = lastAsset.localIdentifier
                    let urlFeed = "instagram://library?LocalIdentifier=" + localIdentifier

                    guard
                        let url = URL(string: urlFeed)
                    else {

                        result(self.ERROR_APP_NOT_AVAILABLE)
                        return
                    }
                    DispatchQueue.main.async {

                        if UIApplication.shared.canOpenURL(url) {

                            if #available(iOS 10.0, *) {

                                UIApplication.shared.open(url, options: [:], completionHandler: { (success) in
                                    result(self.SUCCESS)
                                })
                            }
                            else {

                                UIApplication.shared.openURL(url)
                                result(self.SUCCESS)
                            }
                        }
                        else {

                            result(self.ERROR)
                        }
                    }
                }
            }
            else if let error = error {

                print(error.localizedDescription)
            }
            else {

                result(self.ERROR)
            }
        })
    }

    func shareImageToInstagramFeed(args : [String: Any?],result: @escaping FlutterResult) {
            let videoFile = args[argImagePath] as? String
            let backgroundVideoUrl = URL(fileURLWithPath: videoFile!)
            let videoData = try? Data(contentsOf: backgroundVideoUrl) as NSData

            getLibraryPermissionIfNecessary { granted in

                guard granted else {
                    result(self.ERROR)
                    return
                }
            }


            PHPhotoLibrary.shared().performChanges({

                let documentsPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0];
                let filePath:String
                     filePath = "\(documentsPath)/\(Date().description).jpeg"


                videoData!.write(toFile: filePath, atomically: true)
                    PHAssetChangeRequest.creationRequestForAssetFromImage(atFileURL: URL(fileURLWithPath: filePath))

            },
            completionHandler: { success, error in

                if success {

                    let fetchOptions = PHFetchOptions()

                    fetchOptions.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)]
                    let type:PHAssetMediaType;
                        type = PHAssetMediaType.image


                    let fetchResult = PHAsset.fetchAssets(with: type, options: fetchOptions)

                    if let lastAsset = fetchResult.firstObject {

                        let localIdentifier = lastAsset.localIdentifier
                        let urlFeed = "instagram://library?LocalIdentifier=" + localIdentifier

                        guard
                            let url = URL(string: urlFeed)
                        else {

                            result(self.ERROR_APP_NOT_AVAILABLE)
                            return
                        }
                        DispatchQueue.main.async {

                            if UIApplication.shared.canOpenURL(url) {

                                if #available(iOS 10.0, *) {

                                    UIApplication.shared.open(url, options: [:], completionHandler: { (success) in
                                        result(self.SUCCESS)
                                    })
                                }
                                else {

                                    UIApplication.shared.openURL(url)
                                    result(self.SUCCESS)
                                }
                            }
                            else {

                                result(self.ERROR)
                            }
                        }
                    }
                }
                else if let error = error {

                    print(error.localizedDescription)
                }
                else {

                    result(self.ERROR)
                }
            })
        }

    func getLibraryPermissionIfNecessary(completionHandler: @escaping  (Bool) -> Void) {

        guard PHPhotoLibrary.authorizationStatus() != .authorized else {
            completionHandler(true)
            return
        }

        PHPhotoLibrary.requestAuthorization { status in
            completionHandler(status == .authorized)
        }
    }


    public func shareToSystem(args : [String: Any?],result: @escaping FlutterResult) {
        let text = args[argMessage] as? String
        let filePaths = args[argImagePaths] as? [String]
        var data : [Any] = [text!];
        if filePaths != nil{
            for filePath in filePaths!{
                data.append(URL(fileURLWithPath: filePath))
            }
        }
        let activityViewController = UIActivityViewController(activityItems: data, applicationActivities: nil)
        UIApplication.topViewController()?.present(activityViewController, animated: true, completion: nil)
        result(SUCCESS)
    }


    func copyToClipboard(args : [String: Any?],result: @escaping FlutterResult){
        let message = args[self.argMessage] as? String
        UIPasteboard.general.string = message!
        result(SUCCESS)
    }



    private func openTextShare(
        args: [String: Any?],
        scheme: String,
        host: String,
        path: String = "",
        queryName: String = "text",
        result: @escaping FlutterResult
    ) {
        guard let message = args[argMessage] as? String,
              !message.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty,
              let url = ShareURLBuilder.makeURL(
                scheme: scheme, host: host, path: path, queryName: queryName, value: message
              ) else {
            result(ERROR)
            return
        }
        guard UIApplication.shared.canOpenURL(url) else {
            result(ERROR_APP_NOT_AVAILABLE)
            return
        }
        if #available(iOS 10.0, *) {
            UIApplication.shared.open(url, options: [:]) { opened in
                result(opened ? self.SUCCESS : self.ERROR_OPEN_FAILED)
            }
        } else {
            result(UIApplication.shared.openURL(url) ? SUCCESS : ERROR_OPEN_FAILED)
        }
    }

    func shareToWhatsApp(args: [String: Any?], result: @escaping FlutterResult) {
        openTextShare(args: args, scheme: "whatsapp", host: "send", result: result)
    }

    func shareToFacebookPost(args : [String: Any?],result: @escaping FlutterResult, delegate: SharingDelegate) {
        let message = args[self.argMessage] as? String
        let imagePaths = args[self.argImagePaths] as? [String]

        let content = SharePhotoContent()
        var photos : [SharePhoto] = []
        for image in imagePaths! {
            let photo = SharePhoto(image: UIImage.init(contentsOfFile: image)!, isUserGenerated: true)
            photos.append(photo)
        }
        content.photos = photos
        content.hashtag = Hashtag(message!)
        let dialog = ShareDialog(
            viewController: UIApplication.shared.windows.first!.rootViewController,
            content: content,
            delegate: delegate
        )
        do {
            try dialog.validate()
        } catch {
           result(ERROR)
        }
        dialog.show()
        result(self.SUCCESS)

    }


    func shareToTelegram(args: [String: Any?], result: @escaping FlutterResult) {
        openTextShare(args: args, scheme: "tg", host: "msg", result: result)
    }

    public func shareToInstagramDirect(args: [String: Any?], result: @escaping FlutterResult) {
        openTextShare(args: args, scheme: "instagram", host: "sharesheet", result: result)
    }

    public func shareToMessenger(args: [String: Any?], result: @escaping FlutterResult) {
        guard let link = args[argMessage] as? String,
              ShareURLBuilder.httpURL(from: link) != nil else {
            result(ERROR)
            return
        }
        openTextShare(
            args: args, scheme: "fb-messenger", host: "share", path: "/", queryName: "link", result: result
        )
    }

    public func shareFacebookLink(args: [String: Any?], result: @escaping FlutterResult) {
        guard let value = args["url"] as? String,
              let url = ShareURLBuilder.httpURL(from: value) else {
            result(ERROR)
            return
        }
        let content = ShareLinkContent()
        content.contentURL = url
        let dialog = ShareDialog(
            viewController: UIApplication.topViewController(), content: content, delegate: nil
        )
        dialog.mode = .native
        guard dialog.canShow else {
            result(ERROR_APP_NOT_AVAILABLE)
            return
        }
        facebookLinkDialog = dialog
        if dialog.show() {
            result(SUCCESS)
        } else {
            facebookLinkDialog = nil
            result(ERROR_OPEN_FAILED)
        }
    }

    public func shareToSms(args : [String: Any?],result: @escaping FlutterResult){
        let message = args[self.argMessage] as? String
        if #available(iOS 10, *){
            let urlString = "sms:?&body=\(message!)"
            if(!canOpenUrl(appName: "sms")){
                result(ERROR_APP_NOT_AVAILABLE)
                return
            }
            let tgUrl = URL.init(string: urlString.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed)!)
            UIApplication.shared.open(tgUrl!, options: [:], completionHandler: nil)
        }
        result(SUCCESS)
    }

    public func shareToFacebookStory(args : [String: Any?],result: @escaping FlutterResult) {
        let appId = args[self.argAppId] as? String
        let imagePath = args[self.argbackgroundImage] as? String
        let argVideoFile = args[self.argVideoFile] as? String
        let imagePathSticker = args[self.argstickerImage] as? String
        let backgroundTopColor = args[self.argBackgroundTopColor] as? String
        let backgroundBottomColor =  args[self.argBackgroundBottomColor] as? String
        let attributionURL =  args[self.argAttributionURL] as? String


        guard let facebookURL = URL(string: "facebook-stories://share") else {
            result(ERROR_APP_NOT_AVAILABLE)
            return
        }


        if (UIApplication.shared.canOpenURL(facebookURL)) {
            var pasteboardItems = [
                "com.facebook.sharedSticker.attributionURL": [attributionURL ?? ""],
                "com.facebook.sharedSticker.backgroundTopColor": backgroundTopColor ?? "",
                "com.facebook.sharedSticker.backgroundBottomColor": backgroundBottomColor ?? "",
                "com.facebook.sharedSticker.appID": appId as Any,
            ]
            var backgroundImage: UIImage?;
            if(!(imagePath==nil)){
                backgroundImage =  UIImage.init(contentsOfFile: imagePath!)
                if (backgroundImage != nil) {
                     pasteboardItems["com.facebook.sharedSticker.backgroundImage"] = backgroundImage
                 }
            }
            var stickerImage: UIImage?;
            if(!(imagePathSticker==nil)){
                stickerImage =  UIImage.init(contentsOfFile: imagePathSticker!)
                if (stickerImage != nil) {
                    pasteboardItems["com.facebook.sharedSticker.stickerImage"] = stickerImage
                }
            }
            var backgroundVideoData:Any?;
            if(!(argVideoFile==nil)){
                let backgroundVideoUrl = URL(fileURLWithPath: argVideoFile!)
                backgroundVideoData = try? Data(contentsOf: backgroundVideoUrl)
                if (backgroundVideoData != nil) {
                    pasteboardItems["com.facebook.sharedSticker.backgroundVideo"] = backgroundVideoData
                }
            }


                if #available(iOS 10, *){
                    let pasteboardOptions = [
                        UIPasteboard.OptionsKey.expirationDate: Date().addingTimeInterval(60 * 5)
                    ]
                    UIPasteboard.general.setItems([pasteboardItems], options: pasteboardOptions)
                    UIApplication.shared.open(facebookURL, options: [:])
                }
                result(self.SUCCESS)
                return
        } else {
            result(ERROR_APP_NOT_AVAILABLE)
        }
    }


    func shareToTwitter(args: [String: Any?], result: @escaping FlutterResult) {
        let images = args[argImagePaths] as? [String] ?? []
        guard !images.isEmpty else {
            openTextShare(args: args, scheme: "twitter", host: "post", queryName: "message", result: result)
            return
        }
        // Preserve upstream media sharing; the text-only path does not use the legacy Social composer.
        guard canOpenUrl(appName: "twitter"),
              let title = args[argMessage] as? String,
              let composeController = SLComposeViewController(forServiceType: SLServiceTypeTwitter) else {
            result(ERROR_APP_NOT_AVAILABLE)
            return
        }
        for imagePath in images {
            if let image = UIImage(contentsOfFile: imagePath) {
                composeController.add(image)
            }
        }
        composeController.setInitialText(title)
        guard let presenter = UIApplication.topViewController() else {
            result(ERROR)
            return
        }
        presenter.present(composeController, animated: true) {
            result(self.SUCCESS)
        }
    }

    func shareToInstagramStory(args : [String: Any?],result: @escaping FlutterResult) {
        if #available(iOS 10.0, *){
            let appId = args[self.argAppId] as? String
            let imagePath = args[self.argbackgroundImage] as? String
            let argVideoFile = args[self.argVideoFile] as? String
            let imagePathSticker = args[self.argstickerImage] as? String
            let backgroundTopColor = args[self.argBackgroundTopColor] as? String
            let backgroundBottomColor =  args[self.argBackgroundBottomColor] as? String
            let attributionURL =  args[self.argAttributionURL] as? String


            guard let instagramURL = URL(string: "instagram-stories://share?source_application=\(appId!)") else {
                result(ERROR_APP_NOT_AVAILABLE)
                return
            }


            if (UIApplication.shared.canOpenURL(instagramURL)) {
                var backgroundImage: UIImage?;
                if(!(imagePath==nil)){
                    backgroundImage =  UIImage.init(contentsOfFile: imagePath!)
                }
                var stickerImage: UIImage?;
                if(!(imagePathSticker==nil)){
                    stickerImage =  UIImage.init(contentsOfFile: imagePathSticker!)
                }
                var backgroundVideoData:Any?;
                if(!(argVideoFile==nil)){
                    let backgroundVideoUrl = URL(fileURLWithPath: argVideoFile!)
                    backgroundVideoData = try? Data(contentsOf: backgroundVideoUrl)
                }
                let pasteboardItems = [
                    [
                        "com.instagram.sharedSticker.attributionURL": attributionURL ?? "",
                        "com.instagram.sharedSticker.stickerImage": stickerImage ?? "",
                        "com.instagram.sharedSticker.backgroundVideo": backgroundVideoData ?? "",
                        "com.instagram.sharedSticker.backgroundImage": backgroundImage ?? "",
                        "com.instagram.sharedSticker.backgroundTopColor": backgroundTopColor ?? "",
                        "com.instagram.sharedSticker.backgroundBottomColor": backgroundBottomColor ?? "",
                    ]
                ]
                let pasteboardOptions = [
                    UIPasteboard.OptionsKey.expirationDate: Date().addingTimeInterval(60 * 5)
                ]
                UIPasteboard.general.setItems(pasteboardItems, options: pasteboardOptions)
                UIApplication.shared.open(instagramURL, options: [:])
                result(self.SUCCESS)
            } else {
                result(ERROR_APP_NOT_AVAILABLE)
            }
        }else{
            result(ERROR_FEATURE_NOT_AVAILABLE_FOR_THIS_VERSON)
        }

    }


    public func shareImageToWhatsApp(args : [String: Any?],result: @escaping FlutterResult, delegate: SharingDelegate) {
      let imagePath = args[self.argImagePath] as? String

      guard let url = URL(string: imagePath!) else {
        result(FlutterError(code: "INVALID_PATH", message: "The image path is invalid", details: nil))
        return
      }

      guard let image = UIImage(contentsOfFile: url.path) else {
        result(FlutterError(code: "IMAGE_ERROR", message: "Could not load image", details: nil))
        return
      }


        let urlWhats = "whatsapp://app"
        if let urlString = urlWhats.addingPercentEncoding(withAllowedCharacters:CharacterSet.urlQueryAllowed) {
            if let whatsappURL = URL(string: urlString) {

                if UIApplication.shared.canOpenURL(whatsappURL as URL) {

                        if let imageData = image.jpegData(compressionQuality: 1.0) {
                            let tempFile = URL(fileURLWithPath: NSHomeDirectory()).appendingPathComponent("Documents/whatsAppTmp.wai")
                            do {
                                try imageData.write(to: tempFile, options: .atomic)
                                let documentInteractionController = UIDocumentInteractionController(url: tempFile)
                                documentInteractionController.uti = "net.whatsapp.image"
                                documentInteractionController.presentOpenInMenu(from: CGRect.zero, in: UIApplication.topViewController()!.view, animated: true)

                            } catch {
                                print(error)
                            }
                        }


                } else {
                   print("Cannot open whatsapp")
                }
            }
        }
    }

}

extension UIApplication {
    class func topViewController(controller: UIViewController? = UIApplication.shared.keyWindow?.rootViewController) -> UIViewController? {
        if let navigationController = controller as? UINavigationController {
            return topViewController(controller: navigationController.visibleViewController)
        }
        if let tabController = controller as? UITabBarController {
            if let selected = tabController.selectedViewController {
                return topViewController(controller: selected)
            }
        }
        if let presented = controller?.presentedViewController {
            return topViewController(controller: presented)
        }
        return controller
    }
}

class TransparentViewController: UIViewController {
    override func viewDidLoad() {
        view.backgroundColor = UIColor.clear
        view.isOpaque = false
    }
}
