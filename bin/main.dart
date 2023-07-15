import 'dart:io';

import 'package:args/args.dart';
import 'package:yaml/yaml.dart' as yaml;

void main(List<String> arguments) {
  final parser = ArgParser();

  parser.addCommand('generate');

  final argResults = parser.parse(arguments);

  if (argResults.command?.name == 'generate' &&
      argResults.command?.rest.length == 2) {
    final pathWhereGenerateFolders = argResults.command?.rest[0];
    final templatePath = argResults.command?.rest[1];

    generateTemplateFromYaml(templatePath!, pathWhereGenerateFolders!);
  } else {
    print('Comando non valido.');
    printUsage(parser);
  }
}

bool checkCommand(ArgResults argResults) {
  if (argResults.rest.length < 2) {
    return false;
  }
  return true;
}

void printUsage(ArgParser parser) {
  print(
      'Utilizzo: templategenerator generate <pathWhereGenerateFolders> <templatePath>');
  print('');
  print(parser.usage);
}

void generateTemplateFromYaml(String yamlFilePath, String outputPath) {
  final fileContent = File(yamlFilePath).readAsStringSync();
  final yamlData = yaml.loadYaml(fileContent);

  generateFromYamlData(yamlData, outputPath);
}

void generateFromYamlData(dynamic yamlData, String currentPath) {
  if (yamlData is List) {
    for (var item in yamlData) {
      generateFromYamlData(item, currentPath);
    }
  } else if (yamlData is Map) {
    final name = yamlData['name'];
    final type = yamlData['type'];
    final children = yamlData['children'];

    final newPath = "$currentPath/$name";

    if (type == 'directory') {
      Directory(newPath).createSync(recursive: true);
      if (children != null) {
        generateFromYamlData(children, newPath);
      }
    } else if (type == 'file') {
      final content = yamlData['content'];
      final file = File(newPath);
      file.createSync(recursive: true);
      if (content != null) {
        file.writeAsStringSync(content);
      }
    }
  }
}
