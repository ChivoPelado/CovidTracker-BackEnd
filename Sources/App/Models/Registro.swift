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
    struct Publica: Content {
        let fechaContagio: Date
        let id: UUID
        let latitud: Double
        let longitud: Double
        let creadoEl: Date?
        let actualizadoEl: Date?
    }
    
    static let schema = "registros"
    
    @ID(key: "id")
    var id: UUID?
    
    @Field(key: "fecha_contagio")
    var fechaContagio: Date
    
    @Field(key: "latitud")
    var latitud: Double
    
    @Field(key: "longitud")
    var longitud: Double
    
    @Parent(key: "usuario_id")
    var usuario: Usuario
    
    @Timestamp(key: "creado_el", on: .create)
    var creadoEl: Date?
    
    @Timestamp(key: "actualizado_el", on: .update)
    var actualizadoEl: Date?
    
    init() {}
    
    init(id: UUID? = nil, fechaContagio: Date, latitud: Double, longitud: Double, usuarioId: Usuario.IDValue, creadoEl: Date, actualizadoEl: Date) {
        self.id = id
        self.fechaContagio = fechaContagio
        self.latitud = latitud
        self.longitud = longitud
        self.$usuario.id = usuarioId
        self.creadoEl = creadoEl
        self.actualizadoEl = actualizadoEl
    }
}

extension Registro {
    func infoPublica() throws -> Publica {
        Publica(fechaContagio: fechaContagio, id: try requireID(),
               latitud: latitud,
               longitud: longitud,
               creadoEl: creadoEl,
               actualizadoEl: actualizadoEl)
    }
}
