

import UIKit

var imageCache = NSMutableDictionary()
extension UIImageView {

    func loadImageUsingCacheWithUrlString(urlString: String) {

        self.image = nil
        
        if let img = imageCache.value(forKey: urlString) as? UIImage{
            self.image = img
        }
        else{
            let session = URLSession.shared
            let task = session.dataTask(with: NSURL(string: urlString)! as URL, completionHandler: { (data, response, error) -> Void in

                if(error == nil){

                    if let img = UIImage(data: data!) {
                        
                        imageCache.setValue(img, forKey: urlString)    // Image saved for cache
                        DispatchQueue.main.async {
                                 
                            self.image = img
                            
                    }
                        
                    }


                }
            })
            task.resume()
        }
    }
}

class FeedListViewController: UITableViewController, XMLParserDelegate ,UISearchBarDelegate{

    @IBOutlet weak var searchBar: UISearchBar!
    var myFeed : NSArray = []
    var url: [URL?] = []
    var urlArray : [String] = []
    override func viewDidLoad() {
        
        tableView.keyboardDismissMode = .onDrag
        super.viewDidLoad()
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 140
        tableView.backgroundColor = UIColorFromRGB(rgbValue: 0xdf4926)
        self.tableView.dataSource = self
        self.tableView.delegate = self
        self.searchBar.delegate = self

        let url1 = "http://feeds.skynews.com/feeds/rss/technology.xml"
        let url2 = "https://www.corrieredellosport.it/rss/"
        urlArray = [url1 , url2]
        loadData()
    }
    
    @IBAction func refreshFeed(_ sender: Any) {
        print("refreshFeed")
        loadData()
    }

    func loadData() {
        
        loadRss(urlArray)
    }

    func loadRss(_ data: [String]) {

        // XmlParserManager instance/object/variable.
        let myParser : XmlParserManager = XmlParserManager().initWithURL(data) as! XmlParserManager

        // Put feed in array.
        myFeed = myParser.feeds
        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "openPage" {
            let indexPath: IndexPath = self.tableView.indexPathForSelectedRow!
            let selectedFURL: String = (myFeed[indexPath.row] as AnyObject).object(forKey: "link") as! String

            // Instance of feedpageviewcontrolelr.
            let fivc: FeedItemWebViewController = segue.destination as! FeedItemWebViewController
            fivc.selectedFeedURL = selectedFURL as String
        }
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100
    }

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return myFeed.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! customCellTableViewCell
       
        cell.textLabel?.backgroundColor = UIColor.clear
        cell.detailTextLabel?.backgroundColor = UIColor.clear
        
        if indexPath.row % 2 == 0 {
            cell.backgroundColor = UIColor(white: 1, alpha: 0)
        } else {
            cell.backgroundColor = UIColor(white: 1, alpha: 0.1)
        }
        
        cell.urlString = (myFeed.object(at: indexPath.row) as AnyObject).object(forKey: "image") as! String
        
        let cellImageLayer: CALayer?  = cell.imageView?.layer
        
        cellImageLayer!.cornerRadius = 35
        cellImageLayer!.masksToBounds = true
        cell.imageView?.loadImageUsingCacheWithUrlString(urlString: cell.urlString)

        cell.textLabel?.text = (myFeed.object(at: indexPath.row) as AnyObject).object(forKey: "title") as? String
        cell.textLabel?.textColor = UIColor.white
        cell.textLabel?.numberOfLines = 0
        cell.textLabel?.lineBreakMode = .byWordWrapping
        cell.detailTextLabel?.text = (myFeed.object(at: indexPath.row) as AnyObject).object(forKey: "pubDate") as? String
        cell.detailTextLabel?.textColor = UIColor.white
        
        return cell
    }

    func UIColorFromRGB(rgbValue: UInt) -> UIColor {
        return UIColor(
            red: CGFloat((rgbValue & 0xFF0000) >> 16) / 255.0,
            green: CGFloat((rgbValue & 0x00FF00) >> 8) / 255.0,
            blue: CGFloat(rgbValue & 0x0000FF) / 255.0,
            alpha: CGFloat(1.0)
        )
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchText.isEmpty{
            let url1 = "http://feeds.skynews.com/feeds/rss/technology.xml"
            let url2 = "https://www.corrieredellosport.it/rss/"
            self.urlArray = [url1 , url2]
        }else{
            self.urlArray = []
        }
        self.loadData()
   }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        
        let apiKey = "apikey"
        let searchEngineId = "016317495089526517946:lyxihnbbmnx"
        let serverAddress = String(format: "https://www.googleapis.com/customsearch/v1?q=%@&cx=%@&key=%@" ,"news \(searchBar.text)  filetype:xml",searchEngineId, apiKey)


        let url = serverAddress.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)
        let finalUrl = URL(string: url!)
        let request = NSMutableURLRequest(url: finalUrl!, cachePolicy: .useProtocolCachePolicy, timeoutInterval: 10)
        request.httpMethod = "GET"

        let session = URLSession.shared

        let datatask = session.dataTask(with: request as URLRequest) { (data, response, error) in
            do{
                if let jsonResult = try JSONSerialization.jsonObject(with: data!, options: []) as? NSDictionary {
                    print("asyncResult\(jsonResult)")
                    if let arry = jsonResult["items"] as? [[String:AnyObject]] {
                             for dictionary in arry {
                                self.urlArray.append(dictionary["link"] as! String)
                                }
                    }

                }
            }
            catch let error as NSError {
                print(error.localizedDescription)
            }
        }
        datatask.resume()
        self.loadData()
    }
}

