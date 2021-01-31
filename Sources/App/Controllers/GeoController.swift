//
//  File.swift
//  
//
//  Created by Andres Herrera on 1/27/21.
//

import Vapor
import Fluent

struct NuevaGeolocalizacion: Content {
    let referencia: String
    let latitud: Double
    let longitud: Double
}

struct GeoController: RouteCollection {
    func boot(routes: RoutesBuilder) throws {
        //Acceso abierto
        let rutasRegistro = routes.grouped("geolocalizacion")
        rutasRegistro.get("publicos", use: obtenerGeolocalizacion)
        
        //Acceso restringido
        let protegidoConToken = rutasRegistro.grouped(Token.authenticator())
        protegidoConToken.post("nuevo", ":casoId", use: creaGeolocalizacion)
        protegidoConToken.put("modificar", ":id", use: actualizarGeolocalizacion)
        protegidoConToken.put("eliminar", ":id", use: eliminarGeolocalizacion)
    }
    
    fileprivate func obtenerGeolocalizacion(req: Request) throws -> EventLoopFuture<[Geolocalizacion]> {
        return Geolocalizacion.query(on: req.db)
            .all()
            .flatMapEachThrowing { $0 }
    }
    
    ///http://127.0.0.1:8080/geolocalizacion/nuevo/<CASO-ID>
    fileprivate func creaGeolocalizacion(req: Request) throws -> EventLoopFuture<Geolocalizacion> {
        guard let id = req.parameters.get("casoId", as: UUID.self) else {
            throw Abort(.badRequest)
        }
        let nuevaGeolocalizacion = try req.content.decode(NuevaGeolocalizacion.self)
        
        let registro = Geolocalizacion(
            referencia: nuevaGeolocalizacion.referencia,
            latitud: nuevaGeolocalizacion.latitud,
            longitud: nuevaGeolocalizacion.longitud,
            casoId: id,
            creadoEl: Date(),
            actualizadoEl: Date())
        return registro.save(on: req.db).map { registro }
    }
    
    ///http://127.0.0.1:8080/geolocalizacion/modificar/<ID>
    func actualizarGeolocalizacion(_ req: Request) throws -> EventLoopFuture<Geolocalizacion> {
        guard let id = req.parameters.get("id", as: UUID.self) else {
            throw Abort(.badRequest)
        }
        let registroActualizado = try req.content.decode(NuevaGeolocalizacion.self)
        return Geolocalizacion.find(id, on: req.db)
            .unwrap(or: Abort(.notFound))
            .flatMap { geo in
                geo.referencia = registroActualizado.referencia
                geo.latitud = registroActualizado.latitud
                geo.longitud = registroActualizado.longitud
                return geo.save(on: req.db).map {
                    geo
                }
            }
    }
    
    ///http://127.0.0.1:8080/geolocalizacion/eliminar/<ID>
    func eliminarGeolocalizacion(_ req: Request) throws -> EventLoopFuture<HTTPStatus> {
        guard let id = req.parameters.get("id", as: UUID.self) else {
            throw Abort(.badRequest)
        }
        return Geolocalizacion.find(id, on: req.db)
            .unwrap(or: Abort(.notFound))
            .flatMap { $0.delete(on: req.db) }
            .map{ .ok }
    }
}


