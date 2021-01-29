//
//  File.swift
//  
//
//  Created by Andres Herrera on 1/27/21.
//

import Fluent

struct CrearRegistro: Migration {
    func prepare(on database: Database) -> EventLoopFuture<Void> {
        database.schema("registros")
            .id()
            .field("fecha_contagio", .datetime, .required)
            .field("latitud", .double, .required)
            .field("longitud", .double, .required)
            .field("usuario_id", .uuid, .references("usuarios", "id"), .required)
            .field("creado_el", .datetime, .required)
            .field("actualizado_el", .datetime, .required)
            .create()
    }
    
    func revert(on database: Database) -> EventLoopFuture<Void> {
        database.schema("registros").delete()
    }
    
    
}
