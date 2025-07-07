//
//  WebSocketManager.swift
//  
//
//  Created by Adrian Williams on 05/07/2025.
//


import Foundation

    /// Enumeration of possible errors that might occur while using ``WebSocketConnection``.
public enum WebSocketConnectionError: Error {
    case connectionError
    case transportError
    case encodingError
    case decodingError
    case disconnected
    case closed
}


@MainActor
class WebSocketManager: ObservableObject {
    @Published var latestMessage: IncomingMessage = .text(message: "")
    @Published var messageLog: String = "Ready..."

    private var webSocketTask: URLSessionWebSocketTask?
    private var listenerTask: Task<(), Never>?
    
    private let url = URL(string: "ws://127.0.0.1:8080/flutrws")!
//    private let url = URL(string: "wss://127.0.0.1:8080/flutrws")! // Replace with secure once set up

    private let encoder: JSONEncoder = JSONEncoder()
    private let decoder: JSONDecoder = JSONDecoder()
    
    deinit {
        listenerTask?.cancel()
        webSocketTask?.cancel(with: .goingAway, reason: nil)
    }

    var isConnected: Bool {
        return webSocketTask?.state == .running ? true : false
    }
    
    func connect() {
        let session = URLSession(configuration: .default)
        webSocketTask = session.webSocketTask(with: url)
        webSocketTask?.resume()

        listenForMessages()
    }

    func disconnect() {
        webSocketTask?.cancel(with: .goingAway, reason: nil)
    }
    
    func addToLog(message: String) {
        messageLog.append("\(Date()): \(message)\n")
    }
    
    func sendMessage(_ message: OutgoingMessage) async throws {
        guard let messageData = try? encoder.encode(message) else {
            throw WebSocketConnectionError.encodingError
        }
        
        do {
            try await webSocketTask?.send(.data(messageData))
        } catch {
            switch webSocketTask?.closeCode {
            case .invalid:
                throw WebSocketConnectionError.connectionError
                
            case .goingAway:
                throw WebSocketConnectionError.disconnected
                
            case .normalClosure:
                throw WebSocketConnectionError.closed
                
            default:
                throw WebSocketConnectionError.transportError
            }
        }
    }
    
    func sendTextMessage(_ text: String) async throws {
        let message = OutgoingMessage.text(message: text)
        try await sendMessage(message)
    }
    
    private func actOnIncomingMessage(_ message: IncomingMessage) async {
        self.latestMessage = message

        switch message {
        case .text(let text):
            addToLog(message: text)
//        case let .items(items):
//            self.items = items
//
//        case let .add(item):
//            items.append(item)
//
//        case let .update(item):
//            guard let index = items.firstIndex(where: { $0.id == item.id }) else {
//                return assertionFailure("Expected updated Item to exist")
//            }
//
//            items[index] = item
//
//        case let .delete(item):
//            guard let index = items.firstIndex(where: { $0.id == item.id }) else {
//                return assertionFailure("Expected deleted Item to exist")
//            }
//
//            let _ = items.remove(at: index)
        }

    }

    private func listenForMessages() {
        listenerTask = Task.detached(priority: .utility) { [weak self] in
            guard let self = self else { return }

            while true {
                do {
                    let message = try await self.webSocketTask?.receive()
                    
                    
                    switch message {
                    case .string(_):
//                        await MainActor.run {
//                            self.latestMessage = text
//                        }
                        assertionFailure("Did not expect to receive message as text")
                    case .data(let data):
                        guard let message = try? decoder.decode(IncomingMessage.self, from: data) else {
                            throw WebSocketConnectionError.decodingError
                        }

//                        MainActor.run {
                            await actOnIncomingMessage(message)
//                        }
                    case .none:
                        break
                    @unknown default:
                        assertionFailure("Unknown message type")
                        
                            // Unsupported data, closing the WebSocket Connection
                        await webSocketTask?
                            .cancel(with: .unsupportedData, reason: nil)
                        throw WebSocketConnectionError.decodingError
                    }
                } catch {
//                    await MainActor.run {
                        let errorIncoming = IncomingMessage
                            .text(
                                message: "Error: \(error.localizedDescription)"
                                )
                        await actOnIncomingMessage(errorIncoming)
//                    }
                    break
                }
            }
        }
    }


}
