//
//  File.swift
//  
//
//  Created by Andres Herrera on 1/30/21.
//

import Vapor
import Fluent

struct NuevoCaso: Content {
    let tipoCaso: Diagnostico
    let fechaInicio: Date
    let fechaFin: Date
    let usuarioId: UUID
}

struct CasoController: RouteCollection {
    func boot(routes: RoutesBuilder) throws {
        //Acceso Abierto
        let rutasRegistro = routes.grouped("casos")
        rutasRegistro.get("registrados", use: obtenerCasos)
        
        //Acceso restringido
        let protegidoConToken = rutasRegistro.grouped(Token.authenticator())
        protegidoConToken.post("nuevo", use: creaCaso)
        protegidoConToken.get("propio", use: obtenerCaso)
        protegidoConToken.put("modificar", ":id", use: actualizarCaso)
        protegidoConToken.put("eliminar", ":id", use: eliminarCaso)
    }
    
    ///http://127.0.0.1:8080/casos/registrados
    fileprivate func obtenerCasos(req: Request) throws -> EventLoopFuture<[Caso.Publico]> {
        return Caso.query(on: req.db)
            .with(\.$geolocalizacion)
            .all()
            .flatMapEachThrowing {
                try $0.infoPublica()
            }
    }
    
    ///http://127.0.0.1:8080/casos/nuevo
    fileprivate func creaCaso(req: Request) throws -> EventLoopFuture<Caso> {
        let nuevoCaso = try req.content.decode(NuevoCaso.self)
        let caso = Caso(tipoCaso: nuevoCaso.tipoCaso,
                        fechaInicio: nuevoCaso.fechaInicio,
                        fechaFin: nuevoCaso.fechaFin,
                        usuarioId: nuevoCaso.usuarioId,
                        creadoEl: Date(),
                        actualizadoEl: Date())
        return caso.save(on: req.db).map { caso }
    }
    
    ///http://127.0.0.1:8080/casos/propio
    fileprivate func obtenerCaso(req: Request) throws -> EventLoopFuture<[Caso]> {
        let usuario = try req.auth.require(Usuario.self)
        guard let usuarioId = usuario.id else {
            throw Abort(.badRequest)
        }
        return Usuario.find(usuarioId, on: req.db)
            .unwrap(or: Abort(.notFound))
            .flatMap {
                $0.$caso.query(on: req.db)
                    .with(\.$geolocalizacion)
                    .all()
            }
    }
    
    ///http://127.0.0.1:8080/casos/modificar/<CASO-ID>
    func actualizarCaso(_ req: Request) throws -> EventLoopFuture<Caso> {
        guard let id = req.parameters.get("id", as: UUID.self) else {
            throw Abort(.badRequest)
        }
        let casoActualizado = try req.content.decode(NuevoCaso.self)
        return Caso.find(id, on: req.db)
            .unwrap(or: Abort(.notFound))
            .flatMap { caso in
                caso.tipoCaso = casoActualizado.tipoCaso
                caso.fechaInicio = casoActualizado.fechaInicio
                caso.fechaFin = casoActualizado.fechaFin
                return caso.save(on: req.db).map {
                    caso
                }
            }
    }
    
    ///http://127.0.0.1:8080/casos/eliminar/<CASO-ID>
    func eliminarCaso(_ req: Request) throws -> EventLoopFuture<HTTPStatus> {
        guard let id = req.parameters.get("id", as: UUID.self) else {
            throw Abort(.badRequest)
        }
        return Caso.find(id, on: req.db)
            .unwrap(or: Abort(.notFound))
            .flatMap { $0.delete(on: req.db) }
            .map{ .ok }
    }
}
