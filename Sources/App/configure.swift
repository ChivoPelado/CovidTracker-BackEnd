import Vapor
import Fluent
import FluentSQLiteDriver

public func configure(_ app: Application) throws {
    
    //Referencia y crea la Base de datos
    app.databases.use(.sqlite(.file("covidtracker.sqlite")), as: .sqlite)
    
    app.middleware.use(ErrorMiddleware.default(environment: app.environment))
    
    //Crea esquema de Base de datos
    app.migrations.add(CreateUsers())
    app.migrations.add(CreateTokens())
    app.migrations.add(CrearRegistro())
    
    app.logger.logLevel = .debug
    try app.autoMigrate().wait()

    // registra rutas
    try routes(app)
}
