import Foundation


public class ElevenlabsSwift {
    private var elevenLabsAPI: String
    
    required init(elevenLabsAPI: String) {
        self.elevenLabsAPI = elevenLabsAPI
    }
    
    private let baseURL = "https://api.elevenlabs.io"
    
    public func fetchVoices() async throws -> [Voice]
    {
        
        let session = URLSession.shared
        let url = URL(string: "\(baseURL)/v1/voices")!
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue(elevenLabsAPI, forHTTPHeaderField: "xi-api-key")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        do {
            let (data, _) = try await session.data(for: request)
            
            let userResponse: VoicesResponse = try JSONDecoder().decode(VoicesResponse.self, from: data)
            print(userResponse.voices)
            
            return userResponse.voices
        }
        catch(let error)
        {
            throw WebAPIError.httpError(message: error.localizedDescription)
        }
        
    }
    
    public func textToSpeech(voice_id: String, text: String) async throws -> URL
    {
        
        let session = URLSession.shared
        let url = URL(string: "\(baseURL)/v1/text-to-speech/\(voice_id)")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue(elevenLabsAPI, forHTTPHeaderField: "xi-api-key")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("audio/mpeg", forHTTPHeaderField: "Accept")

        let parameters: SpeechRequest = SpeechRequest(text: text, voice_settings: ["stability" : 0, "similarity_boost": 0])
        
        guard let jsonBody = try? JSONEncoder().encode(parameters) else {
            throw WebAPIError.unableToEncodeJSONData
        }
        
        request.httpBody = jsonBody

        do {
            let (data, _) = try await session.data(for: request)
            print(data)
            
            let url = try self.saveDataToTempFile(data: data)
            
            return url
        }
        catch(let error)
        {
            throw WebAPIError.httpError(message: error.localizedDescription)
        }
        
    }
    
    private func saveDataToTempFile(data: Data) throws -> URL {
        let tempDirectoryURL = FileManager.default.temporaryDirectory
        let randomFilename = UUID().uuidString
        let fileURL = tempDirectoryURL.appendingPathComponent(randomFilename)
        print(data.count)
        try data.write(to: fileURL)
        return fileURL
    }
    
    // Utility function to create data for multipart/form-data
    private func createMultipartData(boundary: String, name: String, fileURL: URL, fileType: String) -> Data? {
        let fileName = fileURL.lastPathComponent
        var data = Data()

        // Multipart form data header
        data.append("--\(boundary)\r\n".data(using: .utf8)!)
        data.append("Content-Disposition: form-data; name=\"\(name)\"; filename=\"\(fileName)\"\r\n".data(using: .utf8)!)
        data.append("Content-Type: \(fileType)\r\n\r\n".data(using: .utf8)!)

        // File content
        guard let fileData = try? Data(contentsOf: fileURL) else {
            return nil
        }
        data.append(fileData)
        data.append("\r\n".data(using: .utf8)!)

        return data
    }

    public func uploadVoice(name: String, description: String, fileURL: URL, completion: @escaping (Bool) -> Void)  {
        
        guard let url = URL(string: "\(baseURL)/v1/voices/add") else {
            print("Invalid URL")
            completion(false)
            return
        }

        let boundary = UUID().uuidString
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "accept")
        request.setValue(elevenLabsAPI, forHTTPHeaderField: "xi-api-key")
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")

        var data = Data()
        let parameters = [
            ("name", name),
            ("description", description),
            ("labels", "")
        ]

        for (key, value) in parameters {
            data.append("--\(boundary)\r\n".data(using: .utf8)!)
            data.append("Content-Disposition: form-data; name=\"\(key)\"\r\n\r\n".data(using: .utf8)!)
            data.append("\(value)\r\n".data(using: .utf8)!)
        }

        if let fileData = createMultipartData(boundary: boundary, name: "files", fileURL: fileURL, fileType: "audio/x-wav") {
            data.append(fileData)
        }

        // Multipart form data footer
        data.append("--\(boundary)--\r\n".data(using: .utf8)!)

        request.httpBody = data

        let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
            if let error = error {
                print("Error: \(error)")
                completion(false)
            } else if let data = data {
                if let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 {
                    do {
                        let json = try JSONSerialization.jsonObject(with: data, options: [])
                        print(json)
                        completion(true)
                    } catch {
                        print("Error decoding JSON: \(error)")
                        completion(false)
                    }
                } else {
                    print("Error: Invalid status code")
                    completion(false)
                }
            }
        }

        task.resume()
    }
    
    public func deleteVoice(voiceId: String) async throws {
        guard let url = URL(string: "\(baseURL)/v1/voices/\(voiceId)") else {
            print("Invalid URL")
            throw WebAPIError.httpError(message: "incorrect url")
        }
        let session = URLSession.shared

        var request = URLRequest(url: url)
        request.httpMethod = "DELETE"
        request.setValue("application/json", forHTTPHeaderField: "accept")
        request.setValue(elevenLabsAPI, forHTTPHeaderField: "xi-api-key")
        
        do {
            let (data, _) = try await session.data(for: request)
            
        }
        catch(let error)
        {
            throw WebAPIError.httpError(message: error.localizedDescription)
        }
    }
    
    public func editVoice(voiceId: String, name: String, description: String, fileURL: URL, completion: @escaping (Bool) -> Void) {
        
        guard let url = URL(string: "\(baseURL)/v1/voices/\(voiceId)/edit") else {
            print("Invalid URL")
            completion(false)
            return
        }

        let boundary = UUID().uuidString
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "accept")
        request.setValue(elevenLabsAPI, forHTTPHeaderField: "xi-api-key")
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")

        var data = Data()
        let parameters = [
            ("name", name),
            ("description", description),
            ("labels", "")
        ]

        for (key, value) in parameters {
            data.append("--\(boundary)\r\n".data(using: .utf8)!)
            data.append("Content-Disposition: form-data; name=\"\(key)\"\r\n\r\n".data(using: .utf8)!)
            data.append("\(value)\r\n".data(using: .utf8)!)
        }

        if let fileData = createMultipartData(boundary: boundary, name: "files", fileURL: fileURL, fileType: "audio/x-wav") {
            data.append(fileData)
        }

        // Multipart form data footer
        data.append("--\(boundary)--\r\n".data(using: .utf8)!)

        request.httpBody = data

        let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
            if let error = error {
                print("Error: \(error)")
                completion(false)
            } else if let data = data {
                if let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 {
                    do {
                        let json = try JSONSerialization.jsonObject(with: data, options: [])
                        print(json)
                        completion(true)
                    } catch {
                        print("Error decoding JSON: \(error)")
                        completion(false)
                    }
                } else {
                    print("Error: Invalid status code")
                    completion(false)
                }
            }
        }

        task.resume()
    }


}


public enum WebAPIError: Error {
    case identityTokenMissing
    case unableToDecodeIdentityToken
    case unableToEncodeJSONData
    case unableToDecodeJSONData
    case unauthorized
    case invalidResponse
    case httpError(message: String)
    case httpErrorWithStatus(status: Int)

}


public struct VoicesResponse: Codable {
    public let voices: [Voice]
}


public struct Voice: Codable, Identifiable, Hashable {
    public let voice_id: String
    public let name: String
    
    public var id: String { voice_id }

}


public struct SpeechRequest: Codable {
    public let text: String
    public let voice_settings: [String: Int]
}
