//
//  Election_Result_DisplayerApp.swift
//  Election Result Displayer
//
//  Created by Andrew on 5/26/25.
//

import SwiftUI;
import AppKit;

@main
struct Election_Result_DisplayerApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate;
    let persistenceController = PersistenceController.shared
    final class AppDelegate: NSObject, NSApplicationDelegate {
        func applicationWillUpdate(_ notification: Notification) {
            if let menu = NSApplication.shared.mainMenu {
                if let view = menu.items.first(where: { $0.title == "View"}) {
                    menu.removeItem(view);
                }
            }
        }
        func applicationDidFinishLaunching(_ notification: Notification) {
            @Environment(\.dismissWindow) var dismissWindow;
            dismissWindow(id: "controlpanel");
        }
    }
    var body: some Scene {
        @NSApplicationDelegateAdaptor(AppDelegate.self) var delegate;
        @Environment(\.openWindow) var openWindow;
        let current: CurrentRace = CurrentRace();
        // main window (in ContentView.swift)
        Window("Election Result Displayer", id: "main"){
            ContentView()
                .fixedSize()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
                .environmentObject(current);
        }.defaultSize(width: 1280, height: 720).windowResizability(.contentSize)
        .commands {
            CommandGroup(after: CommandGroupPlacement.newItem) {
                Button("Open Control Panel") {
                    openWindow(id: "controlpanel");
                }
            }
            CommandGroup(replacing: .help) {
                    Button(action: {
                        openWindow(id: "controlpanel")
                    }, label: {
                        Text("Help")
                    })
                }
        }
        Window("Control Panel", id: "controlpanel"){
            PanelView(googleraces: ElectionData(), localraces: ElectionData(), manualrace: RaceString(racename: "Enter name", index: 0, demname: "", dempercent: "", demvotes: "", dempic: "", gopname: "", goppercent: "", gopvotes: "", goppic: "", winner: "N")).fixedSize()
                .environmentObject(current);
        }.defaultSize(width: 800, height: 500).windowResizability(.contentSize)
    }
}

enum AppError: Error {
    case fetchError(String);
}

class AppDelegate: NSObject, NSApplicationDelegate {
    func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
        return true
    }
}
