//
//  File.swift
//  
//
//  Created by Andres Herrera on 1/28/21.
//

import Fluent
import Vapor

struct CrearPivoteUsuarioRegistroMigration: Migration {
    func prepare(on database: Database) -> EventLoopFuture<Void> {
        database.schema(PivoteUsuarioRegistro.schema)
            .field("id", .uuid, .identifier(auto: true))
            .field("usuario_id", .uuid, .references("usuarios", "id"))
            .field("registro_id", .uuid, .references("registros", "id"))
            .unique(on: "usuario_id", "registro_id")
            .create()
    }
    
    func revert(on database: Database) -> EventLoopFuture<Void> {
        database.schema(PivoteUsuarioRegistro.schema).delete()
    }
}
