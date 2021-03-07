//
//  AtomInfo.swift
//  swifty-protein
//
//  Created by Colin Schmitt on 05/03/2021.
//

import Foundation

struct Elements: Decodable{
    let elements: [AtomInfo]?
}

struct AtomInfo : Decodable{
    let name: String?
    let atomic_mass: Double?
    let boil : Double?
    let category: String?
    let density: Double?
    let discovered_by : String?
    let melt: Double?
    let number: Int?
    let period : Int?
    let phase: String?
    let summary: String?
    let symbol: String?
    let molar_heat: Double?
}

class getAtomInfo {
    
    func getInfo() -> Elements? {
        var jsonResult:Elements? = nil
        if let path = Bundle.main.path(forResource: "PeriodicTableJSON", ofType: "json") {
            do {
                let data = try Data(contentsOf: URL(fileURLWithPath: path), options: .mappedIfSafe)
                jsonResult = try JSONDecoder().decode(Elements.self, from: data) as Elements?
                return jsonResult
            } catch {
                print("error vse dela")
            }
        }
        return jsonResult
    }
    
}
