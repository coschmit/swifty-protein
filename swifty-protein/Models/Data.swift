//
//  Data.swift
//  swifty-protein
//
//  Created by Colin Schmitt on 01/03/2021.
//

import SwiftUI

class ProteinData {
    var proteinsArr = [String]()
    var filteredArr = [String]()

    var pdbFile : String?

    func parseProteins(){
        let filename = Bundle.main.path(forResource: "ligands", ofType: "txt")
        do {
            let data = try NSString(contentsOfFile: filename!, encoding: String.Encoding.utf8.rawValue) as String
            
            let splitedData = data.split(separator: "\n")
            
            for key in splitedData {
                proteinsArr.append(String(key))
            }
        } catch let error as NSError{
            print("Can not read ligands.txt : \(error)")
        }
    }
    
    func downloadProteins(name:String, completionHandler: @escaping (String?)-> Void ){
        let index = name.index(name.startIndex, offsetBy: 0)
        let dir = name[index]
        
        guard let url = URL(string: "https://files.rcsb.org/ligands/\(dir)/\(name)/\(name)_ideal.pdb") else { return }
        
        let task = URLSession.shared.downloadTask(with: url){ data,response,error in
            DispatchQueue.main.async {
                if let data = data {
                    if let pdbfile : String = try? String(contentsOf: data){
                        completionHandler(pdbfile)
                    }
                }
            }
            
        }
        task.resume()
    }
    
    
}

