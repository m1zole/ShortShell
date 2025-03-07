//
//  AppDelegate.swift
//  Pogo
//
//  Created by Amy While on 12/09/2022.
//

import UIKit
import Intents

@main
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        
        self.window = UIWindow(frame: UIScreen.main.bounds)
        self.window?.rootViewController = BaseNavigationController(rootViewController: ViewController(nibName: nil, bundle: nil))
        self.window?.makeKeyAndVisible()
        
        return true
    }
    
    func application(_ application: UIApplication, continue userActivity: NSUserActivity, restorationHandler: @escaping ([UIUserActivityRestoring]?) -> Void) -> Bool {
        
        //Spawner
        if userActivity.activityType == String(describing: SpawnerIntent.self) {
            if let intent = userActivity.interaction?.intent as? SpawnerIntent {
                if let executable:String = intent.binary {
                    if let arguments:String = intent.args {
                        spawn(command: executable, args: arguments.components(separatedBy: " "), root: (intent.asroot != 0))
                    } else {
                        spawn(command: executable, args: [""], root: (intent.asroot != 0))
                    }
                }
            }
        }
        
        //ScriptRunner
        if userActivity.activityType == String(describing: ScriptRunnerIntent.self) {
            if let intent = userActivity.interaction?.intent as? ScriptRunnerIntent {
                if let shell:String = intent.shell {
                    if let script:String = intent.script {
                        spawn(command: shell, args: ["-c"] + [script], root: (intent.asroot != 0))
                    }
                }
            }
        }
        return true
    }
}

