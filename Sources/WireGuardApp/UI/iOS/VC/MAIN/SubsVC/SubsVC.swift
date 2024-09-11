// SPDX-License-Identifier: MIT
// Copyright © 2018-2023 WireGuard LLC. All Rights Reserved.

import UIKit
import ProgressHUD
import PassKit
import StoreKit

class Product {
    let id: String
    let title: String
    let cost: Decimal
    let discountCost: Decimal
    let monthCount: Int

//    var discountPercent: Int {
//        return 100 - Int(discountCost / cost)
//    }

    var costValue: String {
        return "$\(String(format: "%.2f%", (cost as NSDecimalNumber).floatValue))"
    }

    var discountCostValue: String {
        return "$\(String(format: "%.2f%", (discountCost as NSDecimalNumber).floatValue))"
    }

    init(id: String, title: String, cost: Decimal, discountCost: Decimal, monthCount: Int) {
        self.id = id
        self.title = title
        self.cost = cost
        self.discountCost = discountCost
        self.monthCount = monthCount
    }
}

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
    private let isSandbox = true
#else
    private let isSandbox = false
#endif

    private var products: [Product] = []
    private var paymentRequest: PKPaymentRequest?

    private var productsArray: [SKProduct] = []

    override func viewDidLoad() {
        super.viewDidLoad()

        self.products = [Product(id: "1Month", title: "1 Month", cost: 7.99, discountCost: 4.99, monthCount: 1),
                        Product(id: "3Month", title: "3 Month", cost: 14.99, discountCost: 13.99, monthCount: 3),
                        Product(id: "6Months", title: "6 Month", cost: 29.99, discountCost: 23.99, monthCount: 6),
                        Product(id: "1Year", title: "1 Year", cost: 59.99, discountCost: 41.99, monthCount: 12)]
        SKPaymentQueue.default().add(self)

        self.setTargets()
        self.configureUI()

        self.fetchAvailableProducts()
        self.receiptValidation()
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
        self.oneMonthMainPriceLabel.attributedText = "\(self.products[0].costValue)".strikeAttributedString
        self.threeMonthMainPriceLabel.attributedText = "\(self.products[1].costValue)".strikeAttributedString
        self.halfYearMainPriceLabel.attributedText = "\(self.products[2].costValue)".strikeAttributedString
        self.yearMainPriceLabel.attributedText = "\(self.products[3].costValue)".strikeAttributedString


        self.oneMonthCurrentPriceLabel.text = "\(self.products[0].discountCostValue)"
        self.threeMonthCurrentPriceLabel.text = "\(self.products[1].discountCostValue)"
        self.halfYearCurrentPriceLabel.text = "\(self.products[2].discountCostValue)"
        self.yearCurrentPriceLabel.text = "\(self.products[3].discountCostValue)"

    }

    func fetchAvailableProducts() {
        let productIdentifiers = Set(self.products.map({ $0.id }))
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
        guard self.selectedIndex > -1 else { return }
        let product = products[self.selectedIndex]

        guard let product = self.productsArray.first(where: { $0.productIdentifier == self.products[self.selectedIndex].id }) else {
            self.showAlert("Product not found")
            return
        }

        if SKPaymentQueue.canMakePayments() {
            ProgressHUD.animate()
            let payment = SKPayment(product: product)
            SKPaymentQueue.default().add(payment)
        } else {
            self.showAlert("Purchases are disabled on your device")
        }
    }

    @objc
    func subsctibeForFreeButtonTouch() {
        guard let promocode = promocodeTextField.text else {
            self.showAlert("need input promocode")
            return
        }

    }

    func complete(transaction: SKPaymentTransaction) {
        UserDefaults.standard.set(true, forKey: "isPaidUser")

        print("Purchase Success requestData: \(transaction.payment.quantity)")
        print("Purchase Success requestData: \(transaction.transactionState)")

        self.showAlert("Purchase Success: \(transaction.payment.productIdentifier)")
        SKPaymentQueue.default().finishTransaction(transaction)

        self.receiptValidation()
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
        let jsonDict: [String: AnyObject] = ["receipt-data" : recieptString as AnyObject, "password" : "password" as AnyObject]

        do {
            let requestData = try JSONSerialization.data(withJSONObject: jsonDict, options: JSONSerialization.WritingOptions.prettyPrinted)
            let storeURL = URL(string: verifyReceiptURL)!
            var storeRequest = URLRequest(url: storeURL)
            storeRequest.httpMethod = "POST"
            storeRequest.httpBody = requestData
            let session = URLSession(configuration: URLSessionConfiguration.default)
            let task = session.dataTask(with: storeRequest, completionHandler: { [weak self] (data, response, error) in

                do {
                    if let jsonResponse = try JSONSerialization.jsonObject(with: data!, options: JSONSerialization.ReadingOptions.mutableContainers) as? NSDictionary{
                        print("Response :",jsonResponse)
                        if let date = self?.getExpirationDateFromResponse(jsonResponse) {
                            print(date)
                        }
                    }
                } catch let parseError {
                    print(parseError)
                }
            })
            task.resume()
        } catch let parseError {
            print(parseError)
        }
    }

    func getExpirationDateFromResponse(_ jsonResponse: NSDictionary) -> Date? {
//        print(jsonResponse)
        guard let receiptInfo: NSArray = jsonResponse["latest_receipt_info"] as? NSArray, let lastReceipt = receiptInfo.lastObject as? NSDictionary else { return nil }

        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss VV"

        guard let expiresDate = lastReceipt["expires_date"] as? String else { return nil }

        return formatter.date(from: expiresDate)
    }



    func requestForPay() {
        let request = PKPaymentRequest()
        request.merchantIdentifier = "merchant.am.vpnhero.app"
        request.supportedNetworks = [.visa, .masterCard]
        request.supportedCountries = ["RU"]
        request.merchantCapabilities = .capability3DS
        request.countryCode = "RU"
        request.currencyCode = "RUB"
        request.paymentSummaryItems = [PKPaymentSummaryItem(label: self.products[self.selectedIndex].title, amount: NSDecimalNumber(decimal: self.products[self.selectedIndex].discountCost))]
        self.paymentRequest = request

        guard let controller = PKPaymentAuthorizationViewController(paymentRequest: request) else { return }
        controller.delegate = self
        present(controller, animated: true, completion: nil)
    }

}
extension SubsVC: SKPaymentTransactionObserver {
    func paymentQueue(_ queue: SKPaymentQueue, updatedTransactions transactions: [SKPaymentTransaction]) {
        ProgressHUD.dismiss()
        for transaction in transactions {
            switch transaction.transactionState {
            case .purchased:
                complete(transaction: transaction)
            case .failed:
                failed(transaction: transaction)
            case .restored:
                complete(transaction: transaction)
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
            productsArray.forEach { prod in
                var text = "________"
                text += "prod.productIdentifier: \(prod.productIdentifier) \n"
                text += "prod.localizedDescription: \(prod.localizedDescription) \n"
                text += "prod.localizedTitle: \(prod.localizedTitle) \n"
                text += "prod.discounts: \(prod.discounts) \n"
                text += "prod.price: \(prod.price) \n"
                text += "prod.priceLocale: \(prod.priceLocale) \n"
                text += "prod.subscriptionPeriod: \(prod.subscriptionPeriod) \n"
                print(text)
            }
        }
    }
}
extension SubsVC: PKPaymentAuthorizationViewControllerDelegate {
    func paymentAuthorizationViewControllerDidFinish(_ controller: PKPaymentAuthorizationViewController) {
        controller.dismiss(animated: true)
    }

    func paymentAuthorizationViewController(_ controller: PKPaymentAuthorizationViewController, didAuthorizePayment payment: PKPayment, handler completion: @escaping (PKPaymentAuthorizationResult) -> Void) {
        completion(PKPaymentAuthorizationResult(status: .success, errors: nil))
    }
}
