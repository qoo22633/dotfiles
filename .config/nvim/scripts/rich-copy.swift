// HTML とプレーンテキストを両方クリップボードに入れる
// Slack などリッチテキストを受け付けるアプリには HTML、それ以外にはテキストが貼られる
//
// usage: swift rich-copy.swift <html> < plain.txt
import AppKit

let html = CommandLine.arguments[1]
let plain = String(decoding: FileHandle.standardInput.readDataToEndOfFile(), as: UTF8.self)

let pb = NSPasteboard.general
pb.clearContents()
pb.setString(html, forType: .html)
pb.setString(plain, forType: .string)
