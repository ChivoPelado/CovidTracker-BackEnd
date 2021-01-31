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

final class Geolocalizacion: Content, Model {
    static let schema = "geolocalizacion"
    
    @ID(key: "id")
    var id: UUID?
    
    @Field(key: "referencia")
    var referencia: String
    
    @Field(key: "latitud")
    var latitud: Double
    
    @Field(key: "longitud")
    var longitud: Double
    
    @Parent(key: "caso_id")
    var caso: Caso
    
    @Timestamp(key: "creado_el", on: .create)
    var creadoEl: Date?
    
    @Timestamp(key: "actualizado_el", on: .update)
    var actualizadoEl: Date?
    
    init() {}
    
    init(id: UUID? = nil, referencia: String, latitud: Double, longitud: Double, casoId: Caso.IDValue, creadoEl: Date, actualizadoEl: Date) {
        self.id = id
        self.referencia = referencia
        self.latitud = latitud
        self.longitud = longitud
        self.$caso.id = casoId
        self.creadoEl = creadoEl
        self.actualizadoEl = actualizadoEl
    }
}
