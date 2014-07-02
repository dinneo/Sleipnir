//
//  DefaultReporter.swift
//  Sleipnir
//
//  Created by Artur Termenji on 6/24/14.
//  Copyright (c) 2014 railsware. All rights reserved.
//

import Foundation

class DefaultReporter : Reporter {
 
    var examplesCount: Int = 0
    
    var failureMessages: String[]
    
    init() {
        failureMessages = String[]()
    }
    
    func successToken() -> String {
        return "."
    }
    
    func failureToken() -> String {
        return "F"
    }
    
    func errorToken() -> String {
        return "E"
    }
    
    func failureMessageForExample(example: Internal.Example) -> String {
        return "FAILURE " + example.fullText() + ":\n" + example.failure() + "\n"
    }
    
    func runWillStart() {
        println("RUN START")
    }
    
    func runDidComplete() {
        println()
        
        printMessages(failureMessages)
        printStats()
    }
    
    func runWillStartWithGroup(group: Internal.ExampleGroup) {
        startObservingExamples(group.examples)
    }
    
    func runDidCompleteWithGroup(group: Internal.ExampleGroup) {
        stopObservingExamples(group.examples)
    }
    
    // Private
    
    func printMessages(messages: String[]) {
        println()
        
        for message in messages {
            println(message)
        }
    }
    
    func printStats() {
        println("\nFinished in 0 seconds")
        println("\(examplesCount) examples, \(failureMessages.count) failures")
    }
    
    func startObservingExamples(examples: Internal.Example[]) {
        for example in examples {
            var exampleObserver: Observable<Internal.ExampleState>.Observer = ({
                (newValue: Internal.ExampleState) -> () in
                self.reportOnExample(example)
            })
            
            example.state.addObserver("state_observer", observer: exampleObserver)
            examplesCount++
        }
    }
    
    func stopObservingExamples(examples: Internal.Example[]) {
        for example in examples {
            example.state.removeObserver("state_observer")
        }
    }
    
    func reportOnExample(example: Internal.Example) {
        var stateToken: String = ""
    
        switch example.state.get() {
        case Internal.ExampleState.Passed:
            stateToken = successToken()
        case Internal.ExampleState.Error:
            stateToken = errorToken()
        case Internal.ExampleState.Failed:
            stateToken = failureToken()
            failureMessages.append(failureMessageForExample(example))
        default:
            break;
        }
        
        print(stateToken)
    }
    
}