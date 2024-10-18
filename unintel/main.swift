//
//  main.swift
//  unintel
//
//  Created by Amy on 18/10/2024.
//

import Foundation

let arguments = CommandLine.arguments
if arguments.count < 2 {
    print("Usage: \(arguments[0]) <command>")
    exit(1)
}
let inputArg = arguments[1]
let inputPath = URL(fileURLWithPath: inputArg)
if !inputPath.exists {
    print("Path \(inputPath.path) does not exist.")
    exit(1)
}

let lipoPath = URL(fileURLWithPath: "/usr/bin/lipo")
if !FileManager.default.fileExists(atPath: lipoPath.path) {
    print("Lipo is not found. Install Command Line Tools to fix.")
    exit(1)
}

Task {
    await withTaskGroup(of: Void.self) { group in
        func addTask(for file: URL) {
            if file.lastPathComponent != "dylib" && !file.executable  {
                return
            }
            group.addTask {
                let info = Spawn.spawn(path: lipoPath.path, args: ["-info", file.path])
                switch info {
                case .success(stdout: let stdout, stderr: _):
                    guard stdout.contains("x86_64") && (stdout.contains("arm64") || stdout.contains("arm64e")) else {
                        return
                    }
                default:
                    return
                }
                let strip = Spawn.spawn(path: lipoPath.path, args: ["-remove", "x86_64", file.path, "-o", file.path])
                switch strip {
                case .success:
                    print("Stripped \(file.path)")
                case .failure(stdout: let stdout, stderr: let stderr):
                    print("Failed to strip \(file.path) \(stdout) \(stderr)")
                case .failedToSpawn:
                    print("Overloadded!!")
                }
            }
        }
        func loop(for folder: [URL]) {
            for file in folder {
                if file.symlink {
                    continue
                }
                if file.dirExists {
                    loop(for: file.implicitContents)
                    continue
                }
                addTask(for: file)
            }
        }
        if inputPath.dirExists {
            let implicitContents = inputPath.implicitContents
            loop(for: implicitContents)
        } else {
            addTask(for: inputPath)
        }
    }
    exit(0)
}

RunLoop.main.run()
