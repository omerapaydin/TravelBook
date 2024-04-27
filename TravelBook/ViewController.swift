

import UIKit
import MapKit
import CoreLocation
import CoreData

class ViewController: UIViewController , MKMapViewDelegate , CLLocationManagerDelegate{

    @IBOutlet weak var commentText: UITextField!
    @IBOutlet weak var nameText: UITextField!
    var locationManager = CLLocationManager()
    var chosenLatitude = Double()
    var chosenLongitude = Double()
    
    var selectedTitle = ""
    var selectedTitleId : UUID?
    
    var annotationTitle = ""
    var annotationSubtitle = ""
    var annotationLatitude = Double()
    var annotationLongitude = Double()
    
    
    @IBOutlet weak var mapView: MKMapView!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        if selectedTitle != "" {
            
            let appDelegate = UIApplication.shared.delegate as! AppDelegate
            let context = appDelegate.persistentContainer.viewContext
            
            let fetch = NSFetchRequest<NSFetchRequestResult>(entityName: "Places")
            let idString = selectedTitleId?.uuidString
            fetch.predicate = NSPredicate(format: "id = %@", idString!)
            fetch.returnsObjectsAsFaults = false
            
            do {
                
                  let results = try context.fetch(fetch)
                
                  for result in results as! [NSManagedObject]{
                    
                      if let title = result.value(forKey: "title") as? String {
                          annotationTitle = title
                          
                          if let subtitle = result.value(forKey: "subtitle") as? String {
                              annotationSubtitle = subtitle
                              
                              if let latitude = result.value(forKey: "latitude") as? Double {
                                  annotationLatitude = latitude
                                  
                                  
                                  if let longitude = result.value(forKey: "longitude") as? Double {
                                      annotationLongitude = longitude
                                      
                                      
                                      let annotation = MKPointAnnotation()
                                      annotation.title = annotationTitle
                                      annotation.subtitle = annotationSubtitle
                                      let coordinate = CLLocationCoordinate2D(latitude: annotationLatitude, longitude: annotationLongitude)
                                      annotation.coordinate = coordinate
                                      
                                      mapView.addAnnotation(annotation)
                                      nameText.text = annotationTitle
                                      commentText.text = annotationSubtitle
                                      
                                      
                                  }
                              }
                          }
                      }
                      
                }
                
            }catch {
                print("error")
            }
            
            
        }else {
            
            
            
        }
        
        mapView.delegate = self
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
        
        
        let gest = UILongPressGestureRecognizer(target: self, action: #selector(chooseLocation(gestureRecognizer:)))
        gest.minimumPressDuration = 3
        mapView.addGestureRecognizer(gest)
        
        
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let location = CLLocationCoordinate2D(latitude: locations[0].coordinate.latitude, longitude: locations[0].coordinate.longitude)
        let span = MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
        let ragion = MKCoordinateRegion(center: location, span: span)
        mapView.setRegion(ragion, animated: true)
        
        
    }
    
    
    @objc func chooseLocation(gestureRecognizer:UILongPressGestureRecognizer){
        
        if gestureRecognizer.state == .began {
            
            let touchPoint = gestureRecognizer.location(in: self.mapView)
            let touchedCoordinates = self.mapView.convert(touchPoint, toCoordinateFrom: self.mapView)
            
            chosenLatitude = touchedCoordinates.latitude
            chosenLongitude = touchedCoordinates.longitude
            
            let annotation = MKPointAnnotation()
            annotation.coordinate = touchedCoordinates
            annotation.title = nameText.text
            annotation.subtitle = commentText.text
            self.mapView.addAnnotation(annotation)
            
        }
        
    }
    
    
    @IBAction func save(_ sender: Any) {
        
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext
        let newAdd = NSEntityDescription.insertNewObject(forEntityName: "Places", into: context)
        
        newAdd.setValue(nameText.text, forKey: "title")
        newAdd.setValue(commentText.text, forKey: "subtitle")
        newAdd.setValue(chosenLatitude, forKey: "latitude")
        newAdd.setValue(chosenLongitude, forKey: "longitude")
        newAdd.setValue(UUID(), forKey: "id")
        
        do {
            try context.save()
            print("success")
        }catch {
            print("error")
        }
        
        
        
    }
    
}

