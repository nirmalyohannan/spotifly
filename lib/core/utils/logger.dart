import 'dart:developer';

import 'package:chalkdart/chalkdart.dart';
import 'package:dio/dio.dart';

class Logger {
  static Chalk chalk = Chalk();

  /// Error level logging
  static void e(String message) {
    log(chalk.red(message));
  }

  /// Info level logging
  static void i(String message) {
    log(chalk.green(message));
  }

  /// Success level logging
  static void s(String message) {
    log(chalk.green(message));
  }

  /// Warning level logging
  static void w(String message) {
    log(chalk.yellow(message));
  }

  static void apiRequest(RequestOptions options, {String? message}) {
    var time = DateTime.now();
    var formattedTime =
        '${time.hour}:${time.minute}:${time.second}.${time.millisecond}';
    log(
      "${chalk.bold("$formattedTime:")} | ${chalk.rebeccaPurple(options.method)} | ${chalk.blue(options.path)} | ${chalk.redBright(message ?? "")}",
    );
  }
}
