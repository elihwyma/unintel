//
//  Spawn.swift
//  unintel
//
//  Created by Amy on 18/10/2024.
//

import Foundation
import Darwin

internal enum Spawn {
    
    case success(stdout: String, stderr: String)
    
    case failure(stdout: String, stderr: String)
    
    case failedToSpawn
    
    internal static func spawn(path: String, args: [String] = []) -> Spawn {
        let process = Process()
        process.executableURL = URL(fileURLWithPath: path)
        if !args.isEmpty {
            process.arguments = args
        }
       
        let stdoutPipe = Pipe()
        let stderrPipe = Pipe()
        
        process.standardOutput = stdoutPipe
        process.standardError = stderrPipe
        
        do {
            try process.run()
        } catch {
            return .failedToSpawn
        }
        
        process.waitUntilExit()
        
        let stdout = String(data: stdoutPipe.fileHandleForReading.readDataToEndOfFile(), encoding: .utf8) ?? ""
        let stderr = String(data: stderrPipe.fileHandleForReading.readDataToEndOfFile(), encoding: .utf8) ?? ""
        
        if process.terminationStatus != 0 {
            return .failure(stdout: stdout, stderr: stderr)
        } else {
            return .success(stdout: stdout, stderr: stderr)
        }
    }
    
}
