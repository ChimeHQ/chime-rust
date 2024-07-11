import Foundation

import ChimeKit

@MainActor
public final class RustExtension {
	private let lspService: LSPService

	public init(host: any HostProtocol) {
		self.lspService = LSPService(
			host: host,
			executableName: "rust-analyzer"
		)
	}
}

extension RustExtension: ExtensionProtocol {
	public var configuration: ExtensionConfiguration {
		get throws {
			return ExtensionConfiguration(documentFilter: [.uti(.rustSource)],
										  directoryContentFilter: [.uti(.rustSource), .fileName("Cargo.toml")])
		}
	}
	
	public var applicationService: some ApplicationService {
		lspService
	}
}
