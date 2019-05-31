import 'dart:async';

import 'package:dart_language_server/dart_language_server.dart' as lsp;
import 'package:dart_language_server/src/protocol/language_server/interface.dart'
    as lsp;
import 'package:dart_language_server/src/protocol/language_server/messages.dart'
    as lsp;
import 'package:dart_language_server/src/protocol/language_server/wireformat.dart'
    as lsp;

/// https://microsoft.github.io/language-server-protocol/specification
/// https://blog.getgauge.io/gauge-and-the-language-server-protocol-c56fbcfba177
/// https://vscode.readthedocs.io/en/latest/extensions/example-language-server/
class DonLangServer extends lsp.LanguageServer {
  void _makeCapabilties(lsp.ServerCapabilities$Builder b) {
    b.textDocumentSync = lsp.TextDocumentSyncOptions((b) => b
      ..openClose = true
      ..change = lsp.TextDocumentSyncKind.full
      ..willSave = false
      ..willSaveWaitUntil = false
      ..save = lsp.SaveOptions((b) {
        b..includeText = false;
      }));

    /* TODO
    b.completionProvider = lsp.CompletionOptions((b) => b
      ..resolveProvider = false
      ..triggerCharacters = const ['.']);
     */

    // A code lens represents a command that should be shown along with source
    // text, like the number of references, a way to run tests, etc.
    b.codeLensProvider = lsp.CodeLensOptions((b) {
      b..resolveProvider = true;
    });

    b
      ..definitionProvider = true
      ..documentSymbolProvider = true
      ..hoverProvider = true
      ..referencesProvider = true
      ..documentFormattingProvider = true;
  }

  @override
  Future<lsp.ServerCapabilities> initialize(int clientPid, String rootUri,
      lsp.ClientCapabilities clientCapabilities, String trace) async {
    return lsp.ServerCapabilities(_makeCapabilties);
  }

  @override
  // Future that is completed when the server is exiting
  Future<void> get onDone {
    // TODO
  }

  @override
  Stream<lsp.ShowMessageParams> get showMessages {
    // TODO
  }

  @override
  Stream<lsp.ApplyWorkspaceEditParams> get workspaceEdits {
    // TODO
  }

  @override
  Stream<lsp.Diagnostics> get diagnostics {
    // TODO implement
  }

  @override
  Future<lsp.WorkspaceEdit> textDocumentRename(
      lsp.TextDocumentIdentifier documentId,
      lsp.Position position,
      String newName) {
    // TODO implement
  }

  @override
  Future<void> workspaceExecuteCommand(
      String command, List<dynamic> arguments) async {
    // Do nothing!
  }

  @override
  Future<List<dynamic>> textDocumentCodeAction(
      lsp.TextDocumentIdentifier documentId,
      lsp.Range range,
      lsp.CodeActionContext context) {
    // TODO
  }

  @override
  Future<dynamic> textDocumentHover(
      lsp.TextDocumentIdentifier documentId, lsp.Position position) {
    // TODO implement
    // return [HoverMarkup] or [Hover]
  }

  @override
  /// Lists all symbols in the workspace
  Future<List<lsp.SymbolInformation>> workspaceSymbol(String query) {
    // TODO implement
  }

  @override
  /// Lists all symbols in the text document
  Future<List<lsp.SymbolInformation>> textDocumentSymbols(
      lsp.TextDocumentIdentifier documentId) {
    // TODO implement
  }

  @override
  /// Provides ability to highlight similar occurrences in the text document
  Future<List<lsp.DocumentHighlight>> textDocumentHighlight(
      lsp.TextDocumentIdentifier documentId, lsp.Position position) {
    // TODO implement
  }

  @override
  /// Returns the implementation location of the symbol under the cursor
  Future<List<lsp.Location>> textDocumentImplementation(
      lsp.TextDocumentIdentifier documentId, lsp.Position position) {
    // Do nothing
  }

  @override
  /// Returns the locations where the symbol under the cursor is references
  Future<List<lsp.Location>> textDocumentReferences(
      lsp.TextDocumentIdentifier documentId,
      lsp.Position position,
      lsp.ReferenceContext context) {
    // TODO implement
  }

  @override
  /// Returns the location where the symbol under the cursor is defined
  Future<lsp.Location> textDocumentDefinition(
      lsp.TextDocumentIdentifier documentId, lsp.Position position) {
    // TODO implement
  }

  @override
  /// Returns completion suggestions
  Future<lsp.CompletionList> textDocumentCompletion(
      lsp.TextDocumentIdentifier documentId, lsp.Position position) {
    // TODO implement
  }

  @override
  void initialized() {}

  @override
  void textDocumentDidOpen(lsp. TextDocumentItem document) {
    // TODO implement
  }

  @override
  void textDocumentDidChange(lsp.VersionedTextDocumentIdentifier documentId,
      List<lsp.TextDocumentContentChangeEvent> changes) {
    // TODO implement
  }

  @override
  void textDocumentDidClose(lsp.TextDocumentIdentifier documentId) {
    // TODO implement
  }
}
