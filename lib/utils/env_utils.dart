// ignore_for_file: public_member_api_docs

import 'dart:io';

import 'package:dotenv/dotenv.dart';

final env = DotEnv(includePlatformEnvironment: true)..load(['../.env']);

const String nameService = 'FEED';

String secretKey() {
  if (env['SECRET_KEY'] == null) {
    return Platform.environment['SECRET_KEY'] ?? 'secret';
  } else {
    return env['SECRET_KEY']!;
  }
}

int servicePort() {
  if (env['${nameService}_PORT'] == null) {
    return int.parse(
      Platform.environment['${nameService}_PORT'] ?? '2005',
    );
  } else {
    return int.parse(env['${nameService}_PORT']!);
  }
}

String serviceHost() {
  if (env['${nameService}_HOST'] == null) {
    return Platform.environment['${nameService}_HOST'] ?? '0.0.0.0';
  } else {
    return env['${nameService}_HOST']!;
  }
}

int dbProfilesPort() {
  if (env['PROFILES_DATABASE_PORT'] == null) {
    return int.parse(
      Platform.environment['PROFILES_DATABASE_PORT'] ?? '2022',
    );
  } else {
    return int.parse(env['PROFILES_DATABASE_PORT']!);
  }
}

String dbProfilesHost() {
  if (env['PROFILES_DATABASE_HOST'] == null) {
    return Platform.environment['PROFILES_DATABASE_HOST'] ?? '0.0.0.0';
  } else {
    return env['PROFILES_DATABASE_HOST']!;
  }
}

String dbProfilesName() {
  if (env['PROFILES_DATABASE_NAME'] == null) {
    return Platform.environment['PROFILES_DATABASE_NAME'] ?? 'textly_profiles';
  } else {
    return env['PROFILES_DATABASE_NAME']!;
  }
}

String dbProfilesUsername() {
  if (env['PROFILES_DATABASE_USERNAME'] == null) {
    return Platform.environment['PROFILES_DATABASE_USERNAME'] ?? 'admin';
  } else {
    return env['PROFILES_DATABASE_USERNAME']!;
  }
}

String dbProfilesPassword() {
  if (env['PROFILES_DATABASE_PASSWORD'] == null) {
    return Platform.environment['PROFILES_DATABASE_PASSWORD'] ?? 'pass';
  } else {
    return env['PROFILES_DATABASE_PASSWORD']!;
  }
}

int dbPostsPort() {
  if (env['POSTS_DATABASE_PORT'] == null) {
    return int.parse(
      Platform.environment['POSTS_DATABASE_PORT'] ?? '2044',
    );
  } else {
    return int.parse(env['POSTS_DATABASE_PORT']!);
  }
}

String dbPostsHost() {
  if (env['POSTS_DATABASE_HOST'] == null) {
    return Platform.environment['POSTS_DATABASE_HOST'] ?? '0.0.0.0';
  } else {
    return env['POSTS_DATABASE_HOST']!;
  }
}

String dbPostsName() {
  if (env['POSTS_DATABASE_NAME'] == null) {
    return Platform.environment['POSTS_DATABASE_NAME'] ?? 'textly_posts';
  } else {
    return env['POSTS_DATABASE_NAME']!;
  }
}

String dbPostsUsername() {
  if (env['POSTS_DATABASE_USERNAME'] == null) {
    return Platform.environment['POSTS_DATABASE_USERNAME'] ?? 'admin';
  } else {
    return env['POSTS_DATABASE_USERNAME']!;
  }
}

String dbPostsPassword() {
  if (env['POSTS_DATABASE_PASSWORD'] == null) {
    return Platform.environment['POSTS_DATABASE_PASSWORD'] ?? 'pass';
  } else {
    return env['POSTS_DATABASE_PASSWORD']!;
  }
}
