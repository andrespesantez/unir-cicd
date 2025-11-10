import jenkins.model.*
import hudson.security.*

def instance = Jenkins.getInstance()

// Crear usuario admin
def hudsonRealm = new HudsonPrivateSecurityRealm(false)
hudsonRealm.createAccount("admin", "admin123")
instance.setSecurityRealm(hudsonRealm)

// Configurar permisos
def strategy = new FullControlOnceLoggedInAuthorizationStrategy()
strategy.setAllowAnonymousRead(false)
instance.setAuthorizationStrategy(strategy)

instance.save()

println("Usuario admin creado con contraseña: admin123")
