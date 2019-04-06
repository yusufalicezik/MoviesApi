//
//  MyFavsVC.swift
//  MyMovies
//
//  Created by Yusuf ali cezik on 4.04.2019.
//  Copyright © 2019 Yusuf ali cezik. All rights reserved.
//

import UIKit
import CoreData
import Alamofire
import AlamofireImage
import SwiftyJSON


class MyFavsVC: UIViewController,UITableViewDelegate,UITableViewDataSource {
   
    let BASE_URL="https://api.themoviedb.org/3"
    let API_KEY:String="ae32fbb3535e8e640aff557640da5021"
    let LANGUAGE="tr-TR"
    let TOP_RATED_URL="/movie/"
    var parameters:[String:String]?
    var params:[String:String]?
    let PHOTO_URL="https://image.tmdb.org/t/p/w500"
    //https://api.themoviedb.org/3/movie/550?api_key=ae32fbb3535e8e640aff557640da5021&language=tr-TR
    
   
    @IBOutlet weak var tableView: UITableView!
    
    var movieArray=[Movie]()
    var idArray=[String]()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate=self
        tableView.dataSource=self
        parameters=["api_key":API_KEY, "language":LANGUAGE] as? [String : String]
        
        
 
    }
    
    @objc func kaydedilenFilmIdleriniCek(){
        idArray.removeAll(keepingCapacity: false)
        movieArray.removeAll(keepingCapacity: false)
        
        
        let delegate=UIApplication.shared.delegate as! AppDelegate
        let context=delegate.persistentContainer.viewContext
        let fetchRequest=NSFetchRequest<NSFetchRequestResult>(entityName: "Movies")
        fetchRequest.returnsObjectsAsFaults=false
        do {
            let results=try context.fetch(fetchRequest)
            
            if results.count>0{
                
                for result in results as! [NSManagedObject]{
                    let tempId=result.value(forKey: "id") as? String
                    idArray.append(tempId!)
                    //veritabanından kaydettiğim film idlerini aldım. bu id lere göre api den filmleri tek tek çekeceğim.
                }
                print("sayi id",idArray.count)
                self.verileriCek()
            }
        }catch{
        }
    }
    
    
    func verileriCek(){
       
        
        if idArray.count > 0 { //veritabanında herhangi bir veri var ise;
            for i in 0...idArray.count-1{
            
            Alamofire.request(BASE_URL+TOP_RATED_URL+idArray[i], method:.get, parameters:self.parameters).responseJSON {
                response in if response.result.isSuccess {
                    let gelenVeri:JSON=JSON(response.result.value!)
                    print(gelenVeri)
                    if i == self.idArray.count-1{ //son veri ise;
                        self.verileriParcala(json:gelenVeri,sonMu:true)
                    }else{
                        self.verileriParcala(json:gelenVeri,sonMu:false)
                    }
                }else {
                    print(response.result.description)
                    print("error \(String(describing: response.result.error))")
                    
                    }
                }
           }
            
        }
    }
    
    func verileriParcala(json:JSON,sonMu:Bool){
        let title=json["title"].stringValue
        let image=json["poster_path"].stringValue
        let overView=json["overview"].stringValue
        
        let movie=Movie()
        
        if json["genres"].count > 0 {
            for j in 0...json["genres"].count-1{
                
                movie.movieTypeArray.append(json["genres"][j]["id"].stringValue)
                //film türünü ekledik. birden fazlaysa hepsini ekledik.
                //print("ddd",json["genres"][j]["id"].stringValue)
            }
        }
        
        
        movie.title=title
        movie.image=image
        movie.overView=overView
        
        
        
        movieArray.append(movie)
      
        if movieArray.count == idArray.count{ //farklı thredde çektiği için film boyutuna göre bazen
            //bazı filmler geç çekilebiliyor, 3 film varsa bazen hepsini bazen 1,2 tanesini çekip
            //tabloyu yeniliyordu, ama benim film sayım, id sayıma eşit olmadan listemi yenileme dedim;
            tableView.reloadData()
        }
        
        
        
    }
    
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return movieArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell=tableView.dequeueReusableCell(withIdentifier: "cell", for:indexPath) as! SearchCell
        if movieArray.count > 0 {
            cell.movieTitleLabel.text=movieArray[indexPath.row].title
            if movieArray[indexPath.row].overView != nil && movieArray[indexPath.row].overView != ""{
                cell.movieSentenceLabel.text=movieArray[indexPath.row].overView
            }else{
                cell.movieSentenceLabel.text="There is no overview about this movie"
            }
            //image için;
            Alamofire.request(PHOTO_URL+movieArray[indexPath.row].image!).responseImage {
                response in
                if let image=response.result.value {
                    cell.movieImage.image=image
                }
            }
            
            //
            if (movieArray[indexPath.row].movieTypeArray.count) > 0 {
                for i in 0...movieArray[indexPath.row].movieTypeArray.count-1 {
                    if i == 0 {
                        
                        cell.movieTypeIds.text!+=String(movieArray[indexPath.row].movieTypeArray[i])
                    }else{
                        
                        cell.movieTypeIds.text!+=","+String(movieArray[indexPath.row].movieTypeArray[i])
                    }
                }
                
            }
        }
        return cell
    }

    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete{
            
            let silinecekID=idArray[indexPath.row]
            //veritabanından silmek için;
            let appDelegate=UIApplication.shared.delegate as! AppDelegate
            let context=appDelegate.persistentContainer.viewContext
            let fetchRequest=NSFetchRequest<NSFetchRequestResult>(entityName: "Movies")
            do {
                let results = try context.fetch(fetchRequest)
                for result in results as! [NSManagedObject]{
                    if let gelenID=result.value(forKey: "id") as? String {
                        if(gelenID==silinecekID){ //tablodan sildiğim isim v.tabanında varsa vtabanından da sil
                            context.delete(result) //şuan içinde bulunduğum result olan nsobject i sil.
                            ///veritabanı-end/>
                           print("silinen film",movieArray[indexPath.row].title!)
                            movieArray.remove(at: indexPath.row)
                            idArray.remove(at: indexPath.row)
                            tableView.deleteRows(at: [indexPath], with: UITableView.RowAnimation.fade)
                            do{
                                try context.save()
                                
                            }catch{
                                
                            }
                            break //bulup sildikten sonra for u kır.
                            
                            
                        }else{
                            print("silinen film-m",movieArray[indexPath.row].title!)

                        }
                    }
                }
            }catch{
                
            }
            
            
           
        }
        //v.tabanından da silme işlemi yapılacak;
    }

    
    override func viewWillAppear(_ animated: Bool) {
     /*   NotificationCenter.default.addObserver(self, selector: #selector(MyFavsVC.kaydedilenFilmIdleriniCek), name: NSNotification.Name(rawValue: "newMovie"), object: nil)
        */
        //eğer bi yenileme olmuşsa verileri silip tekrar çekecek.
        kaydedilenFilmIdleriniCek()
    }
    
    

}
