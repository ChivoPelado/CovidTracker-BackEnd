//
//  File.swift
//  
//
//  Created by Andres Herrera on 1/27/21.
//

import Fluent

struct CrearRegistro: Migration {
    func prepare(on database: Database) -> EventLoopFuture<Void> {
        database.schema("registro")
            .id()
            .field("fechaContagio", .datetime, .required)
            .field("latitud", .double, .required)
            .field("longitud", .double, .required)
            .create()
    }
    
    func revert(on database: Database) -> EventLoopFuture<Void> {
        database.schema("registro").delete()
    }
    
    
}
