//
//  SearchVC.swift
//  MyMovies
//
//  Created by Yusuf ali cezik on 4.04.2019.
//  Copyright © 2019 Yusuf ali cezik. All rights reserved.
//

import UIKit
import Alamofire
import AlamofireImage
import SwiftyJSON





class SearchVC: UIViewController,UITableViewDelegate,UITableViewDataSource {
 
    

    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var tableView: UITableView!
    
    var movieArray=[Movie]()
    var selectedID:String?
    
    let BASE_URL="https://api.themoviedb.org/3"
    let API_KEY:String="ae32fbb3535e8e640aff557640da5021"
    let LANGUAGE="tr-TR"
    let SEARCH_URL="/search/movie"
    var parameters:[String:String]?
    let PHOTO_URL="https://image.tmdb.org/t/p/w500"
    
    //https://api.themoviedb.org/3/search/movie?api_key=ae32fbb3535e8e640aff557640da5021&language=en-US&query=f&page=1&include_adult=false
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate=self
        tableView.dataSource=self
        
        parameters=["api_key":API_KEY, "language":LANGUAGE] //butona basıldığında ekleme yapılacak(query)
        
        
        
       
    }
    

    @IBAction func searchButtonClicked(_ sender: Any) {
        
        if searchBar.text != nil && searchBar.text != "" && searchBar.text != " "{
            parameters!["query"]=searchBar.text!
            verileriCek()
        }else{
           movieArray.removeAll(keepingCapacity: false)
            tableView.reloadData()
        }
        
    }
    
    func verileriCek(){
        Alamofire.request(BASE_URL+SEARCH_URL, method: .get, parameters:self.parameters).responseJSON {
            response in if response.result.isSuccess {
                print("basarili")
                
                let gelenVeri:JSON=JSON(response.result.value!)
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
            let title=json["results"][i]["title"].stringValue
            let image=json["results"][i]["poster_path"].stringValue
            let id=json["results"][i]["id"].stringValue
            let imdb=json["results"][i]["vote_average"].stringValue
            let overView=json["results"][i]["overview"].stringValue
            
            
            let movie=Movie()
            movie.id=id
            movie.title=title
            movie.overView=overView
            movie.imdb=imdb
            movie.image=image
          
            if json["results"][i]["genre_ids"].count > 0 {
            for j in 0...json["results"][i]["genre_ids"].count-1{

                    movie.movieTypeArray.append(json["results"][i]["genre_ids"][j].stringValue)
                    //film türünü ekledik. birden fazlaysa hepsini ekledik.
                print("ddd",json["results"][i]["genre_ids"][j].stringValue)
                }
            }
           
            
            
            
            movieArray.append(movie)
        }
        
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
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectedID=movieArray[indexPath.row].id
        performSegue(withIdentifier: "toDetailsVC", sender: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        globalID=selectedID
    }
    
    
    
    
    
    /*
     "total_pages" : 2,
     "total_results" : 22,
     "results" : [
     {
     "original_title" : "Fei Lung Gwoh Gong",
     "id" : 503917,
     "popularity" : 5.9500000000000002,
     "backdrop_path" : null,
     "poster_path" : "\/wxWLj73hr9LCluXgdV7o8zUOiDc.jpg",
     "overview" : "Bir polis, ilişki sorunları ile uğraşırken bir suçluya Japonya'ya eşlik eden bir davaya ve terkedilmenin bir sonucu olarak ortaya çıkan muazzam değişime atandı. 1978 te çıkan filmin remake versiyonudur.",
     "release_date" : "2019-04-19",
     "adult" : false,
     "vote_average" : 0,
     "genre_ids" : [
     28,
     35
     ],
     "title" : "Büyük Ejderha",
     "video" : false,
     "vote_count" : 0,
     "original_language" : "cn"
     },
     */




}
