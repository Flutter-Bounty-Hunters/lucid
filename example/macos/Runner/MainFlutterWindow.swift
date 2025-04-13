import Cocoa
import FlutterMacOS

class MainFlutterWindow: NSWindow {
  override func awakeFromNib() {
    let flutterViewController = FlutterViewController()
    let windowFrame = self.frame
    self.contentViewController = flutterViewController
    self.setFrame(windowFrame, display: true)

    RegisterGeneratedPlugins(registry: flutterViewController)

    super.awakeFromNib()

    // Remove the title bar and expand content to fill the entire window.
    self.setContentSize(NSSize(width: 1400, height: 850))
    self.styleMask.insert([.fullSizeContentView])
    self.titleVisibility = TitleVisibility.hidden
    self.titlebarAppearsTransparent = true

    // Create a toolbar and make it unified so we can push down the traffic lights.
    self.toolbar = NSToolbar()
    self.toolbarStyle = .unified
  }

  override func performZoom(_ sender: Any?) {
    // Do nothing to prevent window expansion on double-click
  }
}
