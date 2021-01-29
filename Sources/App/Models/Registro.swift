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
        let usuario: Usuario.Publico
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
//    static func crear(desde nuevoRegistro: NuevoRegistro) throws -> Registro {
//        Registro(fechaContagio: nuevoRegistro.fechaContagio, latitud: nuevoRegistro.latitud, longitud: nuevoRegistro.longitud, usuarioId:  )
//       // Usuario(username: userSignup.username, passwordHash: try Bcrypt.hash(userSignup.password), nombres: userSignup.nombres)
//    }
    func infoPublica() throws -> Publica {
        Publica(fechaContagio: fechaContagio, id: try requireID(),
               latitud: latitud,
               longitud: longitud,
               usuario: try usuario.infoPublica(),
               creadoEl: creadoEl,
               actualizadoEl: actualizadoEl)
    }
}
