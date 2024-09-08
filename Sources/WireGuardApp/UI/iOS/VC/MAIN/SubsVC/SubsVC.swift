// SPDX-License-Identifier: MIT
// Copyright © 2018-2023 WireGuard LLC. All Rights Reserved.

import UIKit
import StoreKit
import ProgressHUD

class SubsVC: UIViewController {

    @IBOutlet weak var oneMonthButton: UIButton!
    @IBOutlet weak var oneMonthCircleButton: UIButton!
    @IBOutlet weak var oneMonthMainPriceLabel: UILabel!
    @IBOutlet weak var oneMonthCurrentPriceLabel: UILabel!

    @IBOutlet weak var threeMonthButton: UIButton!
    @IBOutlet weak var threeMonthCircleButton: UIButton!
    @IBOutlet weak var threeMonthMainPriceLabel: UILabel!
    @IBOutlet weak var threeMonthCurrentPriceLabel: UILabel!

    @IBOutlet weak var halfYearButton: UIButton!
    @IBOutlet weak var halfYearCircleButton: UIButton!
    @IBOutlet weak var halfYearMainPriceLabel: UILabel!
    @IBOutlet weak var halfYearCurrentPriceLabel: UILabel!

    @IBOutlet weak var yearButton: UIButton!
    @IBOutlet weak var yearCircleButton: UIButton!
    @IBOutlet weak var yearMainPriceLabel: UILabel!
    @IBOutlet weak var yearCurrentPriceLabel: UILabel!

    @IBOutlet weak var subscribeButton: UIButton!

    @IBOutlet weak var promocodeTextField: HeroTextField!
    @IBOutlet weak var subscribeForFreeButton: UIButton!

    private var productIDs: [String] = ["1Month", "3Month", "6Months", "1Year"]
    private var productsArray: [SKProduct] = []
    private var selectedIndex = -1 {
        didSet {
            let checkedImage = UIImage(named: "check")
            let uncheckedImage = UIImage(named: "uncheck")
            switch oldValue {
            case 0: self.oneMonthCircleButton.setImage(uncheckedImage, for: .normal)
            case 1: self.threeMonthCircleButton.setImage(uncheckedImage, for: .normal)
            case 2: self.halfYearCircleButton.setImage(uncheckedImage, for: .normal)
            case 3: self.yearCircleButton.setImage(uncheckedImage, for: .normal)
            default: break
            }

            switch selectedIndex {
            case 0: self.oneMonthCircleButton.setImage(checkedImage, for: .normal)
            case 1: self.threeMonthCircleButton.setImage(checkedImage, for: .normal)
            case 2: self.halfYearCircleButton.setImage(checkedImage, for: .normal)
            case 3: self.yearCircleButton.setImage(checkedImage, for: .normal)
            default: break
            }
        }
    }

#if DEBUG
    let isSandbox = true
#else
    let isSandbox = false
#endif

    override func viewDidLoad() {
        super.viewDidLoad()

        self.setTargets()
        self.configureUI()

        SKPaymentQueue.default().add(self)
        self.fetchAvailableProducts()
//        self.validateReceipt()
    }

    deinit {
        SKPaymentQueue.default().remove(self)
    }
}
private extension SubsVC {
    func setTargets() {
        self.oneMonthCircleButton.addTarget(self, action: #selector(circleButtonTouch(_:)), for: .touchUpInside)
        self.threeMonthCircleButton.addTarget(self, action: #selector(circleButtonTouch(_:)), for: .touchUpInside)
        self.halfYearCircleButton.addTarget(self, action: #selector(circleButtonTouch(_:)), for: .touchUpInside)
        self.yearCircleButton.addTarget(self, action: #selector(circleButtonTouch(_:)), for: .touchUpInside)

        self.oneMonthButton.addTarget(self, action: #selector(subscribesButtonTouch(_:)), for: .touchUpInside)
        self.threeMonthButton.addTarget(self, action: #selector(subscribesButtonTouch(_:)), for: .touchUpInside)
        self.halfYearButton.addTarget(self, action: #selector(subscribesButtonTouch(_:)), for: .touchUpInside)
        self.yearButton.addTarget(self, action: #selector(subscribesButtonTouch(_:)), for: .touchUpInside)

        self.subscribeButton.addTarget(self, action: #selector(subscribeButtonTouch), for: .touchUpInside)

        self.subscribeForFreeButton.addTarget(self, action: #selector(subsctibeForFreeButtonTouch), for: .touchUpInside)
    }

    func configureUI() {
        self.oneMonthMainPriceLabel.attributedText = "$7.99".strikeAttributedString
        self.threeMonthMainPriceLabel.attributedText = "$14.99".strikeAttributedString
        self.halfYearMainPriceLabel.attributedText = "$29.99".strikeAttributedString
        self.yearMainPriceLabel.attributedText = "$59.99".strikeAttributedString

    }

    func fetchAvailableProducts() {
        let productIdentifiers = Set(productIDs)
        let productRequest = SKProductsRequest(productIdentifiers: productIdentifiers)
        productRequest.delegate = self
        productRequest.start()
    }

    @objc
    func circleButtonTouch(_ sender: UIButton) {
        self.selectedIndex = switch sender {
        case self.oneMonthCircleButton: 0
        case self.threeMonthCircleButton: 1
        case self.halfYearCircleButton: 2
        case self.yearCircleButton: 3
        default: -1
        }
    }

    @objc
    func subscribesButtonTouch(_ sender: UIButton) {
        self.selectedIndex = switch sender {
        case self.oneMonthButton: 0
        case self.threeMonthButton: 1
        case self.halfYearButton: 2
        case self.yearButton: 3
        default: -1
        }
        self.subscribeButtonTouch()
    }

    @objc
    func subscribeButtonTouch() {
        guard self.selectedIndex > 0 else { return }
        self.buyPlan(id: self.productIDs[self.selectedIndex])
    }

    @objc
    func subsctibeForFreeButtonTouch() {
        guard let promocode = promocodeTextField.text else {
            self.showAlert("need input promocode")
            return
        }

    }

    func buyPlan(id: String) {
        guard let product = productsArray.first(where: { $0.productIdentifier == id }) else {
            self.showAlert("Product not found")
            return
        }
        if SKPaymentQueue.canMakePayments() {
            ProgressHUD.animationType = .circleArcDotSpin
            ProgressHUD.animate()
            let payment = SKPayment(product: product)
            SKPaymentQueue.default().add(payment)
        } else {
            self.showAlert("Purchases are disabled on your device")
        }
    }



    func complete(transaction: SKPaymentTransaction) {
        ProgressHUD.animationType = .circleArcDotSpin
        ProgressHUD.animate()

        ProgressHUD.dismiss()

        UserDefaults.standard.set(true, forKey: "isPaidUser")
        self.showAlert("Purchase Success: \(transaction.payment.productIdentifier)")
        SKPaymentQueue.default().finishTransaction(transaction)
    }

    func failed(transaction: SKPaymentTransaction) {
        ProgressHUD.dismiss()
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

    func restore(transaction: SKPaymentTransaction) {
        ProgressHUD.dismiss()
        UserDefaults.standard.set(true, forKey: "isPaidUser")
        self.showAlert("Purchase Restored: \(transaction.payment.productIdentifier)")
        SKPaymentQueue.default().finishTransaction(transaction)
    }

    func fetchReceipt() -> Data? {
        guard let receiptURL = Bundle.main.appStoreReceiptURL else { return nil }
        return try? Data(contentsOf: receiptURL)
    }
    func validateReceipt() {
        guard let receiptData = fetchReceipt() else {
            self.showAlert("No receipt found")
            return
        }

        let receiptString = receiptData.base64EncodedString(options: [])

        let requestContents: [String: Any] = ["receipt-data": receiptString,
                                              "password": "Y18e81535cb534b31b2dbe3f24f235bc7"]

        guard let requestData = try? JSONSerialization.data(withJSONObject: requestContents, options: []) else { return }

        let sandboxUrlString = "https://sandbox.itunes.apple.com/verifyReceipt"
        let productionUrlString = "https://buy.itunes.apple.com/verifyReceipt"

        let urlString = isSandbox ? sandboxUrlString : productionUrlString
        guard let url = URL(string: urlString) else { return }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.cachePolicy = .reloadIgnoringCacheData
        request.httpBody = requestData

        let session = URLSession.shared
        let task = session.dataTask(with: request) { data, response, error in
            guard error == nil else {
                self.showAlert("Error in receipt validation: \(error!.localizedDescription)")
                return
            }

            guard let data = data else {
                self.showAlert("No data in receipt validation response")
                return
            }

            do {
                if let jsonResponse = try JSONSerialization.jsonObject(with: data, options: .mutableContainers) as? [String: Any] {
                    self.handleReceiptValidationResponse(jsonResponse)
                }
            } catch {
                self.showAlert("Error in receipt validation: \(error.localizedDescription)")
            }
        }
        task.resume()
    }
    func handleReceiptValidationResponse(_ response: [String: Any]) {
        guard let status = response["status"] as? Int else { return }

        if status == 0 {
            // The receipt is valid
            guard let receipt = response["receipt"] as? [String: Any],
                  let inApp = receipt["in_app"] as? [[String: Any]] else { return }

            let currentDate = Date()
            var isSubscribed = false

            for purchase in inApp {
                if let expiresDateString = purchase["expires_date"] as? String,
                   let expiresDate = ISO8601DateFormatter().date(from: expiresDateString) {
                    if expiresDate > currentDate {
                        isSubscribed = true
                        break
                    }
                }
            }

            DispatchQueue.main.async {
                UserDefaults.standard.set(isSubscribed, forKey: "isPaidUser")
                self.showAlert(isSubscribed ? "Subscription is active" : "Subscription has expired")
            }
        } else {
            // The receipt is not valid
            DispatchQueue.main.async {
                self.showAlert("Receipt validation failed with status: \(status)")
            }
        }
    }

}
extension SubsVC: SKPaymentTransactionObserver {
    func paymentQueue(_ queue: SKPaymentQueue, updatedTransactions transactions: [SKPaymentTransaction]) {
        for transaction in transactions {
            switch transaction.transactionState {
            case .purchased:
                complete(transaction: transaction)
            case .failed:
                failed(transaction: transaction)
            case .restored:
                restore(transaction: transaction)
            case .deferred, .purchasing:
                break
            @unknown default:
                break
            }
        }
    }
}
extension SubsVC: SKProductsRequestDelegate {
    func productsRequest(_ request: SKProductsRequest, didReceive response: SKProductsResponse) {
        if !response.products.isEmpty {
            productsArray = response.products
        }
    }
}
