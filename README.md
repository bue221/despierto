# Despierto ☀️🌙

Una mini app para la barra de menú de macOS que mantiene tu Mac **encendido aunque cierres la tapa**.

Un clic en el icono de arriba y listo: tu descarga, tu música o tu render siguen aunque bajes la pantalla.

| Icono | Qué significa |
|---|---|
| 🌙 luna | Normal: el Mac se duerme al cerrar la tapa |
| ☀️ sol | Despierto: el Mac sigue encendido con la tapa cerrada |

## Qué hace

- **Activar / desactivar** con un clic desde la barra de menú (o con `⌘D` con el menú abierto).
- Muestra tu **batería** y avisa con ⚠️ si está activado, vas con batería y baja del 20 %.
- Opción **«Abrir al iniciar sesión»** para tenerla siempre a mano.
- Se actualiza sola si cambias el ajuste desde la Terminal.
- Sin icono en el Dock: solo vive en la barra de arriba.

## Instalación

Necesitas macOS 13 o posterior y las herramientas de Xcode (`xcode-select --install`).

```bash
git clone https://github.com/laulys/despierto.git
cd despierto
./build.sh
open build/Despierto.app
```

Si quieres tenerla siempre, arrastra `build/Despierto.app` a tu carpeta **Aplicaciones** y actívale «Abrir al iniciar sesión».

## Cómo funciona

Por debajo usa el comando de macOS:

```bash
sudo pmset -a disablesleep 1   # no dormir al cerrar la tapa
sudo pmset -a disablesleep 0   # volver a lo normal
```

Como es un ajuste del sistema, macOS te pide tu contraseña cada vez que lo cambias. La app no guarda tu contraseña: la pide el propio sistema.

Todo el código está en [`main.swift`](main.swift) (unas 150 líneas, con comentarios en español).

## ⚠️ Ojo

- **No metas el Mac en la mochila** con el modo despierto activado: se puede calentar mucho.
- Con la tapa cerrada sigue gastando batería, así que mejor enchufado.
- Acuérdate de **volver a lo normal** cuando ya no lo necesites.

## Ideas para seguir

- Temporizador: «despierto durante 1 h» y que luego vuelva solo a lo normal.
- No pedir la contraseña cada vez.
- Icono propio.

---

Vibecodeado con [Claude Code](https://claude.com/claude-code).
