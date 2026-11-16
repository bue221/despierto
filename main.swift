// Despierto — app de barra de menú para que el Mac no se duerma al cerrar la tapa.
// Usa `pmset -a disablesleep 1/0`, que necesita tu contraseña de administrador.

import AppKit
import ServiceManagement

@MainActor
final class AppDelegate: NSObject, NSApplicationDelegate, NSMenuDelegate {
    private var statusItem: NSStatusItem!
    private let menu = NSMenu()
    private let statusLine = NSMenuItem(title: "", action: nil, keyEquivalent: "")
    private let batteryLine = NSMenuItem(title: "", action: nil, keyEquivalent: "")
    private let toggleItem = NSMenuItem(title: "", action: #selector(toggle), keyEquivalent: "d")
    private let loginItem = NSMenuItem(title: "Abrir al iniciar sesión", action: #selector(toggleLogin), keyEquivalent: "")
    private var isAwake = false
    private var timer: Timer?

    func applicationDidFinishLaunching(_ notification: Notification) {
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.squareLength)

        toggleItem.target = self
        loginItem.target = self
        menu.delegate = self

        menu.addItem(statusLine)
        menu.addItem(batteryLine)
        menu.addItem(.separator())
        menu.addItem(toggleItem)
        menu.addItem(.separator())
        menu.addItem(loginItem)
        menu.addItem(NSMenuItem(title: "Salir de Despierto", action: #selector(NSApplication.terminate(_:)), keyEquivalent: "q"))
        statusItem.menu = menu

        refresh()
        // Por si lo cambias desde la Terminal, se actualiza solo cada 30 s.
        timer = Timer.scheduledTimer(withTimeInterval: 30, repeats: true) { _ in
            Task { @MainActor in self.refresh() }
        }
    }

    func menuWillOpen(_ menu: NSMenu) { refresh() }

    // MARK: - Estado

    private func refresh() {
        isAwake = Self.readSleepDisabled()
        let battery = Self.readBattery()

        let symbol = isAwake ? "sun.max.fill" : "moon.zzz"
        let image = NSImage(systemSymbolName: symbol, accessibilityDescription: isAwake ? "Despierto" : "Normal")
        image?.isTemplate = true
        statusItem.button?.image = image
        statusItem.button?.toolTip = isAwake
            ? "Despierto: no se duerme al cerrar la tapa"
            : "Normal: se duerme al cerrar la tapa"

        statusLine.title = isAwake
            ? "☀️  Despierto aunque cierres la tapa"
            : "🌙  Normal: se duerme al cerrar la tapa"
        toggleItem.title = isAwake
            ? "Volver a lo normal"
            : "Mantener despierto con la tapa cerrada"

        if let battery {
            let source = battery.charging ? "enchufado" : "con batería"
            let warning = (isAwake && !battery.charging && battery.percent <= 20) ? "  ⚠️ ¡enchúfalo!" : ""
            batteryLine.title = "🔋  \(battery.percent)% · \(source)\(warning)"
            batteryLine.isHidden = false
        } else {
            batteryLine.isHidden = true
        }

        loginItem.state = SMAppService.mainApp.status == .enabled ? .on : .off
    }

    // MARK: - Acciones

    @objc private func toggle() {
        let newValue = isAwake ? 0 : 1
        let prompt = isAwake
            ? "Despierto quiere volver a dejar que tu Mac se duerma al cerrar la tapa."
            : "Despierto quiere que tu Mac no se duerma al cerrar la tapa."
        let source = "do shell script \"/usr/bin/pmset -a disablesleep \(newValue)\" with prompt \"\(prompt)\" with administrator privileges"

        var error: NSDictionary?
        NSAppleScript(source: source)?.executeAndReturnError(&error)

        // -128 = el usuario pulsó «Cancelar»: no es un error.
        if let error, (error[NSAppleScript.errorNumber] as? Int) != -128 {
            showAlert("No se pudo cambiar", error[NSAppleScript.errorMessage] as? String ?? "Error desconocido")
        }
        refresh()
    }

    @objc private func toggleLogin() {
        do {
            if SMAppService.mainApp.status == .enabled {
                try SMAppService.mainApp.unregister()
            } else {
                try SMAppService.mainApp.register()
            }
        } catch {
            showAlert("No se pudo cambiar el inicio automático", error.localizedDescription)
        }
        refresh()
    }

    private func showAlert(_ title: String, _ message: String) {
        NSApp.activate(ignoringOtherApps: true)
        let alert = NSAlert()
        alert.messageText = title
        alert.informativeText = message
        alert.runModal()
    }

    // MARK: - Lectura del sistema

    /// `pmset -g` solo muestra la línea «SleepDisabled 1» cuando está activado.
    private static func readSleepDisabled() -> Bool {
        let output = run("/usr/bin/pmset", ["-g"])
        for line in output.split(separator: "\n") where line.contains("SleepDisabled") {
            return line.split(whereSeparator: \.isWhitespace).last == "1"
        }
        return false
    }

    private static func readBattery() -> (percent: Int, charging: Bool)? {
        let output = run("/usr/bin/pmset", ["-g", "batt"])
        guard let range = output.range(of: #"\d+(?=%)"#, options: .regularExpression),
              let percent = Int(output[range]) else { return nil }
        return (percent, output.contains("AC Power"))
    }

    private static func run(_ path: String, _ args: [String]) -> String {
        let process = Process()
        process.executableURL = URL(fileURLWithPath: path)
        process.arguments = args
        let pipe = Pipe()
        process.standardOutput = pipe
        process.standardError = Pipe()
        do { try process.run() } catch { return "" }
        let data = pipe.fileHandleForReading.readDataToEndOfFile()
        process.waitUntilExit()
        return String(decoding: data, as: UTF8.self)
    }
}

MainActor.assumeIsolated {
    let app = NSApplication.shared
    let delegate = AppDelegate()
    app.delegate = delegate
    app.setActivationPolicy(.accessory) // sin icono en el Dock
    app.run()
}
