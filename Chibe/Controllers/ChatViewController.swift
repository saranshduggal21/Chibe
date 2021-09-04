import UIKit
import Firebase

class ChatViewController: UIViewController, Errors {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var messageTextfield: UITextField!
    
    let database = Firestore.firestore() //Making a reference to our Cloud Firestore database. 
    
    var chatMessages: [MessageModel] = [] //chatMessages array will be filled by the live messages that we're going to be retrieving from the Cloud Firestore database.
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.hidesBackButton = true
        title = "Chibe"
        tableView.dataSource = self //tableView will look to our ChatViewController and trigger the UITableViewDataSource methods in order to get the data that it needs.
        tableView.register(UINib(nibName: "ChatMessageCell", bundle: nil), forCellReuseIdentifier: "PrototypeCell")

        retrieveChatMessages()
    }
    
    func retrieveChatMessages() { //Function will load all of the current data that's inside of our Cloud Firestore database, and populate that info in our table view.
        
        database.collection("chatMessages").order(by: "messageTimestamp", descending: false).addSnapshotListener{ querySnapshot, error in //Tapping into our database.
            //"addSnapshotListener" listens for realtime updates in our database.
            
            self.chatMessages = []
            if let err = error {
                let errorDescription = "\(err.localizedDescription)"
                self.errorAlert(title: "Error", error: errorDescription)
            }
            else {
                if let documents = querySnapshot?.documents {
                    for docs in documents { //Looping through the array of documents (documents is of type [QueryDocumentSnapshot]) to be able to tap into the data of each of them.
                        let chatData = docs.data()
                        
                        if let messageSender = chatData["userSender"] as? String, let textBody = chatData["body"] as? String {
                            let newMessage = MessageModel(sender: messageSender, messageBody: textBody)
                            self.chatMessages.append(newMessage) //"newMessage" is being added (appended) to the chatMessages array (which was originally empty).
                            
                            DispatchQueue.main.async {
                                //We have to fetch the main thread (process happening in the foreground), and its on that main thread that we actually update our message data.
                                self.tableView.reloadData()
                                let indexPath = IndexPath(row: self.chatMessages.count - 1, section: 0)
                                self.tableView.scrollToRow(at: indexPath, at: .top, animated: true)
                            }
                        }
                    }
                }
            }
        }
    }
    
    @IBAction func sendMessageButton(_ sender: UIButton) {
        if let user = Auth.auth().currentUser?.email, let message = messageTextfield.text {
            
            database.collection("chatMessages").addDocument(data: ["userSender" : user, "body": message, "messageTimestamp": Date().timeIntervalSince1970]) { (error) in
                //The data being sent to Cloud Firestore is in the form of a dictionary with key/value pairs. They first key/value pair refers to the person sending the message (so the email will be stored), and the second key/value pair refers to the message body (message will be stores in the Firestore).
                
                if let err = error {
                    let errorDescription = "\(err.localizedDescription)"
                    self.errorAlert(title: "Error", error: errorDescription)
                }
                else {
                    print("Sucessfully saved message.")
                }
            }
        }
        messageTextfield.text = ""
    }
    
    
    @IBAction func logOutButton(_ sender: UIBarButtonItem) {
        let firebaseAuth = Auth.auth()
        do {
            try firebaseAuth.signOut()
            navigationController?.popToRootViewController(animated: true)
            //"popToRootViewController" destroys all the  view controllers except for the ROOT view controller (WelcomeViewController) and updates the display.
        }
        catch let signOutError as NSError {
            print("Error signing out: %@", signOutError)
        }
        
    }
}

extension ChatViewController: UITableViewDataSource {
    //When "tableView" loads up, its going to make a request for data.
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return chatMessages.count //The # of rows of "tableView" will be determined by the length of the "chatMessages" array.
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        //This METHOD IS GOING TO GET CALLED FOR AS MANY ROWS/CELLS AS THERE ARE IN "tableView".
        
        let currentMessage = chatMessages[indexPath.row]
        
        let tableCell = tableView.dequeueReusableCell(withIdentifier: "PrototypeCell", for: indexPath) as! ChatMessageCell
        //"dequeueReusableCell" returns a reusable table-view cell object for the specified reuse identifier and adds it to the table.
        
        tableCell.textMessageLabel.text = currentMessage.messageBody
        
        if currentMessage.sender == Auth.auth().currentUser?.email { //Checking to see if the text sender is the same as the logged in user.
            //So, all the messages shown here are from the current user.
            tableCell.userAvatarImage.isHidden = false
            tableCell.otherUserAvatarImage.isHidden = true
            tableCell.messageBubbleView.backgroundColor = UIColor(named: "LightAqua")
            tableCell.textMessageLabel.textColor = UIColor(named: "Black")
        }
        else {
            //These are all the messages from the other users.
            tableCell.userAvatarImage.isHidden = true
            tableCell.otherUserAvatarImage.isHidden = false
            tableCell.messageBubbleView.backgroundColor = UIColor(named: "Aqua")
            tableCell.textMessageLabel.textColor = UIColor(named: "White")
        }
        
        return tableCell
    }
    
}
