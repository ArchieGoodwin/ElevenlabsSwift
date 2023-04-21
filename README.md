# ElevenlabsSwift

ElevenlabsSwift is an open-source Swift package that provides an easy-to-use API for managing and utilizing voices in the VoiceLab, a cloud-based service for creating and managing custom voice collections. With ElevenlabsSwift, you can convert text into speech, get a list of all available voices, delete or add new voices, and even edit existing voices created by you.

## Features

ElevenlabsSwift API includes the following features:

- Convert text into speech using a voice of your choice and return the audio.
- Get a list of all available voices for a user.
- Delete a voice by its ID.
- Add a new voice to your collection of voices in VoiceLab.
- Edit a voice created by you.

## Example of usage

```swift
import ElevenlabsSwift

let elevenApi = ElevenlabsSwift(elevenLabsAPI: Elevenlabs_API_key)
let url = try await elevenApi.textToSpeech(voice_id: selectedVoice.voice_id, text: "text to speech")
```

## Installation

To use ElevenlabsSwift in your project, add it to your Package.swift file:

```swift
dependencies: [
    .package(url: "https://github.com/ArchieGoodwin/ElevenlabsSwift", from: "0.7.2")
]
```

And then import the package in your source files:

```swift
import ElevenlabsSwift
```

## License

MIT License

Copyright (c) 2023 wilder.dev LLC

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.

