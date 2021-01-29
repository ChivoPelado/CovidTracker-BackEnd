//
//  File.swift
//  
//
//  Created by Andres Herrera on 1/27/21.
//

import Fluent
import Vapor

final class Usuario: Model {
    struct Publico: Content {
        let username: String
        let nombres: String
        let id: UUID
        let creadoEl: Date?
        let actualizadoEl: Date?
    }
    
    static let schema = "usuarios"
    
    @ID(key: "id")
    var id: UUID?
    
    @Field(key: "username")
    var username: String
    
    @Field(key: "password_hash")
    var passwordHash: String
    
    @Field(key: "nombres")
    var nombres: String
    
    @Children(for: \.$usuario)
    var registro: [Registro]
    
    @Timestamp(key: "creado_el", on: .create)
    var creadoEl: Date?
    
    @Timestamp(key: "actualizado_el", on: .update)
    var actualizadoEl: Date?
    
    init() {}
    
    init(id: UUID? = nil, username: String, passwordHash: String, nombres: String) {
        self.id = id
        self.username = username
        self.passwordHash = passwordHash
        self.nombres = nombres
    }
}

extension Usuario {
    static func crear(desde userSignup: RegistroUsuario) throws -> Usuario {
        Usuario(username: userSignup.username, passwordHash: try Bcrypt.hash(userSignup.password), nombres: userSignup.nombres)
    }
    
    func crearToken(source: SessionSource) throws -> Token {
        let calendar = Calendar(identifier: .gregorian)
        let expiryDate = calendar.date(byAdding: .year, value: 1, to: Date())
        return try Token(userId: requireID(),
                         token: [UInt8].random(count: 16).base64, source: source, expiresAt: expiryDate)
    }
    
    func infoPublica() throws -> Publico {
        Publico(username: username,
                nombres: nombres,
                //Genera un error en el caso de que el cliente no este en la base de datos
               id: try requireID(),
               creadoEl: creadoEl,
               actualizadoEl: actualizadoEl)
    }
}

extension Usuario: ModelAuthenticatable {
    static let usernameKey = \Usuario.$username
    static let passwordHashKey = \Usuario.$passwordHash
    
    func verify(password: String) throws -> Bool {
        try Bcrypt.verify(password, created: self.passwordHash)
    }
}

