//
//  File.swift
//  
//
//  Created by Andres Herrera on 1/28/21.
//

import Fluent
import Vapor

final class PivoteUsuarioRegistro: Model {
  static let schema = "usuario_registro"
  
  @ID(key: "id")
  var id: UUID?
  
  @Parent(key: "registro_id")
  var registro: Registro
  
  @Parent(key: "usuario_id")
  var usuario: Usuario
  
  init() {}
    init(id: UUID?, registroId:Registro.IDValue, usuarioId: Usuario.IDValue) {
    self.id = id
    self.$registro.id = registroId
    self.$usuario.id = usuarioId
  }
}
