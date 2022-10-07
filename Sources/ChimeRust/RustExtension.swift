import Foundation
import os.log

import ChimeKit
import ProcessServiceClient

public final class RustExtension {
	private static let processHostService: String = "com.chimehq.ChimeKit.ProcessService"

	let host: any HostProtocol
	private let lspService: LSPService
	private let logger: Logger

	public init(host: any HostProtocol) {
		self.host = host
		self.logger = Logger(subsystem: "com.chimehq.ChimeRust", category: "RustExtension")

		let filter = LSPService.contextFilter(for: [.rustSource], projectFiles: ["Cargo.toml"])

		self.lspService = LSPService(host: host,
									 contextFilter: filter,
									 executionParamsProvider: RustExtension.provideParams,
									 processHostServiceName: nil)
	}
}

extension RustExtension {
	private static func provideParams() async throws -> Process.ExecutionParameters {
		let userEnv = try await HostedProcess.userEnvironment(with: RustExtension.processHostService)

		let whichParams = Process.ExecutionParameters(path: "/usr/bin/which", arguments: ["rust-analyzer"], environment: userEnv)

		let whichProcess = HostedProcess(named: RustExtension.processHostService, parameters: whichParams)

		let data = try await whichProcess.runAndReadStdout()

		guard let output = String(data: data, encoding: .utf8) else {
			throw LSPServiceError.serverNotFound
		}

		if output.isEmpty {
			throw LSPServiceError.serverNotFound
		}

		let path = output.trimmingCharacters(in: .whitespacesAndNewlines)

		print("found analyzer at: ", path)

		return .init(path: path, environment: userEnv)
	}
}

extension RustExtension: ExtensionProtocol {
	public func didOpenProject(with context: ProjectContext) async throws {
		try await lspService.didOpenProject(with: context)
	}

	public func willCloseProject(with context: ProjectContext) async throws {
		try await lspService.willCloseProject(with: context)
	}

	public func symbolService(for context: ProjectContext) async throws -> SymbolQueryService? {
		return try await lspService.symbolService(for: context)
	}

	public func didOpenDocument(with context: DocumentContext) async throws -> URL? {
		return try await lspService.didOpenDocument(with: context)
	}

	public func didChangeDocumentContext(from oldContext: DocumentContext, to newContext: DocumentContext) async throws {
		return try await lspService.didChangeDocumentContext(from: oldContext, to: newContext)
	}

	public func willCloseDocument(with context: DocumentContext) async throws {
		return try await lspService.willCloseDocument(with: context)
	}

	public func documentService(for context: DocumentContext) async throws -> DocumentService? {
		return try await lspService.documentService(for: context)
	}
}


