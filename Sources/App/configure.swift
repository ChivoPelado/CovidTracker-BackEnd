import Vapor
import Fluent
import FluentSQLiteDriver

// configures your application
public func configure(_ app: Application) throws {
    // uncomment to serve files from /Public folder
    // app.middleware.use(FileMiddleware(publicDirectory: app.directory.publicDirectory))
    
  //  let directoryConfig = DirectoryConfiguration.detect()
    //app.directory
    //Referencia y crea esquema de Base de datos
    app.databases.use(.sqlite(.file("\(app.directory.workingDirectory)covidtracker.sqlite")), as: .sqlite)
    app.migrations.add(CrearRegistro())
    app.logger.logLevel = .debug
    try app.autoMigrate().wait()
    
   
    // register routes
    try routes(app)
}
