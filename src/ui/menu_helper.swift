import Cocoa

class MenuBarController: NSObject, NSApplicationDelegate {
    private var statusItem: NSStatusItem?
    private var menu: NSMenu?
    private var isActive: Bool = true
    
    override init() {
        super.init()
        NSApplication.shared.delegate = self
    }
    
    func applicationDidFinishLaunching(_ notification: Notification) {
        print("MindfulAccess menu helper starting...")
        setupMenuBar()
    }
    
    private func setupMenuBar() {
        // Initialize the application
        let app = NSApplication.shared
        app.setActivationPolicy(.regular)
        
        // Set application icon
        if let appIcon = NSImage(systemSymbolName: "lock.shield.fill", accessibilityDescription: "MindfulAccess") {
            appIcon.size = NSSize(width: 128, height: 128)
            NSApplication.shared.applicationIconImage = appIcon
        }
        
        // Create the status item
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
        
        // Set up the button
        if let button = statusItem?.button {
            button.image = NSImage(systemSymbolName: "lock.shield.fill", accessibilityDescription: "MindfulAccess")
            button.appearsDisabled = false
            button.isEnabled = true
            button.target = self
            button.action = #selector(buttonClicked)
        } else {
            print("Failed to create menu bar button")
            exit(1)
        }
        
        // Create the menu
        menu = NSMenu()
        menu?.addItem(withTitle: "MindfulAccess", action: nil, keyEquivalent: "")
        menu?.addItem(NSMenuItem.separator())
        
        let statusMenuItem = NSMenuItem(title: "Status: Active", action: #selector(toggleStatus), keyEquivalent: "s")
        statusMenuItem.target = self
        menu?.addItem(statusMenuItem)
        
        menu?.addItem(withTitle: "Configure...", 
                     action: #selector(configure),
                     keyEquivalent: ",")
        menu?.addItem(NSMenuItem.separator())
        menu?.addItem(withTitle: "Quit", 
                     action: #selector(quit),
                     keyEquivalent: "q")
        
        statusItem?.menu = menu
        
        updateMenuBarIcon()
        print("Menu bar setup complete")
    }
    
    func applicationDockMenu(_ sender: NSApplication) -> NSMenu? {
        let dockMenu = NSMenu()
        dockMenu.addItem(withTitle: "Configure...", action: #selector(configure), keyEquivalent: "")
        return dockMenu
    }
    
    private func updateMenuBarIcon() {
        if let button = statusItem?.button {
            let iconName = isActive ? "lock.shield.fill" : "lock.shield"
            button.image = NSImage(systemSymbolName: iconName, accessibilityDescription: "MindfulAccess")
        }
    }
    
    @objc private func toggleStatus() {
        isActive = !isActive
        if let item = menu?.items.first(where: { $0.action == #selector(toggleStatus) }) {
            item.title = "Status: \(isActive ? "Active" : "Inactive")"
        }
        updateMenuBarIcon()
    }
    
    @objc private func buttonClicked() {
        if let menu = menu {
            statusItem?.menu?.popUp(positioning: nil, at: NSPoint(x: 0, y: 0), in: statusItem?.button)
        }
    }
    
    @objc private func configure() {
        print("Configure clicked")
        // Look for the script in multiple locations
        let possiblePaths = [
            "/Applications/MindfulAccess.app/Contents/Resources/src/core/app_protector.sh",
            Bundle.main.bundlePath + "/Contents/Resources/src/core/app_protector.sh",
            Bundle.main.bundlePath.replacingOccurrences(of: "/Contents/MacOS", with: "") + "/Contents/Resources/src/core/app_protector.sh"
        ]
        
        var scriptPath: String?
        for path in possiblePaths {
            print("Checking path: \(path)")
            if FileManager.default.fileExists(atPath: path) {
                scriptPath = path
                break
            }
        }
        
        if let scriptPath = scriptPath {
            print("Found script at: \(scriptPath)")
            let process = Process()
            process.executableURL = URL(fileURLWithPath: "/bin/sh")
            process.arguments = ["-c", scriptPath + " --config"]
            
            do {
                try process.run()
                process.waitUntilExit()
            } catch {
                print("Failed to run script: \(error)")
            }
        } else {
            print("Could not find app_protector.sh script")
            // Show an alert to the user
            let alert = NSAlert()
            alert.messageText = "Configuration Error"
            alert.informativeText = "Could not find the configuration script. Please ensure the application is properly installed."
            alert.alertStyle = .warning
            alert.addButton(withTitle: "OK")
            alert.runModal()
        }
    }
    
    @objc private func quit() {
        NSApplication.shared.terminate(nil)
    }
}

// Create and run the application
let app = NSApplication.shared
let delegate = MenuBarController()
app.delegate = delegate
app.run() 