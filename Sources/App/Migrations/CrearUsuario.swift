//
//  File.swift
//  
//
//  Created by Andres Herrera on 1/27/21.
//

import Fluent

struct CreateUsers: Migration {
    func prepare(on database: Database) -> EventLoopFuture<Void> {
        database.schema(Usuario.schema)
            .field("id", .uuid, .identifier(auto: true))
            .field("username", .string, .required)
            .unique(on: "username")
            .field("password_hash", .string, .required)
            .field("nombres", .string, .required)
            .field("creado_el", .datetime, .required)
            .field("actualizado_el", .datetime, .required)
            .create()
    }
    
    func revert(on database: Database) -> EventLoopFuture<Void> {
        database.schema(Usuario.schema).delete()
    }
}
