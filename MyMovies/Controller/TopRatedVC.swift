//
//  FirstViewController.swift
//  MyMovies
//
//  Created by Yusuf ali cezik on 3.04.2019.
//  Copyright © 2019 Yusuf ali cezik. All rights reserved.
//

import UIKit
import CoreLocation
import CoreData
import Alamofire
import AlamofireImage
import SwiftyJSON

class TopRatedVC: UIViewController,UITableViewDelegate,UITableViewDataSource {
   
    @IBOutlet weak var tableView: UITableView!
    
    var movieArray=[Movie]()
    let BASE_URL="https://api.themoviedb.org/3"
    let API_KEY:String="ae32fbb3535e8e640aff557640da5021"
    let LANGUAGE="tr-TR"
    let TOP_RATED_URL="/movie/top_rated"
    var parameters:[String:String]?
    let PHOTO_URL="https://image.tmdb.org/t/p/w500"
    
    
    var selectedID:String?

    
    
    override func viewDidLoad() {
        super.viewDidLoad()
         parameters=["api_key":API_KEY, "language":LANGUAGE]
        tableView.delegate=self
        tableView.dataSource=self
        
        verileriCek()
        
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return movieArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
         let cell=tableView.dequeueReusableCell(withIdentifier: "cell", for:indexPath) as! TopRatedCell
    
        cell.movieNameLabel.text=movieArray[indexPath.row].title
        
        //imdb si 9.6666666666 tarzı olanlar için. kısaltma
        if (movieArray[indexPath.row].imdb?.count)!>3 {
            if let imdbRate = movieArray[indexPath.row].imdb{
                
                let shortImdb=imdbRate.prefix(3)
                cell.movieRateLabel.text="IMDB:\(shortImdb)"
                
            }
        }else{
            cell.movieRateLabel.text="IMDB:\(movieArray[indexPath.row].imdb ?? "error")"
        }
        
        
        cell.movieIDLabel.text=movieArray[indexPath.row].id
        
        
        
        
        Alamofire.request(PHOTO_URL+movieArray[indexPath.row].image!).responseImage {
            response in
            if let image=response.result.value {
                cell.movieImage.image=image
            }
        }
        
        
        return cell
    }
    
    
    func verileriCek(){
        
       
        Alamofire.request(BASE_URL+TOP_RATED_URL, method: .get, parameters:self.parameters).responseJSON {
            response in if response.result.isSuccess {
                print("basarili")
                
                let gelenVeri:JSON=JSON(response.result.value!)
                print(gelenVeri["results"][0]["title"])
                self.verileriParcala(json:gelenVeri)
            }else {
                print("error \(String(describing: response.result.error))")
            }
        }
    }
    
    func verileriParcala(json:JSON){
       movieArray.removeAll(keepingCapacity: false)
        //result ın içinde gezmemiz gerek
       if json["results"].count > 0 {
        
        for i in 0...json["results"].count-1{
            let title=String(i+1)+"."+json["results"][i]["title"].stringValue
            let image=json["results"][i]["backdrop_path"].stringValue
            let id=json["results"][i]["id"].stringValue
            let imdb=json["results"][i]["vote_average"].stringValue
            let overView=json["results"][i]["overview"].stringValue
            let detailImage=json["results"][i]["poster_path"].stringValue
            
            let movie=Movie()
            movie.id=id
            movie.title=title
            movie.overView=overView
            movie.detailImage=detailImage
            movie.imdb=imdb
            movie.image=image
            
            
            print(title)
            
            movieArray.append(movie)
        }

        tableView.reloadData()
    }

}
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectedID=movieArray[indexPath.row].id
        performSegue(withIdentifier: "toDetailsVC", sender: nil)
    }
    
    
   
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
         globalID=selectedID
        
    }

}
