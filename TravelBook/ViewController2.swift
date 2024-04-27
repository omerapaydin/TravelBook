

import UIKit
import CoreData

class ViewController2: UIViewController , UITableViewDelegate , UITableViewDataSource {

    @IBOutlet weak var tableView: UITableView!
    var titleArray = [String]()
    var idArray = [UUID]()
    
    var chosenTitle = ""
    var chosenTitleId : UUID?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.delegate = self
        tableView.dataSource = self
        
        navigationController?.navigationBar.topItem?.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.add, target: self, action: #selector(addButtonClicked))
        
        getData()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        NotificationCenter.default.addObserver(self, selector: #selector(getData), name: NSNotification.Name("newPlace"), object: nil)
    }
    
    
    
   @objc func getData(){
        
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext
        
        let fetch = NSFetchRequest<NSFetchRequestResult>(entityName: "Places")
        fetch.returnsObjectsAsFaults = false
        
        do {
            
            let results = try context.fetch(fetch)
            
            for result in results as! [NSManagedObject] {
                
                if let title = result.value(forKey: "title") as? String {
                    titleArray.append(title)
                }
                
                if let id = result.value(forKey: "id") as? UUID {
                    idArray.append(id)
                }
                
            }
            
        }catch{
            print("error")
        }
        
            }
    
    
    @objc func addButtonClicked(){
        chosenTitle = ""
        performSegue(withIdentifier: "goTo2", sender: nil)
        
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return titleArray.count
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell()
        cell.textLabel?.text = titleArray[indexPath.row]
        return cell
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "goTo2" {
            let desc = segue.destination as! ViewController
            desc.selectedTitle = chosenTitle
            desc.selectedTitleId = chosenTitleId
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        chosenTitle = titleArray[indexPath.row]
        chosenTitleId = idArray[indexPath.row]
        performSegue(withIdentifier: "goTo2", sender: nil)
    }

  

}
