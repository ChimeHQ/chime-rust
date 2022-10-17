import Foundation
import os.log

import ChimeKit
import ProcessServiceClient

public final class RustExtension {
	let host: any HostProtocol
	private let lspService: LSPService
	private let logger: Logger

	public init(host: any HostProtocol, processHostServiceName: String?) {
		self.host = host
		let logger = Logger(subsystem: "com.chimehq.ChimeRust", category: "RustExtension")
		self.logger = logger

		let filter = LSPService.contextFilter(for: [.rustSource], projectFiles: ["Cargo.toml"])
		let paramProvider = { try await RustExtension.provideParams(logger: logger, processHostService: processHostServiceName) }

		self.lspService = LSPService(host: host,
									 contextFilter: filter,
									 executionParamsProvider: paramProvider,
									 processHostServiceName: processHostServiceName)
	}
}

extension RustExtension {
	private static func provideParams(logger: Logger, processHostService: String?) async throws -> Process.ExecutionParameters {
		let userEnv: [String: String]

		if let processHostService = processHostService {
			userEnv = try await HostedProcess.userEnvironment(with: processHostService)
		} else {
			userEnv = ProcessInfo.processInfo.userEnvironment
		}

		let whichParams = Process.ExecutionParameters(path: "/usr/bin/which", arguments: ["rust-analyzer"], environment: userEnv)

		let data: Data

		if let processHostService = processHostService {
			let whichProcess = HostedProcess(named: processHostService, parameters: whichParams)

			data = try await whichProcess.runAndReadStdout()
		} else {
			let whichProcess = Process(parameters: whichParams)

			data = try whichProcess.runAndReadStdout() ?? Data()
		}

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


