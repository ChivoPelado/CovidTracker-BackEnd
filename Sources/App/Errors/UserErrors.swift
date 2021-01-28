//
//  File.swift
//  
//
//  Created by Andres Herrera on 1/27/21.
//

import Vapor

enum UserError {
  case usernameTaken
}

extension UserError: AbortError {
  var description: String {
    reason
  }

  var status: HTTPResponseStatus {
    switch self {
    case .usernameTaken: return .conflict
    }
  }

  var reason: String {
    switch self {
    case .usernameTaken: return "Nombre de usuario seleccionado ya existe. Por favor seleccione otro nombre"
    }
  }
}
