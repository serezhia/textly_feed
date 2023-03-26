import 'dart:async';
import 'dart:io';

import 'package:dart_frog/dart_frog.dart';
import 'package:logger/logger.dart';
import 'package:textly_core/textly_core.dart';
import 'package:textly_feed/models/textly_response.dart';
import 'package:textly_feed/models/user_id_model.dart';

FutureOr<Response> onRequest(RequestContext context, String id) async {
  switch (context.request.method) {
    case HttpMethod.get:
      return _get(context, id);
    case HttpMethod.post:
    case HttpMethod.put:
    case HttpMethod.delete:
    case HttpMethod.head:
    case HttpMethod.options:
    case HttpMethod.patch:
      return Response(statusCode: HttpStatus.methodNotAllowed);
  }
}

FutureOr<Response> _get(RequestContext context, String id) async {
  final params = context.request.uri.queryParameters;

  final limit = int.tryParse(params['limit'] ?? '');
  final offset = int.tryParse(params['offset'] ?? '');

  final feedRepository = context.read<FeedRepository>();

  final userId = int.tryParse(id);
  final reqUserId = context.read<UserId>().userId;

  final uuid = context.read<String>();
  final logger = context.read<Logger>();

  if (limit == null) {
    return TextlyResponse.needMoreData(
      uuid: uuid,
      type: TypeNeedData.param,
      nameData: 'limit',
    );
  }
  if (offset == null) {
    return TextlyResponse.needMoreData(
      uuid: uuid,
      type: TypeNeedData.param,
      nameData: 'offest',
    );
  }
  if (reqUserId == null) {
    return TextlyResponse.needMoreData(
      uuid: uuid,
      type: TypeNeedData.param,
      nameData: '[id]',
    );
  }

  try {
    logger.d(
      '$uuid: Read personal feed, userId: $userId, reqUserId: $reqUserId',
    );
    final chunk = await feedRepository.readPersonalFeed(
      userId: reqUserId,
      offset: offset,
      limit: limit,
    );
    logger.d(
      '$uuid: Readed personal feed, userId: $userId, reqUserId: $reqUserId',
    );
    return TextlyResponse.success(
      uuid: uuid,
      message:
          'Success read personal feed userId: $userId, reqUserId: $reqUserId',
      data: chunk.toJson(),
    );
  } catch (e) {
    logger.e(
      '''$uuid: Error read personal feed , userId: $userId, reqUserId: $reqUserId''',
    );
    return TextlyResponse.error(
      uuid: uuid,
      statusCode: 500,
      message: 'Error read personal feed',
      error: '$e',
      errorCode: 0,
    );
  }
}
