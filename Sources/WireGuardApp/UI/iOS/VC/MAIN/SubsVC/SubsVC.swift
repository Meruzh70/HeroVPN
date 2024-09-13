// SPDX-License-Identifier: MIT
// Copyright © 2018-2023 WireGuard LLC. All Rights Reserved.

import UIKit
import ProgressHUD
import PassKit
import StoreKit

class SubsVC: UIViewController {

    @IBOutlet weak var currentPlanView: UIView!
    @IBOutlet weak var leftBackgroundView: UIView!
    @IBOutlet weak var daysLeftLabel: UILabel!
    @IBOutlet weak var hoursLeftLabel: UILabel!
    @IBOutlet weak var minutesLeftLabel: UILabel!
    @IBOutlet weak var secondsLeftLabel: UILabel!

    @IBOutlet weak var tarifTableView: UITableView!
    @IBOutlet weak var heightTarifTableViewConstraint: NSLayoutConstraint!

    @IBOutlet weak var subscribeButton: UIButton!

    @IBOutlet weak var promocodeTextField: HeroTextField!
    @IBOutlet weak var subscribeForFreeButton: UIButton!

    private var tarifs: [Tarif] = UserDefaultsManager.shared.tarifs

    private var selectedIndex = -1

#if DEBUG
    private let isSandbox = true
#else
    private let isSandbox = false
#endif

    private var paymentRequest: PKPaymentRequest?

    private var productsArray: [SKProduct] = []

    private var transactionId: String?
    private var transactionPrice: Float?
    private var transactionIdentifier: String?
    private var transactionDate: Double?

    private var timer: Timer?
    private var secLeft: Int = 0

    override func viewDidLoad() {
        super.viewDidLoad()

        SKPaymentQueue.default().add(self)

        self.setTargets()
        self.configureUI()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.requestTarrifs()
        self.requestStatus()
    }

    deinit {
        SKPaymentQueue.default().remove(self)
    }
}
extension SubsVC: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.selectedIndex = self.selectedIndex != indexPath.row ? indexPath.row : -1
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
        self.subscribeButton.addTarget(self, action: #selector(subscribeButtonTouch), for: .touchUpInside)
        self.subscribeForFreeButton.addTarget(self, action: #selector(subsctibeForFreeButtonTouch), for: .touchUpInside)
    }

    func configureUI() {
        self.currentPlanView.isHidden = true

        self.leftBackgroundView.layer.cornerRadius = 16
        self.leftBackgroundView.clipsToBounds = true

        self.tarifTableView.register(UINib(nibName: "TarifTableViewCell", bundle: nil), forCellReuseIdentifier: TarifTableViewCell.className)
        self.tarifTableView.showsVerticalScrollIndicator = false
        self.tarifTableView.showsHorizontalScrollIndicator = false
        self.tarifTableView.isScrollEnabled = false
        self.tarifTableView.separatorStyle = .none
        self.tarifTableView.allowsMultipleSelectionDuringEditing = false
        self.tarifTableView.delegate = self
        self.tarifTableView.dataSource = self
    }

    func fetchAvailableProducts() {
        let productIdentifiers = Set(self.tarifs.map({ $0.uniqId }))
        let productRequest = SKProductsRequest(productIdentifiers: productIdentifiers)
        productRequest.delegate = self
        productRequest.start()
    }

    @objc
    func subscribeButtonTouch() {
        guard self.selectedIndex > -1 else { return }

        guard let product = self.productsArray.first(where: { $0.productIdentifier == self.tarifs[self.selectedIndex].uniqId }) else {
            self.showAlert("Product not found")
            return
        }

        if SKPaymentQueue.canMakePayments() {
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

        ProgressHUD.animate()
        AppService().promocode(code: promocode) { result in
            ProgressHUD.dismiss()
            switch result {
            case .succsess(_):
                self.promocodeTextField.text = nil
                self.requestStatus()
            case .failure(let error):
                self.showAlert(error.textError)
            }
        }
    }

    func subscribeByApple() {
        guard let transactionId = self.transactionId else {
            print("transactionId is empty")
            return
        }

        guard let transactionIdentifier = self.transactionIdentifier else {
            print("transactionIdentifier is empty")
            return
        }

        guard let transactionPrice = self.transactionPrice else {
            print("transactionPrice is empty")
            return
        }

        guard let transactionDate = self.transactionDate else {
            print("transactionDate is empty")
            return
        }

        AppService().subsribe(transactionId: transactionId, uniqId: transactionIdentifier, cost: transactionPrice, created: transactionDate) { [weak self] (result) in
            guard let self = self else { return }
            switch result {
            case .succsess(let state):
                if state {
                    self.transactionId = nil
                    self.transactionIdentifier = nil
                    self.transactionPrice = nil
                    self.transactionDate = nil

                    self.requestStatus()
                } else {
                    print("error subscribe")
                }
            case .failure(let error):
                print(error.textError)
            }
        }
    }

    func requestTarrifs() {
        ProgressHUD.animate()
        AppService().getTarifs(complition: { [weak self] (result) in
            ProgressHUD.dismiss()
            guard let self = self else { return }
            switch result {
            case .succsess(let tarifs):
                UserDefaultsManager.shared.tarifs = tarifs
                self.tarifs = tarifs
                self.heightTarifTableViewConstraint.constant = CGFloat(76 * tarifs.count)
                self.tarifTableView.reloadData()

                self.fetchAvailableProducts()
            case .failure(let error):
                self.showAlert(error.textError)
            }
        })
    }

    func requestStatus() {
        AppService().getStatus(complition: { result in
            switch result {
            case .succsess(let statusEntity):
                if statusEntity.isSuccess {
                    self.secLeft = statusEntity.secLeft ?? 0

                    self.timer?.invalidate()
                    self.timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(self.updateTimer), userInfo: nil, repeats: true)
                } else {
                    self.receiptValidation()
                }
            case .failure(let error):
                self.showAlert(error.textError)
            }
        })
    }

    @objc
    func updateTimer() {
        self.secLeft -= 1

        guard self.secLeft > 0 else {
            self.timer?.invalidate()
            self.currentPlanView.isHidden = true
            return
        }

        let secondsLeft: Int = self.secLeft % 3600 % 60
        let minutesLeft: Int = (self.secLeft % 3600) / 60
        let hoursLeft: Int = (self.secLeft % 86400) / 3600
        let daysLeft: Int = self.secLeft / 86400

        self.secondsLeftLabel.text =  String(format: "%02d", secondsLeft)
        self.minutesLeftLabel.text =  String(format: "%02d", minutesLeft)
        self.hoursLeftLabel.text =  String(format: "%02d", hoursLeft)
        self.daysLeftLabel.text =  String(format: "%02d", daysLeft)

        if self.currentPlanView.isHidden {
            self.currentPlanView.isHidden = false
        }
    }

    func complete(transaction: SKPaymentTransaction) {
        UserDefaults.standard.set(true, forKey: "isPaidUser")

        print("Purchase Success requestData: \(transaction.transactionState)")
        let successStates: [SKPaymentTransactionState] = [.purchased, .restored]
        if successStates.contains(transaction.transactionState) {
            if let date = transaction.transactionDate {
                self.transactionDate = date.timeIntervalSince1970
            } else {
                self.transactionDate = Date().timeIntervalSince1970
            }
            self.transactionIdentifier = transaction.payment.productIdentifier
        }

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
        self.transactionId = recieptString
        let jsonDict: [String: AnyObject] = ["receipt-data": recieptString as AnyObject,
                                             "password": "password" as AnyObject]

        do {
            let requestData = try JSONSerialization.data(withJSONObject: jsonDict, options: JSONSerialization.WritingOptions.prettyPrinted)
            let storeURL = URL(string: verifyReceiptURL)!
            var storeRequest = URLRequest(url: storeURL)
            storeRequest.httpMethod = "POST"
            storeRequest.httpBody = requestData
            let session = URLSession(configuration: URLSessionConfiguration.default)
            let task = session.dataTask(with: storeRequest, completionHandler: { [weak self] (data, response, error) in
                guard let self = self else { return }
                do {
                    if let jsonResponse = try JSONSerialization.jsonObject(with: data!, options: JSONSerialization.ReadingOptions.mutableContainers) as? NSDictionary{
                        print("Response :",jsonResponse)

                        if let date = self.getExpirationDateFromResponse(jsonResponse) {
                            print("Expired at: \(date)")

                            var addingValue = 0
                            var addingComponent: Calendar.Component = .month
                            if let firstProduct = self.productsArray.first(where: { $0.productIdentifier == self.transactionIdentifier ?? "" }) {
                                addingValue = firstProduct.subscriptionPeriod?.numberOfUnits ?? 0
                                switch firstProduct.subscriptionPeriod?.unit {
                                case .day: addingComponent = .day
                                case .week:
                                    addingValue = 7 * addingValue
                                    addingComponent = .day
                                case .month:
                                    addingComponent = .month
                                case .year:
                                    addingComponent = .year
                                default: break
                                }
                            }
                            self.transactionDate = date.adding(addingComponent, value: -addingValue).timeIntervalSince1970
                        }

                        if self.isSandbox {
                            self.transactionDate = Date().timeIntervalSince1970
                        }
                        self.subscribeByApple()
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



//    func requestForPay() {
//        let request = PKPaymentRequest()
//        request.merchantIdentifier = "merchant.am.vpnhero.app"
//        request.supportedNetworks = [.visa, .masterCard]
//        request.supportedCountries = ["RU"]
//        request.merchantCapabilities = .capability3DS
//        request.countryCode = "RU"
//        request.currencyCode = "RUB"
//        request.paymentSummaryItems = [PKPaymentSummaryItem(label: self.products[self.selectedIndex].title, amount: NSDecimalNumber(decimal: self.products[self.selectedIndex].discountCost))]
//        self.paymentRequest = request
//
//        guard let controller = PKPaymentAuthorizationViewController(paymentRequest: request) else { return }
//        controller.delegate = self
//        present(controller, animated: true, completion: nil)
//    }

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
                self.transactionPrice = prod.price.floatValue
                self.transactionIdentifier = prod.productIdentifier
            }
            self.subscribeByApple()
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
