//
//  LoginController.swift
//  LMANotes
//
//  Created by Bareeth Rasik on 31/03/23.
//  Copyright © 2023 Learn Make Application. All rights reserved.
//

import Foundation
import FirebaseDatabase
import FirebaseAuth
import UIKit

class LoginController: UIViewController {
  weak var delegate: LoginDelegate?

  private var loginView: LoginView { view as! LoginView }

  private var email: String { loginView.emailTextField.text! }
  private var password: String { loginView.passwordTextField.text! }

  // Hides tab bar when view controller is presented
  override var hidesBottomBarWhenPushed: Bool { get { true } set {} }

  // MARK: - View Controller Lifecycle Methods

  override func loadView() {
    view = LoginView()
  }

  override func viewDidLoad() {
    super.viewDidLoad()
    configureNavigationBar()
    configureDelegatesAndHandlers()
  }

  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
      
    navigationController?.setTitleColor(.label)
  }

  override func viewWillDisappear(_ animated: Bool) {
    super.viewWillDisappear(animated)
    view.endEditing(true)
    navigationController?.setTitleColor(.systemOrange)
  }

  override func viewDidDisappear(_ animated: Bool) {
    super.viewDidDisappear(animated)
  }

  // Dismisses keyboard when view is tapped
  override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
    super.touchesBegan(touches, with: event)
    view.endEditing(true)
  }

  // MARK: - Firebase

  private func login(with email: String, password: String) {
    Auth.auth().signIn(withEmail: email, password: password) { result, error in
      guard error == nil else { return self.displayError(error) }
        self.loginDidOccur()
    }
  }
    
    func loginDidOccur() {
        if let viewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "NotesViewController") as? NotesViewController {
               if let navigator = navigationController {
                   navigator.pushViewController(viewController, animated: true)
               }
           }
    }

  private func createUser(email: String, password: String) {
    Auth.auth().createUser(withEmail: email, password: password) { authResult, error in
      guard error == nil else { return self.displayError(error) }
        self.loginDidOccur()
    }
  }

  // MARK: - Action Handlers

  @objc
  private func handleLogin() {
    login(with: email, password: password)
  }

  @objc
  private func handleCreateAccount() {
    createUser(email: email, password: password)
  }

  // MARK: - UI Configuration

  private func configureNavigationBar() {
    navigationItem.title = "Welcome"
    navigationItem.backBarButtonItem?.tintColor = .systemYellow
    navigationController?.navigationBar.prefersLargeTitles = true
  }

  private func configureDelegatesAndHandlers() {
    loginView.emailTextField.delegate = self
    loginView.passwordTextField.delegate = self
    loginView.loginButton.addTarget(self, action: #selector(handleLogin), for: .touchUpInside)
    loginView.createAccountButton.addTarget(
      self,
      action: #selector(handleCreateAccount),
      for: .touchUpInside
    )
  }

  override func viewWillTransition(to size: CGSize,
                                   with coordinator: UIViewControllerTransitionCoordinator) {
    super.viewWillTransition(to: size, with: coordinator)
    loginView.emailTopConstraint.constant = UIDevice.current.orientation.isLandscape ? 15 : 50
    loginView.passwordTopConstraint.constant = UIDevice.current.orientation.isLandscape ? 5 : 20
  }
    
}

// MARK: - UITextFieldDelegate

extension LoginController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if loginView.emailTextField.isFirstResponder, loginView.passwordTextField.text!.isEmpty {
            loginView.passwordTextField.becomeFirstResponder()
        } else {
            textField.resignFirstResponder()
        }
        return true
    }
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        print("textFieldShouldBeginEditing:")
        return true
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField){
        print("textFieldDidBeginEditing:")
    }
}
@available(iOS 13.0, *)
class LoginView: UIView {
  var emailTextField: UITextField! {
    didSet {
      emailTextField.textContentType = .emailAddress
    }
  }

  var passwordTextField: UITextField! {
    didSet {
      passwordTextField.textContentType = .password
    }
  }

  var emailTopConstraint: NSLayoutConstraint!
  var passwordTopConstraint: NSLayoutConstraint!

  lazy var loginButton: UIButton = {
    let button = UIButton()
    button.setTitle("Login", for: .normal)
    button.setTitleColor(.white, for: .normal)
    button.setTitleColor(.highlightedLabel, for: .highlighted)
    button.setBackgroundImage(UIColor.systemOrange.image, for: .normal)
    button.setBackgroundImage(UIColor.systemOrange.highlighted.image, for: .highlighted)
    button.clipsToBounds = true
    button.layer.cornerRadius = 14
    return button
  }()

  lazy var createAccountButton: UIButton = {
    let button = UIButton()
    button.setTitle("Create Account", for: .normal)
    button.setTitleColor(.secondaryLabel, for: .normal)
    button.setTitleColor(UIColor.secondaryLabel.highlighted, for: .highlighted)
    return button
  }()

  convenience init() {
    self.init(frame: .zero)
    setupSubviews()
  }

  // MARK: - Subviews Setup

  private func setupSubviews() {
    backgroundColor = .systemBackground
    clipsToBounds = true

    setupFirebaseLogoImage()
    setupEmailTextfield()
    setupPasswordTextField()
    setupLoginButton()
    setupCreateAccountButton()
  }

  private func setupFirebaseLogoImage() {
    let firebaseLogo = UIImage(named: "firebaseLogo")
    let imageView = UIImageView(image: firebaseLogo)
    imageView.contentMode = .scaleAspectFit
    addSubview(imageView)
    imageView.translatesAutoresizingMaskIntoConstraints = false
    NSLayoutConstraint.activate([
      imageView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: -55),
      imageView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: 55),
      imageView.widthAnchor.constraint(equalToConstant: 325),
      imageView.heightAnchor.constraint(equalToConstant: 325),
    ])
  }

  private func setupEmailTextfield() {
    emailTextField = textField(placeholder: "Email", symbolName: "person.crop.circle")
    emailTextField.translatesAutoresizingMaskIntoConstraints = false
    addSubview(emailTextField)
    NSLayoutConstraint.activate([
      emailTextField.leadingAnchor.constraint(
        equalTo: safeAreaLayoutGuide.leadingAnchor,
        constant: 15
      ),
      emailTextField.trailingAnchor.constraint(
        equalTo: safeAreaLayoutGuide.trailingAnchor,
        constant: -15
      ),
      emailTextField.heightAnchor.constraint(equalToConstant: 45),
    ])

    let constant: CGFloat = UIDevice.current.orientation.isLandscape ? 15 : 50
    emailTopConstraint = emailTextField.topAnchor.constraint(
      equalTo: safeAreaLayoutGuide.topAnchor,
      constant: constant
    )
    emailTopConstraint.isActive = true
  }

  private func setupPasswordTextField() {
    passwordTextField = textField(placeholder: "Password", symbolName: "lock.fill")
    passwordTextField.translatesAutoresizingMaskIntoConstraints = false
    addSubview(passwordTextField)
    NSLayoutConstraint.activate([
      passwordTextField.leadingAnchor.constraint(
        equalTo: safeAreaLayoutGuide.leadingAnchor,
        constant: 15
      ),
      passwordTextField.trailingAnchor.constraint(
        equalTo: safeAreaLayoutGuide.trailingAnchor,
        constant: -15
      ),
      passwordTextField.heightAnchor.constraint(equalToConstant: 45),
    ])

    let constant: CGFloat = UIDevice.current.orientation.isLandscape ? 5 : 20
    passwordTopConstraint =
      passwordTextField.topAnchor.constraint(
        equalTo: emailTextField.bottomAnchor,
        constant: constant
      )
    passwordTopConstraint.isActive = true
  }

  private func setupLoginButton() {
    addSubview(loginButton)
    loginButton.translatesAutoresizingMaskIntoConstraints = false
    NSLayoutConstraint.activate([
      loginButton.leadingAnchor.constraint(
        equalTo: safeAreaLayoutGuide.leadingAnchor,
        constant: 15
      ),
      loginButton.trailingAnchor.constraint(
        equalTo: safeAreaLayoutGuide.trailingAnchor,
        constant: -15
      ),
      loginButton.heightAnchor.constraint(equalToConstant: 45),
      loginButton.centerYAnchor.constraint(equalTo: centerYAnchor, constant: 5),
    ])
  }

  private func setupCreateAccountButton() {
    addSubview(createAccountButton)
    createAccountButton.translatesAutoresizingMaskIntoConstraints = false
    NSLayoutConstraint.activate([
      createAccountButton.centerXAnchor.constraint(equalTo: centerXAnchor),
      createAccountButton.topAnchor.constraint(equalTo: loginButton.bottomAnchor, constant: 5),
    ])
  }

  // MARK: - Private Helpers

  private func textField(placeholder: String, symbolName: String) -> UITextField {
    let textfield = UITextField()
    textfield.backgroundColor = .secondarySystemBackground
    textfield.layer.cornerRadius = 14
    textfield.placeholder = placeholder
    textfield.tintColor = .systemOrange
    let symbol = UIImage(systemName: symbolName)
    textfield.setImage(symbol)
    return textfield
  }
}
