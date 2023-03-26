import 'package:dart_frog/dart_frog.dart';

Response onRequest(RequestContext context) {
  return Response(body: 'Welcome to Dart Frog!');
}


/// textly.dev/api/feed/user/[id]/likes
/// textly.dev/api/feed/user/[id]/comments
/// textly.dev/api/feed/user/[id]/posts
/// textly.dev/api/feed/user/[id]/personal
/// textly.dev/api/feed/hot 
