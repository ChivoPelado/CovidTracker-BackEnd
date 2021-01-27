import Vapor
import Fluent

func routes(_ app: Application) throws {
    app.get { req in
        return "It works!"
    }

    app.get("hello") { req -> String in
        return "Hello, world!"
    }
    
    app.post("registro") { req -> EventLoopFuture<Registro> in        
        let nuevoRegistro = try req.content.decode(Registro.self)
        return nuevoRegistro.save(on: req.db).map { nuevoRegistro }
    }
}
