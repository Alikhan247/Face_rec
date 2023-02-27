//
//  AuthorizedViewController.swift
//  Face_rec
//
//  Created by Alikhan Nursapayev on 12.02.2023.
//

import UIKit

class AuthorizedViewController: UIViewController {
    var name: String? = ""
    @IBOutlet weak var authorizedLabel: UILabel!
    
    
       private let label = UILabel()
       private let animationView = UIImageView()
       private let button = UIButton(type: .system)
    override func viewDidLoad() {
        super.viewDidLoad()
        authorizedLabel.text  = "Authorized as: \(name ?? "")"
        // Do any additional setup after loading the view.
        // Set up label
                label.text = "You are now authorized"
                label.font = UIFont.systemFont(ofSize: 20, weight: .bold)
                label.textAlignment = .center
                
        animationView.image = UIImage(systemName: "checkmark.seal.fill")
                // Set up animation view
                animationView.backgroundColor = UIColor.green
                animationView.layer.cornerRadius = 10
                animationView.alpha = 0
                
                // Set up button
                button.setTitle("Proceed", for: .normal)
//                button.addTarget(self, action: #selector(buttonTapped), for: .touchUpInside)
                
                // Add subviews and set up constraints
                view.addSubview(label)
                view.addSubview(animationView)
                view.addSubview(button)
                
                label.translatesAutoresizingMaskIntoConstraints = false
                animationView.translatesAutoresizingMaskIntoConstraints = false
                button.translatesAutoresizingMaskIntoConstraints = false
                
                NSLayoutConstraint.activate([
                    // Label constraints
                    label.topAnchor.constraint(equalTo: view.topAnchor, constant: 50),
                    label.leadingAnchor.constraint(equalTo: view.leadingAnchor),
                    label.trailingAnchor.constraint(equalTo: view.trailingAnchor),
                    
                    // Animation view constraints
                    animationView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
                    animationView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
                    animationView.widthAnchor.constraint(equalToConstant: 80),
                    animationView.heightAnchor.constraint(equalToConstant: 80),
                    
                    // Button constraints
                    button.leadingAnchor.constraint(equalTo: view.leadingAnchor),
                    button.trailingAnchor.constraint(equalTo: view.trailingAnchor),
                    button.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -50),
                    button.heightAnchor.constraint(equalToConstant: 44),
                ])
    }
    
    override func viewDidAppear(_ animated: Bool) {
        // Animate confirmation
                UIView.animate(withDuration: 1.0) {
                    self.animationView.alpha = 1
                }
    }

    @objc func buttonTapped() {
//        self.navigationController?.  /
        }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
