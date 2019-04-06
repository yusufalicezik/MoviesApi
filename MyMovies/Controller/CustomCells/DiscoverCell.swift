//
//  DiscoverCell.swift
//  MyMovies
//
//  Created by Yusuf ali cezik on 5.04.2019.
//  Copyright © 2019 Yusuf ali cezik. All rights reserved.
//

import UIKit
import AlamofireImage
import Alamofire
import SwiftyJSON
var g=false
var year:Int=0
class DiscoverCell: UITableViewCell,UICollectionViewDelegate,UICollectionViewDataSource{

    
    let BASE_URL="https://api.themoviedb.org/3"
    let API_KEY:String="ae32fbb3535e8e640aff557640da5021"
    let LANGUAGE="tr-TR"
    let DISCOVER_URL="/discover/movie"
    var parameters:[String:Any]?
    var genreIdArray=[String]()
    var genreNameArray=[String]()
    let PHOTO_URL="https://image.tmdb.org/t/p/w500"
    //with_genres
    
    var secilenId:String?
   
    
    @IBOutlet weak var label: UILabel!
    @IBOutlet weak var categoryNameLabel: UILabel!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var categoryIDLabel: UILabel!
    var delegate: CustomCellDelegate?
    
    //segment 2 olduğunda buranın global değişkenini değiştirebiliriz.
    //sorgulama yaparken primary_release_year e 2019 vs eklenir
    
    var movieArray=[Movie]()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        categoryIDLabel.isHidden=true
        collectionView.delegate=self
        collectionView.dataSource=self
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        
       label.layer.borderWidth = 0
       label.layer.masksToBounds = false
       
       label.layer.cornerRadius = label.frame.width/25
       label.clipsToBounds = true

        if categoryIDLabel.text != nil && categoryIDLabel.text != "" && categoryIDLabel.text != " "{
            parameters=["api_key":API_KEY, "language":LANGUAGE, "with_genres":categoryIDLabel.text!,"primary_release_year":year]
            filmleriCek()
        }
        
        // Configure the view for the selected state
    }

    func filmleriCek(){
        Alamofire.request(BASE_URL+DISCOVER_URL, method: .get, parameters:self.parameters).responseJSON {
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
            let image=json["results"][i]["backdrop_path"].stringValue
            let id=json["results"][i]["id"].stringValue
            
            let movie=Movie()
            movie.id=id
            movie.title=title
            movie.image=image
            
            
            
            movieArray.append(movie)
        }
        
        collectionView.reloadData()
        }
    }
    
    @IBAction func allButonClicked(_ sender: Any) {
        
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return movieArray.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell=collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for:indexPath) as! DiscoverFilmCollectionCell
        
        cell.movieNameLabel.text=movieArray[indexPath.row].title
       
        cell.movieImage.layer.borderWidth = 0
        cell.movieImage.layer.masksToBounds = false
        cell.movieImage.layer.borderColor = UIColor.black.cgColor
        cell.movieImage.layer.cornerRadius = cell.movieImage.frame.width/2
        cell.movieImage.clipsToBounds = true
        
        Alamofire.request(PHOTO_URL+movieArray[indexPath.row].image!).responseImage {
            response in
            if let image=response.result.value {
                cell.movieImage.image=image
            }
        }
        
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        print("tiklandi")
        secilenId=movieArray[indexPath.row].id
        
        globalID=secilenId
    
        // performSegue(withIdentifier: "toDetailsVC", sender: nil)
        g=false
         NotificationCenter.default.post(name: NSNotification.Name(rawValue: "goto"), object: nil)
        
      delegate?.didTapAnyButton("asd")
        
    }
 
    
    
    
    
    
}



/*
 
 "results": [
 {
 "vote_count": 3357,
 "id": 299537,
 "video": false,
 "vote_average": 7.2,
 "title": "Kaptan Marvel",
 "popularity": 358.609,
 "poster_path": "/AtsgWhDnHTq68L0lLsUrCnM7TjG.jpg",
 "original_language": "en",
 "original_title": "Captain Marvel",
 "genre_ids": [
 28,
 12,
 878
 ],
 "backdrop_path": "/w2PMyoyLU22YvrGK3smVM9fW1jj.jpg",
 "adult": false,
 "overview": "Carol Danvers (Brie Larson) sakin ve sıradan bir hayat yaşayan bir kadındır. Ancak bu değişmek üzeredir. Günün birinde Kree teknolojisini içeren bir patlama sonucu özel güçler edinir. Transformasyon yeteneği kazanan karakter kısa sürede güçlerini iyilik için kullanmaya karar vererek Kaptan Marvel adını alır. O artık adaleti sağlamak ve güçsüzleri korumak için çalışacaktır.",
 "release_date": "2019-03-06"
 },
 
 
 */
