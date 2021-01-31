//
//  File.swift
//  
//
//  Created by Andres Herrera on 1/30/21.
//

import FluentSQLiteDriver
import Fluent
import Foundation
import Vapor

enum Diagnostico: String, Codable {
    case Confirmado, Sospecha
}

final class Caso: Content, Model {
    
    struct Publico: Content {
        let tipoCaso: Diagnostico
        let fechaInicio: Date
        let id: UUID
        let fechaFin: Date
        let creadoEl: Date?
        let actualizadoEl: Date?
        let geolocalizacion: [Geolocalizacion]
    }
    
    static let schema = "casos"
    
    @ID(key: "id")
    var id: UUID?
    
    @Enum(key: "tipo_caso")
    var tipoCaso: Diagnostico
    
    @Field(key: "fecha_inicio")
    var fechaInicio: Date
    
    @Field(key: "fecha_fin")
    var fechaFin: Date
    
    @Parent(key: "usuario_id")
    var usuario: Usuario
    
    @Children(for: \.$caso)
    var geolocalizacion: [Geolocalizacion]
    
    @Timestamp(key: "creado_el", on: .create)
    var creadoEl: Date?
    
    @Timestamp(key: "actualizado_el", on: .update)
    var actualizadoEl: Date?
    
    init() {}
    
    init(id: UUID? = nil, tipoCaso: Diagnostico, fechaInicio: Date, fechaFin: Date, usuarioId: Usuario.IDValue, creadoEl: Date, actualizadoEl: Date ) {
        self.id = id
        self.tipoCaso = tipoCaso
        self.fechaInicio = fechaInicio
        self.fechaFin = fechaFin
        self.$usuario.id = usuarioId
        self.creadoEl = creadoEl
        self.actualizadoEl = actualizadoEl
    }
}

extension Caso {
    func infoPublica() throws -> Publico {
        Publico(
               tipoCaso: tipoCaso,
               fechaInicio: fechaInicio,
               id: try requireID(),
               fechaFin: fechaFin,
               creadoEl: creadoEl,
               actualizadoEl: actualizadoEl,
               geolocalizacion: geolocalizacion)
    }
}
