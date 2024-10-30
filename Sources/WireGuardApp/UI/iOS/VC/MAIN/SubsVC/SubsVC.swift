// SPDX-License-Identifier: MIT
// Copyright © 2018-2023 WireGuard LLC. All Rights Reserved.

import UIKit
import ProgressHUD
import PassKit
import StoreKit
import PassKit

class SubsVC: UIViewController {

    @IBOutlet weak var currentPlanView: UIView!
    @IBOutlet weak var currentPlanLabel: UILabel!
    @IBOutlet weak var leftBackgroundView: UIView!
    @IBOutlet weak var daysLeftLabel: UILabel!
    @IBOutlet weak var hoursLeftLabel: UILabel!
    @IBOutlet weak var minutesLeftLabel: UILabel!
    @IBOutlet weak var secondsLeftLabel: UILabel!
    @IBOutlet weak var daysLabel: UILabel!
    @IBOutlet weak var hoursLabel: UILabel!
    @IBOutlet weak var minutesLabel: UILabel!
    @IBOutlet weak var secondsLabel: UILabel!

    @IBOutlet weak var choosePlanView: UIView!
    @IBOutlet weak var choosePlanLabel: UILabel!
    @IBOutlet weak var exploreLabel: UILabel!
    @IBOutlet weak var tarifTableView: UITableView!
    @IBOutlet weak var linksTextView: UITextView!
    @IBOutlet weak var heightTarifTableViewConstraint: NSLayoutConstraint!

    @IBOutlet weak var buyBackgroundView: UIView!
    @IBOutlet weak var buyButton: UIButton!

    @IBOutlet weak var promocodeView: UIView!
    @IBOutlet weak var promocodeTextField: HeroTextField!
    @IBOutlet weak var subscribeForFreeButton: UIButton!

    private var tarifs: [Tarif] = UserDefaultsManager.shared.tarifs

    private var selectedIndex = -1

#if DEBUG
    private let isSandbox = true
#else
    private let isSandbox = false
#endif

    // private var productsArray: [SKProduct] = []

    private var timer: Timer?

    private var checkStatusTimer: Timer?
    private var dateStartTimer: TimeInterval?

    private var paymentRequest: PKPaymentRequest?
    private var transactionId: String = ""
    private var successPayment: Bool = false
    private var amount: Float = 0
    private var uniqId = ""

    private var processVC: ProcessVC?

    override func viewDidLoad() {
        super.viewDidLoad()

        self.currentPlanView.isHidden = true
//        self.choosePlanView.isHidden = true
        self.promocodeView.isHidden = true

//        SKPaymentQueue.default().add(self)

        self.configureUI()
        self.setTargets()

        self.sendPushToken()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.requestTarrifs()

        SubscribtionManager.shared.getStatus()

        self.startTimer()
    }

    deinit {
//        SKPaymentQueue.default().remove(self)
        NotificationCenter.default.removeObserver(self)
    }
}
extension SubsVC: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.selectedIndex = self.selectedIndex != indexPath.row ? indexPath.row : -1
        self.buyButton.alpha = self.selectedIndex == -1 ? 0.5 : 1
        self.tarifTableView.reloadData()
    }
}

extension SubsVC: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.tarifs.count
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 76
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: TarifTableViewCell.className) ?? UITableViewCell()

        if let cell = cell as? TarifTableViewCell {
            cell.setup(data: self.tarifs[indexPath.row], isSelected: self.selectedIndex == indexPath.row)
        }

        return cell
    }
}

private extension SubsVC {
    func setTargets() {
        self.buyButton.addTarget(self, action: #selector(subscribeButtonTouch), for: .touchUpInside)
        self.subscribeForFreeButton.addTarget(self, action: #selector(subsctibeForFreeButtonTouch), for: .touchUpInside)
    }

    func setSubscribtions() {
        NotificationCenter.default.addObserver(self, selector: #selector(self.updateSubscribtion), name: .finishSubscribtionUpdated, object: nil)
    }

    @objc
    func startTimer() {
        self.timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(self.updateSubscribtion), userInfo: nil, repeats: true)
    }

    @objc
    func finishTimer() {
        self.timer?.invalidate()
    }

    @objc
    func updateSubscribtion() {
        guard let timerFinishSubscribtion = UserDefaultsManager.shared.timerFinishSubscribtion else {
            self.currentPlanView.isHidden = true
            self.choosePlanView.isHidden = false
            self.timer?.invalidate()

//            self.receiptValidation()
            return
        }

        let secLeft =  Int(timerFinishSubscribtion - Date().timeIntervalSince1970)
        guard secLeft > 0 else {
            self.currentPlanView.isHidden = true
            UserDefaultsManager.shared.timerFinishSubscribtion = nil
            self.choosePlanView.isHidden = false
            return
        }

        let secondsLeft: Int = secLeft % 3600 % 60
        let minutesLeft: Int = (secLeft % 3600) / 60
        let hoursLeft: Int = (secLeft % 86400) / 3600
        let daysLeft: Int = secLeft / 86400

        DispatchQueue.main.async {
            self.secondsLeftLabel.text =  String(format: "%02d", secondsLeft)
            self.minutesLeftLabel.text =  String(format: "%02d", minutesLeft)
            self.hoursLeftLabel.text =  String(format: "%02d", hoursLeft)
            self.daysLeftLabel.text =  String(format: "%02d", daysLeft)

            if self.currentPlanView.isHidden {
                self.currentPlanView.isHidden = false
//                self.choosePlanView.isHidden = true
            }
        }

        if !(self.timer?.isValid ?? false) {
            self.startTimer()
        }
    }

    func configureUI() {
        self.buyBackgroundView.setBlueGradient()
        self.buyButton.titleLabel?.font = .montserratSemiBold(size: 16)
        self.buyButton.setTitle("Buy", for: .normal)

        self.buyButton.alpha = 0.5

        self.currentPlanView.isHidden = true
        self.updateSubscribtion()

        self.leftBackgroundView.layer.cornerRadius = 16
        self.leftBackgroundView.clipsToBounds = true

        self.promocodeTextField.setPlaceholder(text: "Promo code")

        self.tarifTableView.register(UINib(nibName: "TarifTableViewCell", bundle: nil), forCellReuseIdentifier: TarifTableViewCell.className)
        self.tarifTableView.showsVerticalScrollIndicator = false
        self.tarifTableView.showsHorizontalScrollIndicator = false
        self.tarifTableView.isScrollEnabled = false
        self.tarifTableView.separatorStyle = .none
        self.tarifTableView.allowsMultipleSelectionDuringEditing = false
        self.tarifTableView.delegate = self
        self.tarifTableView.dataSource = self

        let text1 = "The tariff is purchased once. For additional information contact us from settings."
        let textLinkPrivacy = "Privacy Policy"
        let textLinkTerms = "Terms of service"
        let totalText = "\(text1) \(textLinkPrivacy) and \(textLinkTerms)."

        let attributedString = NSMutableAttributedString(string: totalText)

        let linkPrivacy = URL(string: "https://app.vpnhero.am/api/page/privacy")!
        let linkTerms = URL(string: "https://app.vpnhero.am/api/page/terms_of_service")!

        let startIndexPrivacy = totalText.range(of: textLinkPrivacy)?.lowerBound.utf16Offset(in: totalText) ?? 0
        let startIndexTerms =  totalText.range(of: textLinkTerms)?.lowerBound.utf16Offset(in: totalText) ?? 0

        attributedString.setAttributes([.foregroundColor: UIColor.white.withAlphaComponent(0.5), .font: UIFont.montserratRegular(size: 12)], range: NSMakeRange(0, totalText.count))
        attributedString.setAttributes([.link: linkPrivacy, .font: UIFont.montserratMedium(size: 12)], range: NSMakeRange(startIndexPrivacy, textLinkPrivacy.count))
        attributedString.setAttributes([.link: linkTerms, .font: UIFont.montserratMedium(size: 12)], range: NSMakeRange(startIndexTerms, textLinkTerms.count))

        self.linksTextView.attributedText = attributedString
        self.linksTextView.isUserInteractionEnabled = true
        self.linksTextView.isEditable = false
        self.linksTextView.isScrollEnabled = false
        self.linksTextView.delegate = self

        self.linksTextView.textContainerInset = .zero;
        self.linksTextView.textContainer.lineFragmentPadding = 0;

        self.linksTextView.linkTextAttributes = [
            .foregroundColor: UIColor.white,
            .underlineStyle: NSUnderlineStyle.single.rawValue
        ]
    }

//    func fetchAvailableProducts() {
//        let productIdentifiers = Set(self.tarifs.map({ $0.uniqId }))
//        let productRequest = SKProductsRequest(productIdentifiers: productIdentifiers)
//        productRequest.delegate = self
//        productRequest.start()
//    }

    @objc
    func subscribeButtonTouch() {
        guard self.selectedIndex > -1 else {
            self.showAlert("Should choose plan")
            return
        }

        self.requestForPay()

        /*
        guard let product = self.productsArray.first(where: { $0.productIdentifier == self.tarifs[self.selectedIndex].uniqId }) else {
            self.showAlert("Product not found")
            return
        }
         */




        /*
        if SKPaymentQueue.canMakePayments() {
            let payment = SKPayment(product: product)
            SKPaymentQueue.default().add(payment)
        } else {
            self.showAlert("Purchases are disabled on your device")
        }
         */
    }

    @objc
    func subsctibeForFreeButtonTouch() {
        guard let promocode = promocodeTextField.text else {
            self.showAlert("need input promocode")
            return
        }

        ProgressHUD.animate()
        AppService().promocode(code: promocode) { result in
            ProgressHUD.dismiss()
            switch result {
            case .success(_):
                self.promocodeTextField.text = nil

                SubscribtionManager.shared.getStatus()
            case .failure(let error):
                self.showAlert(error.textError)
            }
        }
    }

    func subscribeByApple(transactionId: String, uniqId: String, transactionPrice: Float, transactionDate: Double) {
        print("subscribe by apple \n transactionId: \(transactionId) \n uniqId: \(uniqId) \n cost: \(transactionPrice) \n created: \(transactionDate)")

        self.transactionId = transactionId

        guard let vc = Utils.shared.mainStoryboard().instantiateViewController(withIdentifier: ProcessVC.className) as? ProcessVC else { return }
        vc.type = .processPayment
        vc.planString = self.tarifs[self.selectedIndex].nameEn
        vc.delegate = self
        self.present(vc, animated: true)

        self.processVC = vc

        AppService().subsribe(transactionId: transactionId, uniqId: uniqId, cost: transactionPrice, created: transactionDate) { [weak self] (result) in
            guard let self = self else { return }
            switch result {
            case .success(let state):
                if state {
                    self.checkStatusTimer = Timer.scheduledTimer(timeInterval: 3, target: self, selector: #selector(self.getStatusTransaction), userInfo: nil, repeats: true)
                    self.dateStartTimer = Date().timeIntervalSince1970
                } else {
                    vc.changeStatus(type: .errorPayment)
                }
            case .failure(let error):
                vc.changeStatus(type: .errorPayment)
                print(error.textError)
            }
        }
    }

    @objc
    func getStatusTransaction() {
        guard UserDefaultsManager.shared.timerFinishSubscribtion == nil else {
            self.processVC?.changeStatus(type: .successPayment)
            self.updateSubscribtion()
            self.dateStartTimer = nil
            self.checkStatusTimer?.invalidate()
            return
        }

        guard let dateStartTimer = self.dateStartTimer, Date().timeIntervalSince1970 - dateStartTimer < 60 else {
            self.dateStartTimer = nil
            self.checkStatusTimer?.invalidate()
            return
        }

        SubscribtionManager.shared.getStatus()
    }

    func requestTarrifs(withShowingProgress: Bool = true) {
        if withShowingProgress {
            ProgressHUD.animate()
        }
        AppService().getTarifs(complition: { [weak self] (result) in
            ProgressHUD.dismiss()
            guard let self = self else { return }
            switch result {
            case .success(let tarifs):
                UserDefaultsManager.shared.tarifs = tarifs
                self.tarifs = tarifs
                self.heightTarifTableViewConstraint.constant = CGFloat(76 * tarifs.count)
                self.tarifTableView.reloadData()

//                self.fetchAvailableProducts()
            case .failure(let error):
                self.showAlert(error.textError)
            }
        })
    }

    /*
    func complete(transaction: SKPaymentTransaction) {
        UserDefaults.standard.set(true, forKey: "isPaidUser")

        print("Purchase Success requestData: \(transaction.transactionState)")
        let successStates: [SKPaymentTransactionState] = [.purchased, .restored]
        if successStates.contains(transaction.transactionState) {

            if let transactionIdentifier = transaction.transactionIdentifier, let product = self.productsArray.first(where: { $0.productIdentifier ==  transaction.payment.productIdentifier }) {
                self.subscribeByApple(transactionId: transactionIdentifier, uniqId: transaction.payment.productIdentifier, transactionPrice: Float(product.price), transactionDate: transaction.transactionDate?.timeIntervalSince1970 ?? Date().timeIntervalSince1970)
            }
        }

        SKPaymentQueue.default().finishTransaction(transaction)
    }

    func failed(transaction: SKPaymentTransaction) {
        UserDefaults.standard.set(false, forKey: "isPaidUser")
        if let error = transaction.error as? SKError {
            switch error.code {
            case .unknown:
                self.showAlert("Unknown error. Please contact support")
            case .clientInvalid:
                self.showAlert("Not allowed to make the payment")
            case .paymentCancelled:
                break
            case .paymentInvalid:
                self.showAlert("The purchase identifier was invalid")
            case .paymentNotAllowed:
                self.showAlert("The device is not allowed to make the payment")
            case .storeProductNotAvailable:
                self.showAlert("The product is not available in the current storefront")
            case .cloudServicePermissionDenied:
                self.showAlert("Access to cloud service information is not allowed")
            case .cloudServiceNetworkConnectionFailed:
                self.showAlert("Could not connect to the network")
            case .cloudServiceRevoked:
                self.showAlert("User has revoked permission to use this cloud service")
            default:
                self.showAlert(error.localizedDescription)
            }
        }
        SKPaymentQueue.default().finishTransaction(transaction)
    }
    */

    /*
    func receiptValidation() {
        let verifyReceiptURL = self.isSandbox ?  "https://sandbox.itunes.apple.com/verifyReceipt" : "https://buy.itunes.apple.com/verifyReceipt"
        guard let receiptFileURL = Bundle.main.appStoreReceiptURL else {
            print("Error get appStoreReceiptURL")
            return
        }
        guard let receiptData = try? Data(contentsOf: receiptFileURL) else { print("No receipt found")
            return
        }
        let recieptString = receiptData.base64EncodedString(options: NSData.Base64EncodingOptions(rawValue: 0))
//        print("recieptString: \(recieptString)")

        let jsonDict: [String: AnyObject] = ["receipt-data": recieptString as AnyObject,
                                             "password": "password" as AnyObject]

//        do {
//            let requestData = try JSONSerialization.data(withJSONObject: jsonDict, options: JSONSerialization.WritingOptions.prettyPrinted)
//            let storeURL = URL(string: verifyReceiptURL)!
//            var storeRequest = URLRequest(url: storeURL)
//            storeRequest.httpMethod = "POST"
//            storeRequest.httpBody = requestData
//            let session = URLSession(configuration: URLSessionConfiguration.default)
//            let task = session.dataTask(with: storeRequest, completionHandler: { [weak self] (data, response, error) in
//                guard let self = self else { return }
//                do {
//                    if let jsonResponse = try JSONSerialization.jsonObject(with: data!, options: JSONSerialization.ReadingOptions.mutableContainers) as? NSDictionary{
//                        print("Response :",jsonResponse)
//
//                        if let date = self.getExpirationDateFromResponse(jsonResponse) {
//                            print("Expired at: \(date)")
//
//                            var addingValue = 0
//                            var addingComponent: Calendar.Component = .month
//                            if let firstProduct = self.productsArray.first(where: { $0.productIdentifier == self.transactionIdentifier ?? "" }) {
//                                addingValue = firstProduct.subscriptionPeriod?.numberOfUnits ?? 0
//                                switch firstProduct.subscriptionPeriod?.unit {
//                                case .day: addingComponent = .day
//                                case .week:
//                                    addingValue = 7 * addingValue
//                                    addingComponent = .day
//                                case .month:
//                                    addingComponent = .month
//                                case .year:
//                                    addingComponent = .year
//                                default: break
//                                }
//                            }
//                            self.transactionDate = date.adding(addingComponent, value: -addingValue).timeIntervalSince1970
//                        }
//
//                        if self.isSandbox {
//                            self.transactionDate = Date().timeIntervalSince1970
//                        }
//                        self.subscribeByApple()
//                    }
//                } catch let parseError {
//                    print(parseError)
//                }
//            })
//            task.resume()
//        } catch let parseError {
//            print(parseError)
//        }
    }

    func getExpirationDateFromResponse(_ jsonResponse: NSDictionary) -> Date? {
//        print(jsonResponse)
        guard let receiptInfo: NSArray = jsonResponse["latest_receipt_info"] as? NSArray, let lastReceipt = receiptInfo.lastObject as? NSDictionary else { return nil }

        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss VV"

        guard let expiresDate = lastReceipt["expires_date"] as? String else { return nil }

        return formatter.date(from: expiresDate)
    }
*/

    func sendPushToken() {
        let fcmToken = UserDefaultsManager.shared.curentPushToken
        guard !fcmToken.isEmpty else { return }

        AppService().pushToken(pushToken: fcmToken) { result in
            switch result {
            case .success(let state):
                print("success sending fcm token")
            case .failure(let textError):
                print(textError)
            }
        }
    }

    func requestForPay() {
        self.amount = self.tarifs[self.selectedIndex].priceDiscount ?? self.tarifs[self.selectedIndex].price
        self.uniqId = self.tarifs[self.selectedIndex].uniqId

        guard self.amount > 0 else {
            self.showAlert("Error configure pay request")
            return
        }

        let request = PKPaymentRequest()
        request.merchantIdentifier = "merchant.am.vpnhero.app"
        request.supportedCountries = ["US"]
        request.countryCode = "US"
        request.currencyCode = "USD"

        let paymentNetworks = [PKPaymentNetwork.visa, .masterCard, .discover]
        request.supportedNetworks = paymentNetworks
        request.merchantCapabilities = .capability3DS

//        let item = PKPaymentSummaryItem(label: "VPN plan for \(self.tarifs[self.selectedIndex].nameEn)", amount: NSDecimalNumber(string: "\(self.amount)"))
        let item = PKPaymentSummaryItem(label: "VPN plan for \(self.tarifs[self.selectedIndex].nameEn)", amount: NSDecimalNumber(string: "\(0.5)"))
        request.paymentSummaryItems = [item]

        self.paymentRequest = request

        if let applePayVC = PKPaymentAuthorizationViewController(paymentRequest: request) {
            applePayVC.delegate = self
            self.present(applePayVC, animated: true, completion: nil)
        }

//        if PKPaymentAuthorizationViewController.canMakePayments(usingNetworks: paymentNetworks) {
//            request.supportedNetworks = paymentNetworks
//            request.merchantCapabilities = .capability3DS
//
//            let item = PKPaymentSummaryItem(label: "VPN plan for \(self.tarifs[self.selectedIndex].nameEn)", amount: NSDecimalNumber(string: "\(self.amount)"))
//            request.paymentSummaryItems = [item]
//
//            self.paymentRequest = request
//
//            if let applePayVC = PKPaymentAuthorizationViewController(paymentRequest: request) {
//                applePayVC.delegate = self
//                self.present(applePayVC, animated: true, completion: nil)
//            }
//        } else {
//            self.showAlert("Apple Pay is not available on this device")
//        }
    }


}
//extension SubsVC: SKPaymentTransactionObserver {
//    func paymentQueue(_ queue: SKPaymentQueue, updatedTransactions transactions: [SKPaymentTransaction]) {
//        ProgressHUD.dismiss()
//        if let lastTransaction = transactions.sorted(by: { ($0.transactionDate?.timeIntervalSince1970 ?? 0) > ($1.transactionDate?.timeIntervalSince1970 ?? 0) }).first(where: { $0.transactionState == .purchased || $0.transactionState == .restored }) {
//            complete(transaction: lastTransaction)
//        }
//    }
//}
//extension SubsVC: SKProductsRequestDelegate {
//    func productsRequest(_ request: SKProductsRequest, didReceive response: SKProductsResponse) {
//        if !response.products.isEmpty {
//            productsArray = response.products
//        }
//    }
//}
//extension SubsVC: PKPaymentAuthorizationViewControllerDelegate {
//    func paymentAuthorizationViewControllerDidFinish(_ controller: PKPaymentAuthorizationViewController) {
//        controller.dismiss(animated: true)
//    }
//
//    func paymentAuthorizationViewController(_ controller: PKPaymentAuthorizationViewController, didAuthorizePayment payment: PKPayment, handler completion: @escaping (PKPaymentAuthorizationResult) -> Void) {
//        completion(PKPaymentAuthorizationResult(status: .success, errors: nil))
//    }
//}
extension SubsVC: ProcessVCDelegate {
    func mainActionTouched(vc: UIViewController, type: ProcessType) {
        vc.dismiss(animated: true)
        self.processVC = nil
        if type == .successPayment {
            SubscribtionManager.shared.getStatus()
        }
    }
}
extension SubsVC: UITextViewDelegate {
    func textView(_ textView: UITextView, shouldInteractWith URL: URL, in characterRange: NSRange, interaction: UITextItemInteraction) -> Bool {

        if URL.absoluteString.contains("privacy") {
            if let vc = Utils.shared.mainStoryboard().instantiateViewController(withIdentifier: InfoVC.className) as? InfoVC {
                vc.type = .privacy
                self.present(vc, animated: true)
            }
            return false
        } else if URL.absoluteString.contains("terms_of_service") {
            if let vc = Utils.shared.mainStoryboard().instantiateViewController(withIdentifier: InfoVC.className) as? InfoVC {
                vc.type = .terms
                self.present(vc, animated: true)
            }
            return false
        }

        return true
    }
}
extension SubsVC: PKPaymentAuthorizationViewControllerDelegate {
    func paymentAuthorizationViewControllerDidFinish(_ controller: PKPaymentAuthorizationViewController) {
        self.dismiss(animated: true, completion: nil)
    }

    func paymentAuthorizationViewController(_ controller: PKPaymentAuthorizationViewController, didAuthorizePayment payment: PKPayment, completion: @escaping (PKPaymentAuthorizationStatus) -> Void) {

        print(payment.token)
        // Get response from the server and set the PKPaymentAuthorizationStatus
        let status = PKPaymentAuthorizationStatus(rawValue: 0)!

        self.transactionId = payment.token.transactionIdentifier

        switch status.rawValue {
        case 0:
            self.successPayment = true

            self.subscribeByApple(transactionId: self.transactionId, uniqId: self.uniqId, transactionPrice: self.amount, transactionDate: Date().timeIntervalSince1970)

            // perform Functionality on Apple Pay Successfull Payment
        default:
            self.successPayment = false

        }
    }
}
