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
        let rutasRegistro = routes.grouped("registro")
        rutasRegistro.get("publicos", use: obtenerRegistros)
        
        let protegidoConToken = rutasRegistro.grouped(Token.authenticator())
        protegidoConToken.post("nuevo", use: creaRegistro)
        protegidoConToken.get("actual", use: obtenerRegistro)
        protegidoConToken.put("modificar", ":id", use: actualizarRegistro)
        protegidoConToken.put("eliminar", ":id", use: eliminarRegistro)
    }
    fileprivate func obtenerRegistros(req: Request) throws -> EventLoopFuture<[Registro.Publica]> {
        return Registro.query(on: req.db)
            .all()
            .flatMapEachThrowing {
                try $0.infoPublica()
            }
    }
    
    fileprivate func creaRegistro(req: Request) throws -> EventLoopFuture<Registro> {
        
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
    
    fileprivate func obtenerRegistro(req: Request) throws -> EventLoopFuture<[Registro]> {
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
    func actualizarRegistro(_ req: Request) throws
    -> EventLoopFuture<Registro> {
        
        guard let id = req.parameters.get("id", as: UUID.self) else {
            throw Abort(.badRequest)
        }
        
        let registroActualizado = try req.content.decode(NuevoRegistro.self)
        
        return Registro.find(id, on: req.db)
            .unwrap(or: Abort(.notFound))
            .flatMap { registro in
                registro.fechaContagio = registroActualizado.fechaContagio
                registro.latitud = registroActualizado.latitud
                registro.longitud = registroActualizado.longitud
                registro.actualizadoEl = Date()
                
                return registro.save(on: req.db).map {
                    registro
                }
            }
    }
    func eliminarRegistro(_ req: Request) throws
    -> EventLoopFuture<HTTPStatus> {
        
        guard let id = req.parameters.get("id", as: UUID.self) else {
            throw Abort(.badRequest)
        }
        
        return Registro.find(id, on: req.db)
            .unwrap(or: Abort(.notFound))
            .flatMap { $0.delete(on: req.db) }
            .map{ .ok }
    }
}


