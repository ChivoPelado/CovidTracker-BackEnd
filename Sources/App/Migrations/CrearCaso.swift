//
//  File.swift
//  
//
//  Created by Andres Herrera on 1/30/21.
//

import Fluent

struct CrearCaso: Migration {
    func prepare(on database: Database) -> EventLoopFuture<Void> {
        database.enum("tipo_caso")
            .case("Confirmado")
            .case("Sospecha")
            .create()
            .flatMap { tipoCaso in
                return  database.schema(Caso.schema)
                    .id()
                    .field("tipo_caso", tipoCaso, .required)
                    .field("fecha_inicio", .datetime, .required)
                    .field("fecha_fin", .datetime, .required)
                    .field("usuario_id", .uuid, .references("usuarios", "id"), .required)
                    .field("creado_el", .datetime, .required)
                    .field("actualizado_el", .datetime, .required)
                    .create()
            }
    }
    
    func revert(on database: Database) -> EventLoopFuture<Void> {
        database.schema(Caso.schema).delete().flatMap {
            return database.enum("tipo_caso").delete()
        }
    }
    
    
}
