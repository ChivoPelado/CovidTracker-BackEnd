//
//  File.swift
//  
//
//  Created by Andres Herrera on 1/27/21.
//

import Vapor
import Fluent

struct UserSignup: Content {
  let username: String
  let password: String
}

struct NewSession: Content {
  let token: String
  let user: Usuario.Publico
}

extension UserSignup: Validatable {
  static func validations(_ validations: inout Validations) {
    validations.add("username", as: String.self, is: !.empty)
    validations.add("password", as: String.self, is: .count(6...))
  }
}

struct UserController: RouteCollection {
  func boot(routes: RoutesBuilder) throws {
    let usersRoute = routes.grouped("users")
    usersRoute.post("signup", use: create)
    
    let tokenProtected = usersRoute.grouped(Token.authenticator())
    tokenProtected.get("me", use: getMyOwnUser)
    
    let passwordProtected = usersRoute.grouped(Usuario.authenticator())
    passwordProtected.post("login", use: login)
  }

  fileprivate func create(req: Request) throws -> EventLoopFuture<NewSession> {
    try UserSignup.validate(content: req)
    let userSignup = try req.content.decode(UserSignup.self)
    let user = try Usuario.crear(desde: userSignup)
    var token: Token!

    return checkIfUserExists(userSignup.username, req: req).flatMap { exists in
      guard !exists else {
        return req.eventLoop.future(error: UserError.usernameTaken)
      }

      return user.save(on: req.db)
    }.flatMap {
      guard let newToken = try? user.crearToken(source: .signup) else {
        return req.eventLoop.future(error: Abort(.internalServerError))
      }
      token = newToken
      return token.save(on: req.db)
    }.flatMapThrowing {
      NewSession(token: token.value, user: try user.infoPublica())
    }
  }

  fileprivate func login(req: Request) throws -> EventLoopFuture<NewSession> {
    let user = try req.auth.require(Usuario.self)
    let token = try user.crearToken(source: .login)

    return token.save(on: req.db).flatMapThrowing {
      NewSession(token: token.value, user: try user.infoPublica())
    }
  }

  func getMyOwnUser(req: Request) throws -> Usuario.Publico {
    try req.auth.require(Usuario.self).infoPublica()
  }

  private func checkIfUserExists(_ username: String, req: Request) -> EventLoopFuture<Bool> {
    Usuario.query(on: req.db)
      .filter(\.$username == username)
      .first()
      .map { $0 != nil }
  }
}
