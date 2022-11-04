import Foundation

import ChimeKit

public final class RustExtension {
	private let lspService: LSPService

	public init(host: any HostProtocol, processHostServiceName: String) {
		let filter = LSPService.contextFilter(for: [.rustSource], projectFiles: ["Cargo.toml"])

		self.lspService = LSPService(host: host,
									 contextFilter: filter,
									 executableName: "rust-analyzer",
									 processHostServiceName: processHostServiceName,
									 logMessages: true)
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
