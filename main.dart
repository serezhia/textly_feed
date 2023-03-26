import 'dart:io';

import 'package:dart_frog/dart_frog.dart';
import 'package:logger/logger.dart';
import 'package:postgres/postgres.dart';
import 'package:textly_core/textly_core.dart';
import 'package:textly_feed/data_sources/postgres_feed_data_source.dart';
import 'package:textly_feed/utils/env_utils.dart';
import 'package:textly_feed/utils/jwt_service.dart';

Future<HttpServer> run(Handler handler, InternetAddress ip, int port) async {
  final logger = Logger(
    filter: ProductionFilter(),
    printer: PrettyPrinter(
      methodCount: 0,
      noBoxingByDefault: true,
    ),
  );

  /// Подключаемся к БД
  final dbProfilesConection = PostgreSQLConnection(
    dbProfilesHost(),
    // '0.0.0.0',
    dbProfilesPort(),
    dbProfilesName(),
    username: dbProfilesUsername(),
    password: dbProfilesPassword(),
  );

  try {
    await dbProfilesConection.open();
    logger.i('Database profiles connect success');
  } catch (e) {
    logger.e('Error connecting to database profiles');
    Future.delayed(
      const Duration(seconds: 3),
      () => exit(1),
    );
  }

  /// Подключаемся к БД
  final dbPostsConection = PostgreSQLConnection(
    dbPostsHost(),
    // '0.0.0.0',
    dbPostsPort(),
    dbPostsName(),
    username: dbPostsUsername(),
    password: dbPostsPassword(),
  );

  try {
    await dbPostsConection.open();
    logger.i('Database posts connect success');
  } catch (e) {
    logger.e('Error connecting to database posts');
    Future.delayed(
      const Duration(seconds: 3),
      () => exit(1),
    );
  }

  final jwtService = JwtServiceImpl();
  final feedRepository = PostgresFeedDataSource(
    postConnection: dbPostsConection,
    profileConnection: dbProfilesConection,
  );

  final newHandler = handler
      .use(
        provider<Logger>(
          (context) => logger,
        ),
      )
      .use(
        provider<FeedRepository>(
          (context) => feedRepository,
        ),
      )
      .use(
        provider<JwtService>(
          (context) => jwtService,
        ),
      );

  return serve(
    newHandler,
    // 'localhost',
    // 2005,
    serviceHost(),
    servicePort(),
  );
}
