//
//  CalculateWSD.swift
//  Runner
//
//  Created by Kara Crowder on 11/21/19.
//  Copyright © 2019 The Chromium Authors. All rights reserved.
//

import Foundation
import AVFoundation

class WSDCalculator {
	
	var ambianceThreshold: Float = -1.0
	
	static let sharedInstance = WSDCalculator()
	
	private init() {}
	
	// Get amplitudes for the given file
	func getAmplitudes(for fileName: String) -> [Double] {
		//get multisyllabic word array and rate
		
		let currentWordResponse = getCurrentWordArrayAndRate(for: fileName)
		let currentWordArray = currentWordResponse.0
		
		var doubleArray: [Double] {
			currentWordArray.map {Double($0)}
		}
		
		return doubleArray
	}
	
	// Calculates the WSD of the given file with syllable count
	func calculateWSD(for fileName: String, with syllableCount: Int) -> Double {
		//get multisyllabic word array and rate
		
		let currentWordResponse = getCurrentWordArrayAndRate(for: fileName)
		let currentWordArray = currentWordResponse.0
		let currentWordRate = currentWordResponse.1
		
		//get absolute value of multisyllabic word array
		
		let currentWordArrayAbsValue = getAbsoluteValueArray(for: currentWordArray)
		let threshold = ambianceThreshold
		let leveledOutCurrentWordArray = levelArrayOut(array: currentWordArrayAbsValue)
		let countAboveThreshold = getCountAboveThreshold(for: leveledOutCurrentWordArray, with: threshold)

		let speechInMS = (Double(countAboveThreshold) / currentWordRate) * 1000
		
		let calculatedWSD = speechInMS / Double(syllableCount)
		
		return calculatedWSD
	}
	
	// Takes in the audio file URL and returns the array of floats, rate, and frame count
	func loadAudioSignal(for audioURL: URL) -> (signal: [Float], rate: Double, frameCount: Int) {
		let file = try! AVAudioFile(forReading: audioURL)
		let format = AVAudioFormat(commonFormat: .pcmFormatFloat32, sampleRate: file.fileFormat.sampleRate, channels: file.fileFormat.channelCount, interleaved: false)!
		let buf = AVAudioPCMBuffer(pcmFormat: format, frameCapacity: UInt32(file.length))
		
		try? file.read(into: buf!)
		
		let floatArray = Array(UnsafeBufferPointer(start: buf?.floatChannelData![0], count:Int(buf!.frameLength)))
		return (signal: floatArray, rate: file.fileFormat.sampleRate, frameCount: Int(file.length))
	}
	
	// Takes in the file name and finds it in the system and then returns
	// the array of floats and rate for the word
	func getCurrentWordArrayAndRate(for fileName: String) -> ([Float], Double) {
		let urls = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
		
		let documentDirectory = urls as URL
		
		var documentDirectoryString = documentDirectory.absoluteString
		
		if (!fileName.hasPrefix("file://")) {
			let start = documentDirectoryString.index(documentDirectoryString.startIndex, offsetBy: 7)
			let end = documentDirectoryString.endIndex
			let range = start..<end
			documentDirectoryString = String(documentDirectoryString[range])
		}
		
		let wavFile = String(fileName.dropFirst(documentDirectoryString.count))
				
		let soundURL = documentDirectory.appendingPathComponent(wavFile)
		
		let currentMultisyllabicWordResponse = loadAudioSignal(for: soundURL)
		
		return (currentMultisyllabicWordResponse.signal, currentMultisyllabicWordResponse.rate)
	}
	
	// Takes in the ambiance recording file and returns the threshold for the ambiance
	func getAmbianceFileThreshold(fileName: String) -> Float {
		//get ambiance array
		let ambianceFileArray = getThresholdFileArray(fileName: fileName)
		
		//get threshold from the ambiance array
		let threshold = getThreshold(for: getAbsoluteValueArray(for: ambianceFileArray))
		
		//Set the ambiance threshold in the singleton to the calculated one
		ambianceThreshold = threshold
		return threshold
	}
	
	func getThresholdFileArray(fileName: String) -> [Float] {
		let response = getCurrentWordArrayAndRate(for: fileName)
		return response.0
	}
	
	func getAbsoluteValueArray(for originalArray: [Float]) -> [Float] {
		return originalArray.map { abs($0) }
	}
	
	// Levels out the float array
	func levelArrayOut(array: [Float]) -> [Float] {
		var leveledOutArray = array.map { $0 }
		
		for i in 20..<(array.count - 20) {
			let subArray = array[(i - 20)...(i + 20)]
			let maxInSubArray = subArray.max()!
			leveledOutArray[i] = maxInSubArray
		}
		
		return leveledOutArray
	}
	
	// Gets the threshold of the array that is passed in
	func getThreshold(for array: [Float]) -> Float {
		var arrayHere = array
		arrayHere.sort()
		return arrayHere[Int(0.992 * Double(arrayHere.count))]
	}
	
	// Gets the count of items in the array above the given threshold
	func getCountAboveThreshold(for array: [Float], with threshold: Float) -> Int {
		var count = 0
		for item in array {
			if item >= threshold {
				count += 1
			}
		}
		return count
	}
	
}
