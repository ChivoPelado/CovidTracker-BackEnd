//
//  File.swift
//  
//
//  Created by Andres Herrera on 1/27/21.
//

import Vapor
import Fluent

struct NuevoRegistro: Content {
    let fechaContagio: Date
    let latitud: Double
    let longitud: Double
    let usuarioId: UUID
}

struct RegistroController: RouteCollection {
    func boot(routes: RoutesBuilder) throws {
        let dinnersRoute = routes.grouped("registro")
        
        let tokenProtected = dinnersRoute.grouped(Token.authenticator())
        
        tokenProtected.post("nuevo", use: create)
        tokenProtected.get("actual", use: getDinner)
   
    }
    
    fileprivate func create(req: Request) throws -> EventLoopFuture<Registro> {
        let usuario = try req.auth.require(Usuario.self)
        let nuevoRegistro = try req.content.decode(NuevoRegistro.self)
        let registro = Registro(
            fechaContagio: nuevoRegistro.fechaContagio,
            latitud: nuevoRegistro.latitud,
            longitud: nuevoRegistro.longitud,
            usuarioId: nuevoRegistro.usuarioId,
            creadoEl: Date(),
            actualizadoEl: Date())
        
        return registro.save(on: req.db).map { registro }
    }
    
    fileprivate func getDinner(req: Request) throws -> EventLoopFuture<[Registro]> {
        let usuario = try req.auth.require(Usuario.self)
        guard let usuarioId = usuario.id else {
            throw Abort(.badRequest)
        }
        return Usuario.find(usuarioId, on: req.db)
            .unwrap(or: Abort(.notFound))
            .flatMap {
                $0.$registro.get(on: req.db)
            }
    }
}

