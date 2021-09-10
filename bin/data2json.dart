// ignore_for_file: avoid_print
/// A script for turning data files into code via a JSON file.
import 'dart:io';

import 'package:args/command_runner.dart';
import 'package:ziggurat/ziggurat.dart' show DataFile, DataFileEntry;

/// The command runner for listing files in a data file.
class LsCommand extends Command<void> {
  @override
  final String name = 'ls';
  @override
  final String description = 'List files in a data file.';
  @override
  void run() {
    final results = argResults;
    if (results != null) {
      final rest = results.rest;
      if (rest.isEmpty) {
        print('You must provide at least one filename.\n');
        print('Usage: ${runner?.executableName} <filename>');
      } else {
        for (final filename in rest) {
          final file = File(filename);
          if (file.existsSync()) {
            print('--- $filename ---');
            final dataFile = DataFile.fromFile(file);
            if (dataFile.entries.isEmpty) {
              print('No files to show.');
            } else {
              for (final entry in dataFile.entries) {
                print('${entry.variableName}: ${entry.comment}');
                print('Filename: ${entry.fileName}');
              }
            }
          } else {
            print('Could not show the contents of $filename: '
                'File does not exist.');
          }
        }
      }
    }
  }
}

/// The command that creates a new data file.
class CreateCommand extends Command<void> {
  /// Create an instance.
  CreateCommand() {
    argParser.addOption('comment',
        abbr: 'c',
        help: 'The comment to put at the top of the resulting Dart file');
  }
  @override
  final String name = 'create';
  @override
  final String description = 'Create a new data file.';
  @override
  void run() {
    final results = argResults;
    if (results != null) {
      if (results.rest.isEmpty) {
        print('You must provide at least one filename to create.\n');
        print('Usage: ${runner?.executableName} <filename>');
      } else {
        final dataFile = DataFile(comment: results['comment'] as String?);
        for (final filename in results.rest) {
          final file = File(filename);
          if (file.existsSync()) {
            print('File $filename already exists.');
          } else {
            dataFile.dump(file);
            print('Created file $filename.');
          }
        }
      }
    }
  }
}

/// A command for adding files to a data file.
class AddFileCommand extends Command<void> {
  /// Create the instance.
  AddFileCommand() {
    argParser
      ..addOption('filename',
          abbr: 'f', help: 'The name of the file to add', mandatory: true)
      ..addOption('variable',
          abbr: 'v',
          help: 'The name of the resulting dart variable',
          mandatory: true)
      ..addOption('comment',
          abbr: 'c',
          help: 'The comment to show above the variable declaration');
  }
  @override
  final String name = 'add';
  @override
  final String description = 'Add a file to a data file.';
  @override
  void run() {
    final results = argResults;
    if (results != null) {
      if (results.rest.length != 1) {
        print('You must provide exactly one filename.');
      } else {
        final filename = results['filename'] as String;
        final variableName = results['variable'] as String;
        final comment = results['comment'] as String?;
        final file = File(results.rest.first);
        if (file.existsSync()) {
          final dataFile = DataFile.fromFile(file);
          dataFile.entries
              .add(DataFileEntry(variableName, filename, comment: comment));
          dataFile.dump(file);
          print('Added file $filename.');
        } else {
          print('Error: ${file.path} does not exist.');
        }
      }
    }
  }
}

/// A command for changing the comment in a data file entry.
class CommentCommand extends Command<void> {
  /// Create an instance.
  CommentCommand() {
    argParser.addOption('comment',
        abbr: 'c', help: 'The new comment for the entry');
  }
  @override
  final String name = 'comment';
  @override
  final String description = 'Change the comment for an entry.';

  @override
  void run() {
    final results = argResults;
    if (results != null) {
      if (results.rest.length != 2) {
        print('Usage: ${runner?.executableName} $name <json-filename> '
            '<variableName>');
      } else {
        final filename = results.rest.first;
        final variableName = results.rest.last;
        final file = File(filename);
        if (file.existsSync()) {
          final dataFile = DataFile.fromFile(file);
          for (final entry in dataFile.entries) {
            if (entry.variableName == variableName) {
              entry.comment = results['comment'] as String?;
              dataFile.dump(file);
              print(
                  'Comment ${entry.comment == null ? "cleared" : "changed"}.');
              return;
            }
          }
          print('Variable $variableName not found.');
        } else {
          print('File $filename does not exist.');
        }
      }
    }
  }
}

/// A command for removing a file from a [DataFile] instance.
class RemoveFileCommand extends Command<void> {
  @override
  final String name = 'remove';
  @override
  final String description = 'Remove a file.';
  @override
  void run() {
    final results = argResults;
    if (results != null) {
      if (results.rest.length != 2) {
        print('Usage: ${runner?.executableName} $name <json-filename> '
            '<variable-name>');
      } else {
        final file = File(results.rest.first);
        if (file.existsSync()) {
          final dataFile = DataFile.fromFile(file);
          DataFileEntry? toRemove;
          for (final entry in dataFile.entries) {
            if (entry.variableName == results.rest.last) {
              toRemove = entry;
            }
          }
          if (toRemove == null) {
            print('No variable named ${results.rest.last} found.');
          } else {
            dataFile.entries.remove(toRemove);
            dataFile.dump(file);
            print('Done.');
          }
        } else {
          print('Json file ${file.path} does not exist.');
        }
      }
    }
  }
}

/// A command for converting a [DataFile] to dart code.
class CompileCommand extends Command<void> {
  @override
  final String name = 'compile';
  @override
  final String description = 'Convert a JSON file to Dart code.';
  @override
  void run() {
    final results = argResults;
    if (results != null) {
      if (results.rest.length != 2) {
        print('Usage: ${runner?.executableName} $name <json-filename> '
            '<dart-filename>');
      } else {
        final jsonFilename = results.rest.first;
        final dartFilename = results.rest.last;
        final jsonFile = File(jsonFilename);
        if (jsonFile.existsSync()) {
          final dartFile = File(dartFilename);
          if (dartFile.existsSync()) {
            print('Dart file $dartFilename already exists.');
          } else {
            final dataFile = DataFile.fromFile(jsonFile);
            var comment = dataFile.comment;
            final stringBuffer = StringBuffer()
              ..writeln(
                  '/// Automatically generated from $jsonFilename, do not edit.');
            if (comment != null) {
              for (final line in comment.split('\n')) {
                stringBuffer.writeln('/// $line');
              }
              stringBuffer.writeln();
            }
            for (final entry in dataFile.entries) {
              final file = File(entry.fileName);
              if (file.existsSync()) {
                final data = file.readAsBytesSync().join(',\n  ');
                comment = entry.comment;
                if (comment != null) {
                  for (final line in comment.split('\n')) {
                    stringBuffer.writeln('/// $line');
                  }
                }
                stringBuffer
                  ..writeln('const ${entry.variableName} = [')
                  ..writeln('  $data')
                  ..writeln('];')
                  ..writeln();
              } else {
                print('File ${entry.fileName} does not exist.');
              }
            }
            dartFile.writeAsStringSync(stringBuffer.toString());
            print('Wrote file $dartFilename.');
          }
        } else {
          print('JSON file $jsonFilename does not exist.');
        }
      }
    }
  }
}

Future<void> main(List<String> args) async {
  final command = CommandRunner<void>(
      'data2json',
      'Convert data files into code via json.\n\n'
          'It is first necessary to create a file:\n'
          '  `data2json create music.json -c "Music to be loaded from code."`\n\n'
          'Then you can add files to the collection with the `add command`.')
    ..addCommand(CreateCommand())
    ..addCommand(AddFileCommand())
    ..addCommand(CommentCommand())
    ..addCommand(RemoveFileCommand())
    ..addCommand(LsCommand())
    ..addCommand(CompileCommand());
  try {
    await command.run(args);
  } on UsageException catch (e) {
    print(e);
  }
}
