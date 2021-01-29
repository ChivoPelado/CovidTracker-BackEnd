//
//  File.swift
//  
//
//  Created by Andres Herrera on 1/27/21.
//

import Vapor
import Fluent

struct RegistroUsuario: Content {
    let username: String
    let password: String
    let nombres: String
}

struct NuevaSesion: Content {
    let token: String
    let usuario: Usuario.Publico
}

extension RegistroUsuario: Validatable {
    static func validations(_ validations: inout Validations) {
        validations.add("username", as: String.self, is: !.empty)
        validations.add("password", as: String.self, is: .count(6...))
    }
}

struct UsuarioController: RouteCollection {
    func boot(routes: RoutesBuilder) throws {
        let usersRoute = routes.grouped("usuarios")
        usersRoute.post("registro", use: registrar)
        
        let tokenProtected = usersRoute.grouped(Token.authenticator())
        tokenProtected.get("yo", use: obtenerMiInformacion)
        
        let passwordProtected = usersRoute.grouped(Usuario.authenticator())
        passwordProtected.post("autenticar", use: autenticar)
    }
    
    fileprivate func registrar(req: Request) throws -> EventLoopFuture<NuevaSesion> {
        try RegistroUsuario.validate(content: req)
        let userSignup = try req.content.decode(RegistroUsuario.self)
        let usuario = try Usuario.crear(desde: userSignup)
        var token: Token!
        
        return verificaSiUsuarioExiste(userSignup.username, req: req).flatMap { existe in
            guard !existe else {
                return req.eventLoop.future(error: UserError.usernameTaken)
            }
            
            return usuario.save(on: req.db)
        }.flatMap {
            guard let nuevoToken = try? usuario.crearToken(source: .signup) else {
                return req.eventLoop.future(error: Abort(.internalServerError))
            }
            token = nuevoToken
            return token.save(on: req.db)
        }.flatMapThrowing {
            NuevaSesion(token: token.value, usuario: try usuario.infoPublica())
        }
    }
    
    fileprivate func autenticar(req: Request) throws -> EventLoopFuture<NuevaSesion> {
        let usuario = try req.auth.require(Usuario.self)
        let token = try usuario.crearToken(source: .login)
        
        return token.save(on: req.db).flatMapThrowing {
            NuevaSesion(token: token.value, usuario: try usuario.infoPublica())
        }
    }
    
    func obtenerMiInformacion(req: Request) throws -> Usuario.Publico {
        try req.auth.require(Usuario.self).infoPublica()
    }
    
    private func verificaSiUsuarioExiste(_ username: String, req: Request) -> EventLoopFuture<Bool> {
        Usuario.query(on: req.db)
            .filter(\.$username == username)
            .first()
            .map { $0 != nil }
    }
}
