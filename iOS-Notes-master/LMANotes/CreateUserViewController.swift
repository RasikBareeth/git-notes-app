//
//  CreateUserViewController.swift
//  LMANotes
//
//  Created by expert on 06/04/23.
//  Copyright © 2023 Learn Make Application. All rights reserved.
//

import Foundation
import FirebaseDatabase
import FirebaseAuth
import UIKit

class CreateUserViewController: UIViewController {
    weak var delegate: LoginDelegate?
    
    private var loginView: LoginView { view as! LoginView }
    
    private var email: String { loginView.emailTextField.text! }
    private var password: String { loginView.passwordTextField.text! }
    
    // Hides tab bar when view controller is presented
    override var hidesBottomBarWhenPushed: Bool { get { true } set {} }
    
    // MARK: - View Controller Lifecycle Methods
    
    override func loadView() {
        let loginView = LoginView()
        loginView.setupSubviews(false)
        view = loginView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loginView.passwordTextField.isSecureTextEntry = true
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
    
    func createUser(email: String, password: String) {
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
        navigationItem.title = "Create User"
        navigationItem.backBarButtonItem?.tintColor = .systemYellow
        navigationController?.navigationBar.prefersLargeTitles = true
    }
    
    private func configureDelegatesAndHandlers() {
        loginView.emailTextField.delegate = self
        loginView.passwordTextField.delegate = self
        loginView.signUpAccountButton.addTarget(
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

extension CreateUserViewController: UITextFieldDelegate {
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
