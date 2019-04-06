//
//  TopRatedCell.swift
//  MyMovies
//
//  Created by Yusuf ali cezik on 3.04.2019.
//  Copyright © 2019 Yusuf ali cezik. All rights reserved.
//

import UIKit
import CoreData
import CoreLocation

class TopRatedCell: UITableViewCell {

    @IBOutlet weak var movieNameLabel: UILabel!
    @IBOutlet weak var movieImage: UIImageView!
    @IBOutlet weak var movieRateLabel: UILabel!
    @IBOutlet weak var movieIDLabel: UILabel!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        movieIDLabel.isHidden=true
        
        
        
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

       
    }

    @IBAction func favButtonClicked(_ sender: Any) {
        
        
        //context ve delegate e erişim için
        let delegate=UIApplication.shared.delegate as! AppDelegate
        let context=delegate.persistentContainer.viewContext
        ///
        if !varMi(){
            //eğer veritabanımda kayıtlı değilse bu film idsi, bunu kaydet.
            let yeniObje=NSEntityDescription.insertNewObject(forEntityName: "Movies", into: context)
            yeniObje.setValue(movieIDLabel.text, forKey: "id")
            do {
                try context.save()
                print("kaydedildi")
                
                delegate.alerOlustur("Favorilerinize Eklendi", "")
                //ekleme yaptığımıza dair bildirim göndermesi için(bi önceki aktiviteye)
                NotificationCenter.default.post(name:NSNotification.Name(rawValue: "newMovie"), object: nil)
           }catch{
                print("kaydetme hatası")
            }
            
        }else{
            delegate.alerOlustur("Bu film zaten favori listenizde var", "")
            
            
        }
    }
    
    func varMi()->Bool{
        
        var donecek:Bool=false
        
        let delegate=UIApplication.shared.delegate as! AppDelegate
        let context=delegate.persistentContainer.viewContext
        
        
        let fetchRequest=NSFetchRequest<NSFetchRequestResult>(entityName: "Movies")
        fetchRequest.predicate=NSPredicate(format: "id=%@", movieIDLabel.text!)
        fetchRequest.returnsObjectsAsFaults=false
        
        do {
            let results=try context.fetch(fetchRequest)
            
            if results.count>0{
                
                for result in results as! [NSManagedObject]{
                    if result.value(forKey: "id") as? String==movieIDLabel.text{
                        donecek=true
                    }
                }
            }
        }catch{
            
        }
        
        
        return donecek
    }
}
