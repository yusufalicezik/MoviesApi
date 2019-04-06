//
//  SecondViewController.swift
//  MyMovies
//
//  Created by Yusuf ali cezik on 3.04.2019.
//  Copyright © 2019 Yusuf ali cezik. All rights reserved.
//

import UIKit
import SwiftyJSON
import Alamofire


var globalID:String?


class MovieDetailsVC: UIViewController {
    
    
    let BASE_URL="https://api.themoviedb.org/3"
    let API_KEY:String="ae32fbb3535e8e640aff557640da5021"
    let LANGUAGE="tr-TR"
    let TOP_RATED_URL="/movie/"
    var parameters:[String:String]?
    var params:[String:String]?
    let PHOTO_URL="https://image.tmdb.org/t/p/w500"
        //https://api.themoviedb.org/3/movie/550?api_key=ae32fbb3535e8e640aff557640da5021&language=tr-TR
    
    @IBOutlet weak var movieTitleLabel: UILabel!
    @IBOutlet weak var movieTypeLabel: UILabel!
    @IBOutlet weak var movieImageLabel: UIImageView!
    @IBOutlet weak var movieOverViewTextLabel: UITextView!
    @IBOutlet weak var movieReleaseDateLabel: UILabel!
    
    
    var selectedID:String?
    
    var selectedMovie=Movie()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        selectedID=globalID!
        parameters=["api_key":API_KEY, "language":LANGUAGE] as? [String : String]
     
        
        movieDetayBilgileriniGetir()
    }
    
    func movieDetayBilgileriniGetir(){
        Alamofire.request(BASE_URL+TOP_RATED_URL+selectedID!, method: .get, parameters:self.parameters).responseJSON {
            response in if response.result.isSuccess {
               let gelenVeri:JSON=JSON(response.result.value!)
                print(gelenVeri)
               self.verileriParcala(json:gelenVeri)
            }else {
                print(response.result.description)
                 print("error \(String(describing: response.result.error))")
               
            }
        }
    }
    
    func verileriParcala(json:JSON){
       
            let title=json["title"].stringValue
            let image=json["poster_path"].stringValue
            let overView=json["overview"].stringValue
            let releaseDate=json["release_date"].stringValue
        var names=""
        if json["genres"].count > 0 {
        for i in 0...json["genres"].count-1{
            if i == 0{
                names+=json["genres"][i]["name"].stringValue
            }else{
                names+=", "+json["genres"][i]["name"].stringValue
            }
            
        }
        }
        
        selectedMovie.title=title
        selectedMovie.genresName=names
        selectedMovie.image=image
        selectedMovie.id=selectedID
        selectedMovie.overView=overView
        selectedMovie.releaseDate=releaseDate
        
        verileriEkranaYaz()
    }
    
    func verileriEkranaYaz(){
        if selectedMovie.image != nil {
            Alamofire.request(PHOTO_URL+selectedMovie.image!).responseImage {
                response in
                if let image=response.result.value {
                    self.movieImageLabel.image=image
                }
            }
        }
        
        
        if selectedMovie.title != nil{
            movieTitleLabel.text=selectedMovie.title
            movieTypeLabel.text="Tür : "+selectedMovie.genresName!
            movieReleaseDateLabel.text="Çıkış Tarihi : "+selectedMovie.releaseDate!
            movieOverViewTextLabel.text=selectedMovie.overView
            
        }
    }

}
/*
 {
 "id" : 278,
 "video" : false,
 "popularity" : 27.082999999999998,
 "backdrop_path" : "\/j9XKiZrVeViAixVRzCta7h1VU9W.jpg",
 "production_companies" : [
 {
 "origin_country" : "US",
 "logo_path" : "\/7znWcbDd4PcJzJUlJxYqAlPPykp.png",
 "name" : "Castle Rock Entertainment",
 "id" : 97
 },
 {
 "origin_country" : "US",
 "logo_path" : "\/ky0xOc5OrhzkZ1N6KyUxacfQsCk.png",
 "name" : "Warner Bros. Pictures",
 "id" : 174
 }
 ],
 "vote_average" : 8.6999999999999993,
 "production_countries" : [
 {
 "iso_3166_1" : "US",
 "name" : "United States of America"
 }
 ],
 "release_date" : "1994-09-23",
 "status" : "Released",
 "homepage" : "",
 "poster_path" : "\/zGINvGjdlO6TJRu9wESQvWlOKVT.jpg",
 "spoken_languages" : [
 {
 "iso_639_1" : "en",
 "name" : "English"
 }
 ],
 "belongs_to_collection" : null,
 "tagline" : "Korku seni esir tutabilir. Umut seni özgür bırakabilir.",
 "runtime" : 142,
 "title" : "Esaretin Bedeli",
 "vote_count" : 12624,
 "original_language" : "en",
 "overview" : "Genç ve başarılı bir banker olan Andy Dufresne (Tim Robbins), karısını ve onun sevgilisini öldürmek suçundan ömür boyu hapse mahkum edilir ve Shawshank hapishanesine gönderilir. İşkence, tecavüz, dayak dahil her türlü kötü koşulun hüküm sürdüğü hapishane koşullarında, Andy'nin hayata bağlı ve her daim iyi bir şeyler bulma çabası içindeki hali, çevresindeki herkesi çok etkileyecektir. Bir süre sonra parmaklıkların arkasında bile özgür bir yaşam olabileceğine bütün mahkumları inandırır.Bu mahkumlardan biri olan Ellis Boyd \"Red\" (Morgan Freeman) ve Andy, unutulmaz bir dostluk kurarak hapishaneyi bambaşka bir yer haline getirirler.",
 "adult" : false,
 "revenue" : 28341469,
 "genres" : [
 {
 "id" : 18,
 "name" : "Dram"
 },
 {
 "id" : 80,
 "name" : "Suç"
 }
 ],
 "imdb_id" : "tt0111161",
 "budget" : 25000000,
 "original_title" : "The Shawshank Redemption"
 }

 
 */
