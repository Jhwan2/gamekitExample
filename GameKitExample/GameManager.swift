//
//  GameManager.swift
//  GameKitExample
//
//  Created by 주환 on 3/29/24.
//

import UIKit
import GameKit

enum GameSessionState {
    case idle
    case matchmaking
    case inGame
    case shared
}

enum PlayerAuthState: String {
    case authenticating = "Logging in to Game Center..."
    case unauthenticated = "Please sign in to Game Center to play."
    case authenticated = ""
    
    case error = "There was an error, logging into Game Center."
    case restricted = "You're not allowed to play multiplayer games!"
}

final class GameManager: NSObject, ObservableObject {
    static let shared = GameManager()
    @Published var authenticationState = PlayerAuthState.authenticating
    var localPlayer = GKLocalPlayer.local
    
    private var matchRequest: GKMatchRequest = GKMatchRequest() // 매칭의 각종 설정을 넣어줄 수 있음 최소, 최대인원수라던가 그룹번호라던가
    private var matchmakingMode: GKMatchmakingMode = .default // 이친구도 매칭 관련 옵션설정하는 거
    private var matchmaker: GKMatchmaker? // 이 친구는 매칭을 시작하게 하는 것
    var match: GKMatch? // 매칭이 성공적으로 되었을 때 넣어둘 매칭 친구
    @Published var otherPlayer: [GKPlayer]? // GKPlayer == 다른 사람들 저장해둘 수도 있고 그외에 처리할 때도 쓰임 등.
    
    private var rootViewController: UIViewController? {
        let windowsence = UIApplication.shared.connectedScenes.first as? UIWindowScene
        return windowsence?.windows.first?.rootViewController
    }
    
    func authenticateUser() {
        print("유저 인증 시작")
        GKLocalPlayer.local.authenticateHandler = { [self] viewc, error in
            if let viewContorller = viewc {
                rootViewController?.present(viewContorller, animated: true)
                return
            } // GameKit내부의 로그인 ViewController를 띄워줌
            if let error = error {
                authenticationState = .error
                print(error.localizedDescription)
                return
            } // 에러처리
            if localPlayer.isAuthenticated {
                if localPlayer.isMultiplayerGamingRestricted {
                    authenticationState = .restricted
                } else {
                    authenticationState = .authenticated
                }
            } else {
                authenticationState = .unauthenticated
            } // 로그인 후 상태 설정
        }
    }
    
    func startMatchmaking() {
        let request = GKMatchRequest() // 매칭 설정 셋팅하기위해서 만들고
        request.minPlayers = 2 // 최소 인원을 2명으로할거야
        request.maxPlayers = 4 // 최대인원은 사용자에게 받아온 인원으로할거야
//        request.playerGroup = Int(groupNumber)! // 이거슨 플로깅에 쓰였던건데 숫자코드로 원하는사람들끼리 매칭하는 기능으로 사용되었음
        matchRequest = request // 선언해두었던 곳으로 옮기는 과정
        
        matchmaker = GKMatchmaker.shared()
        matchmaker?.findMatch(for: matchRequest, withCompletionHandler: { [weak self] (match, error) in
            if let error = error {
                print("\(error.localizedDescription)")
            } else if let match = match {
                self?.startGame(newMatch: match)
            } //matchmaker을 통해 request를 넣고 매칭을 시작함 매칭이 완료되면 완료된 매칭을
             // 내가 선언한곳에 안전하게 옮겨주고 게임시작 로직을 실행하는거임
        })
    }
    
    func startGame(newMatch: GKMatch) {
        newMatch.delegate = self
        match = newMatch
        
        if let match = match, match.players.isEmpty {
            otherPlayer = newMatch.players
            //            inGame = true
        } else {
            print("player info nothing..")
        }
    }
}

extension GameManager: GKMatchDelegate {
    // Receive..
    func match(_ match: GKMatch, didReceive data: Data, fromRemotePlayer player: GKPlayer) {
        print(#function)
//        switch gameState {
//        case .matchmaking:
//            if !isHost {
//                let content = String(decoding: data, as: UTF8.self)
//                if content.starts(with: "strData") {
//                    let message = content.replacing("strData:", with: "")
//                    receivedString(message)
//                }
//                //                gameState = .inGame
//            } else {
//                if let content = decodeUserInfo(data) {
//                    DispatchQueue.main.async { [self] in
//                        if let index = otherPlayerInfo?.firstIndex(where: { $0.uuid == content.uuid }) {
//                            // If an element with the same uuid exists, replace it
//                            otherPlayerInfo?[index] = content
//                            sendUserInfo()
//                        } else {
//                            // If the uuid doesn't exist, append the new element
//                            otherPlayerInfo?.append(content)
//                            sendUserInfo()
//                        }
//                    }
//                } else {
//                    //                    sendUserInfo()
//                }
//            }
//        case .inGame:
//            if let content = decodeUserInfo(data) {
//                DispatchQueue.main.async { [self] in
//                    if let index = otherPlayerInfo?.firstIndex(where: { $0.uuid == content.uuid }) {
//                        // If an element with the same uuid exists, replace it
//                        otherPlayerInfo?[index] = content
//                    } else {
//                        // If the uuid doesn't exist, append the new element
//                        otherPlayerInfo?.append(content)
//                    }
//                }
//            } else {
//                if let content = decodeUserInfoArray(from: data) {
//                    DispatchQueue.main.async {
//                        self.otherPlayerInfo = self.filterAndRemoveOwnUserInfo(from: content)
//                    }
//                } else {
//                    //                    sendUserInfo()
//                }
//            }
//        case .idle:
//            print("아직 게임 매칭상태도아님.")
//        case .shared:
//            print("shared게임상태로 들어감")
//            if isHost {
//                if let content = decodeUserInfo(data) {
//                    DispatchQueue.main.async { [self] in
//                        if let index = otherPlayerInfo?.firstIndex(where: { $0.uuid == content.uuid }) {
//                            // If an element with the same uuid exists, replace it
//                            otherPlayerInfo?[index] = content
//                            otherPlayerInfo?.insert(localPlayerInfo!, at: 0)
//                        } else {
//                            // If the uuid doesn't exist, append the new element
//                            otherPlayerInfo?.append(content)
//                            otherPlayerInfo?.insert(localPlayerInfo!, at: 0)
//                        }
//                    }
//                }
//            } else {
//                if let content = decodeUserInfoArray(from: data) {
//                    DispatchQueue.main.async {
//                        var arr = self.filterAndRemoveOwnUserInfo(from: content)
//                        arr.insert(self.localPlayerInfo!, at: 0)
//                        self.otherPlayerInfo = arr
//                    }
//                } else {
//                    //                    sendUserInfo()
//                }
//            }
//        }
        
    }
    
    func match(_ match: GKMatch, player: GKPlayer, didChange state: GKPlayerConnectionState) {
        print(#function)
        //        guard let user = localPlayerInfo else { return }
        switch state {
        case .connected:
            print("DEBUG: localplayer = \(localPlayer.displayName), otherplayer = \(player.displayName)")
            if isHost {
                hostPlayer = localPlayer.displayName
                guard let host = hostPlayer else { print("ishost, host optional and nil !")
                    return }
                sendString(host)
            }
                        DispatchQueue.main.async {
                            guard let host = self.hostPlayer else { return }
                            self.sendString("began: \(host.gamePlayerID)")
                            self.otherPlayer?.append(player)
                            self.sendString("began: \(user.name)")
                            self.sendUserInfo()
                        }
        case .disconnected:
            print("플레이어\(player.displayName)의 연결이 끊김")
        case .unknown: 280
            print("\(player.displayName)의 연결상태 모름")
        @unknown default:
            break
        }
        
    }
    
}
