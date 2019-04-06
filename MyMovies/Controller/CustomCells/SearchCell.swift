//
//  SearchCell.swift
//  MyMovies
//
//  Created by Yusuf ali cezik on 4.04.2019.
//  Copyright © 2019 Yusuf ali cezik. All rights reserved.
//

import UIKit
import SwiftyJSON
import Alamofire

class SearchCell: UITableViewCell,UICollectionViewDelegate,UICollectionViewDataSource {
   
    //https://api.themoviedb.org/3/genre/movie/list?api_key=ae32fbb3535e8e640aff557640da5021&language=en-US
    let BASE_URL="https://api.themoviedb.org/3"
    let API_KEY:String="ae32fbb3535e8e640aff557640da5021"
    let LANGUAGE="tr-TR"
    let SEARCH_URL="/genre/movie/list"
    var parameters:[String:String]?
    
    
    
    
    
    
    @IBOutlet weak var movieImage: UIImageView!
    @IBOutlet weak var movieSentenceLabel: UITextView!
    @IBOutlet weak var movieTypesCollectionView: UICollectionView!
    @IBOutlet weak var movieTitleLabel: UILabel!
    @IBOutlet weak var movieTypeIds: UILabel!
    
    var movieTypeArray=[String]()
    var movieTypeArrayStrings=[String]()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
       // movieTypeIds.isHidden=true
        movieSentenceLabel.isEditable=false
        movieTypesCollectionView.delegate=self
        movieTypesCollectionView.dataSource=self
        
        
        
        
        
    }
    


    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        parameters=["api_key":API_KEY, "language":LANGUAGE]
        movieTypeParcala()
     
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return movieTypeArrayStrings.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        
        let cell=collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for:indexPath) as! SearchGenresCollectionViewCell
        cell.movieTypeLabel.text=movieTypeArrayStrings[indexPath.row]
       
        return cell
    }
    
    func movieTypeParcala(){
        movieTypeArray.removeAll(keepingCapacity: false)
        movieTypeArray=movieTypeIds.text!.components(separatedBy: ",")
        movieTypeIds.text=""
        print("ff",movieTypeArray)
        
        
        filmTurleriniGetir()
        
        
        
    }
    
    func filmTurleriniGetir(){
        
        Alamofire.request(BASE_URL+SEARCH_URL, method: .get, parameters:self.parameters).responseJSON {
            response in if response.result.isSuccess {
                print("basarili")
                
                let gelenVeri:JSON=JSON(response.result.value!)
                print(gelenVeri["genres"])
                self.verileriParcala(json:gelenVeri)
            }else {
                print("error \(String(describing: response.result.error))")
            }
        }
        
       
    }
    
    func verileriParcala(json:JSON){
        movieTypeArrayStrings.removeAll(keepingCapacity: false)
        //result ın içinde gezmemiz gerek
        
        if json["genres"].count > 0 {
        for i in 0...json["genres"].count-1{
         
            for j in 0...movieTypeArray.count-1{
                if movieTypeArray[j] == json["genres"][i]["id"].stringValue{
                    movieTypeArrayStrings.append(json["genres"][i]["name"].stringValue)
                }
            }
            
            
        }
        
        }

        
         self.movieTypesCollectionView.reloadData()
    }
    

}
