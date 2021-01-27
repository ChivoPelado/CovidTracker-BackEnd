//
//  File.swift
//  
//
//  Created by Andres Herrera on 1/27/21.
//

import FluentSQLiteDriver
import Fluent
import Foundation
import Vapor

final class Registro: Content, Model {
    
    static let schema = "registro"
    
    @ID
    var id: UUID?
    
    @Field(key: "nombre")
    var nombre: String
    
    @Field(key: "direccion")
    var direccion: String
    
    @Field(key: "fechaContagio")
    var fechaContagio: Date
    
    @Field(key: "latitud")
    var latitud: Double
    
    @Field(key: "longitud")
    var longitud: Double
    
    init() {}
    
    init(id: UUID?, nombre: String, direccion: String, fechaContagio: Date, latitud: Double, longitud: Double) {
        self.id = id
        self.nombre = nombre
        self.direccion = direccion
        self.fechaContagio = fechaContagio
        self.latitud = latitud
        self.longitud = longitud
    }
}
