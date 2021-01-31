import Vapor
import Fluent

func routes(_ app: Application) throws {    
    try app.register(collection: UsuarioController())
    try app.register(collection: GeoController())
    try app.register(collection: CasoController())
}
