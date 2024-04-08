import UIKit
import FirebaseFirestore
import SDWebImage

class ViewController: UIViewController, UITextFieldDelegate {

    @IBOutlet weak var searchTextField: UITextField!
    @IBOutlet weak var containerView: UIStackView!
    @IBOutlet weak var plantImageView: UIImageView!

    var firestore: Firestore!

    override func viewDidLoad() {
        super.viewDidLoad()
        searchTextField.delegate = self
        firestore = Firestore.firestore()
        
        customizeUI()
    }

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        performSearch()
        return true
    }

    @IBAction func searchButtonTapped(_ sender: UIButton) {
        performSearch()
    }

    func performSearch() {
        guard var searchText = searchTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines), !searchText.isEmpty else {
            return
        }

       
        
        if !searchText.isEmpty {
            // Capitalize the first letter of the search text
            searchText = searchText.prefix(1).capitalized + searchText.dropFirst()
        }

        let collectionRef = firestore.collection("plantdata")
        let query = collectionRef.whereField("name", isEqualTo: searchText)

        query.getDocuments { [self] (snapshot, error) in
            if let error = error {
                print("Error getting documents: \(error)")
            } else {
                guard let snapshot = snapshot else { return }

               
                    for document in snapshot.documents {
                        let data = document.data()
                      
                      
                        if var imageURLString = (data["image"] as? String) {
                            imageURLString = imageURLString.replacingOccurrences(of: "http://", with: "https://")
                            print(imageURLString)
                            if let imageURL = URL(string: String(imageURLString)) {
                                plantImageView.sd_setImage(with: imageURL)
                            }
                        }

                        
                        if let fieldValue = (data["avoidInstructions"] as? String){
                            self.addLabel(with: String(fieldValue))
                        }
                        if let fieldValue = (data["culinaryHints"] as? String) {
                            self.addLabel(with: String(fieldValue))
                        }
                        if let fieldValue = (data["harvestInstructions"] as? String) {
                            self.addLabel(with: String(fieldValue))
                        }
                        if let fieldValue = (data["sowInstructions"] as? String) {
                            self.addLabel(with: String(fieldValue))
                        }
                        if let fieldValue = (data["compatiblePlants"] as? String) {
                            self.addLabel(with: String(fieldValue))
                        }
                    }
                }
            }
        
    }



    func addLabel(with text: String) {
        let label = UILabel()
        label.text = text
        label.numberOfLines = 0
        label.lineBreakMode = .byWordWrapping
        label.textColor = .darkGray
        label.font = UIFont.systemFont(ofSize: 16)
        containerView.addArrangedSubview(label)
    }



    
   
    func customizeUI() {
        // Background color
        view.backgroundColor = UIColor.white
        
        // Customize search text field
        searchTextField.backgroundColor = UIColor.lightGray.withAlphaComponent(0.2)
        searchTextField.layer.cornerRadius = 15
        searchTextField.layer.borderWidth = 1
        searchTextField.layer.borderColor = UIColor.gray.cgColor
        searchTextField.font = UIFont(name: "Arial", size: 16)
        searchTextField.textColor = UIColor.darkGray
        searchTextField.attributedPlaceholder = NSAttributedString(string: "Search for plants", attributes: [NSAttributedString.Key.foregroundColor: UIColor.gray])
        
      
        
       
    }

}

