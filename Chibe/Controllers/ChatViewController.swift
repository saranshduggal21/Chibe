import UIKit
import Firebase

class ChatViewController: UIViewController, Errors {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var messageTextfield: UITextField!
    
    let database = Firestore.firestore() //Making a reference to our Cloud Firestore database. 
    
    var chatMessages: [MessageModel] = [] //chatMessages contains an array of MessageModel objects, which will contain the properties carried by the MessageModel struct. This array will be filled by the live messages that we're going to be retrieving from the Cloud Firestore database.
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.hidesBackButton = true //This will hide the "Back" button that comes with the stack navigator, in the top bar of the ChatViewController as it doesn't make sense to have a back button on this screen.
        title = "Chibe"
        tableView.dataSource = self //tableView will look to our ChatViewController and trigger the delegate methods in order to get the data that it needs.
        //tableView.delegate = self
        
        tableView.register(UINib(nibName: "ChatMessageCell", bundle: nil), forCellReuseIdentifier: "PrototypeCell")
        //Since a custom design file (ChatMessageCell.xib) is being used, we have to register it in ChatViewController for it to show up in the table view.
        
        retrieveChatMessages()
    }
    
    func retrieveChatMessages() { //The point of this function is for it to be able to retrieve and load all of the current data that's inside of our Cloud Firestore database, and populate that info in our table view.
        
        database.collection("chatMessages").order(by: "messageTimestamp", descending: false).addSnapshotListener{ querySnapshot, error in //Tapping into our database.
            //"addSnapshotListener" listens for realtime updates in our database - so whenever a new messzage gets added to our database, the following blocks of code get initialized.
            //"order" orders the messages the are retrieved from the database by their timestamp.
            
            self.chatMessages = [] //Everytime a new message is added to the database collection, this empties out the old and adds the fresh messages into it, from scratch.
            
            if let err = error { //if err is not nil, then the following block of code will be initiated.
                let errorDescription = "\(err.localizedDescription)"
                self.errorAlert(title: "Error", error: errorDescription)
            }
            else {
                if let documents = querySnapshot?.documents {
                    for docs in documents { //Looping through the array of documents (documents is of type [QueryDocumentSnapshot]) to be able to tap into the data of each of them.
                        let chatData = docs.data() //So now, "data()" is a key/value pair in the [QueryDocumentSnapshot] dictionary.
                        
                        if let messageSender = chatData["userSender"] as? String, let textBody = chatData["body"] as? String {
                            //Firebase allows us to store different data types within our database, which is why, "sender" & "textBody" originally have a data type of an optional Any. However, that flexibility makes it a little difficult to retrieve the items.
                            //Thus, "sender" & "textBody" are being CONDITIONALLY DOWNCASTED as strings, making them optional strings. Then, they were optionally binded to make them real strings.
                            
                            let newMessage = MessageModel(sender: messageSender, messageBody: textBody)
                            self.chatMessages.append(newMessage) //"newMessage" is being added (appended) to the chatMessages array (which was empty as shown in line 32).
                            
                            DispatchQueue.main.async {
                                //The process of fetching documents happens in a closure (meaning, in the BG), so when we're ready to update our tableView with the new messgages, we have to fetch the main thread (process happening in the foreground), and its on that main thread that we actually update our data.
                                
                                self.tableView.reloadData() //Will tap into the tableView and trigger the UITableViewDataSource methods again.
                                
                                let indexPath = IndexPath(row: self.chatMessages.count - 1, section: 0)
                                //In the line below we're telling it to scroll to a row, and in the line above we're telling it exactly which row we want to scroll to. "chatMessages.count - 1" is telling the code that we want to scroll to the last message that was added to the chatMessages array.
                                //Section = 0 because we only have 1 section.
                                self.tableView.scrollToRow(at: indexPath, at: .top, animated: true)
                                //Scrolls to the bottom of the tableView (where the new message is shown) everytime a new message added.
                            }
                        }
                    }
                }
            }
        }
    }
    
    @IBAction func sendMessageButton(_ sender: UIButton) {
        if let user = Auth.auth().currentUser?.email, let message = messageTextfield.text {
            //"chatMessage" and "user" are both optional strings because the "messageTextField" could be empty (nil) and, if a user isn't signed in, "currentUser" is nil. Thus, both variables are being optionally binded using the CHAINING method so that, if "messageTextField.text" isn't nil then save it inside "chatMessage" and if there is a "currentUser" logged in then save it inside "user".
            //If "chatMessage" & "user" aren't nil then the following code is run in the "if" statement to send these piecse of data to the Firebase Cloud Firestore.
            
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
            try firebaseAuth.signOut() //The signOut() method can throw an error which is why its been wrapped in a "do/catch" block.
            navigationController?.popToRootViewController(animated: true)
            //"popToRootViewController" is a method part of the navigation controller that will destroy all the other view controllers on the stack except for the ROOT view controller (WelcomeViewController) and updates the display.
        }
        catch let signOutError as NSError {
            print("Error signing out: %@", signOutError)
        }
        
    }
}

extension ChatViewController: UITableViewDataSource { //UITableViewDatasource is the protocol responsible for POPULATING the table view (i.e. how many cells its needs, and which cells to put into the table view).
    //So, when "tableView" loads up, its going to make a request for data.
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return chatMessages.count //The # of rows of "tableView" will be determined by the length of the "chatMessages" array.
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        //This method is asking us for a UITableViewCell that it should display in each and every row of our table view.
        //Thus, THIS METHOD IS GOING TO GET CALLED FOR AS MANY ROWS/CELLS AS THERE ARE IN "tableView".
        //So here, we have to CREATE a table cell and return it to "tableView".
        
        let currentMessage = chatMessages[indexPath.row] //Gets the current message from the chatMessages array.
        
        let tableCell = tableView.dequeueReusableCell(withIdentifier: "PrototypeCell", for: indexPath) as! ChatMessageCell
        //"dequeueReusableCell" returns a reusable table-view cell object for the specified reuse identifier and adds it to the table.
        //By using "as!" we're able to know about all of the properties in the ChatMessageCell class and we're able to CAST this reusable cell as the ChatMessageCell class.
        
        tableCell.textMessageLabel.text = currentMessage.messageBody
        //"textMessageLabel" is a property of the ChatMessageCell class and by editing it will allow us to correspond to the main label in the cell.
        
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

//extension ChatViewController: UITableViewDelegate {
//    //Now whenever "tableView" is interacted with by the user (for ex. when a particular row in tableView is selected), then the method below will be triggered because we've set ChatViewController (the current class) as the delegate.
//    //This then allows us to RECIEVE MESSAGES FROM "tableView" and when the user interacts with tableView then we know exactly which cell it is that they intereacted with.
//    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
//        <#code#>
//    }
//
//}
