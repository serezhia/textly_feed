// ignore_for_file: public_member_api_docs

import 'package:postgres/postgres.dart';
import 'package:textly_core/textly_core.dart';

class PostgresFeedDataSource implements FeedRepository {
  PostgresFeedDataSource({
    required this.postConnection,
    required this.profileConnection,
  });

  final PostgreSQLConnection postConnection;
  final PostgreSQLConnection profileConnection;

  @override
  Future<PostsChunk> readHotFeed({
    required int offset,
    required int limit,
    int? reqUserId,
  }) async {
    final postsIdFromDB = await postConnection.mappedResultsQuery(
      '''
      SELECT post_id
      FROM posts
      WHERE created_at > @date AND is_delete IS NOT NULL
      ORDER BY likes DESC
			OFFSET @offset
			LIMIT @limit
      ''',
      substitutionValues: {
        'date': DateTime(
          DateTime.now().year,
          DateTime.now().month,
          DateTime.now().day,
        ).subtract(const Duration(days: 1)),
        'offset': offset,
        'limit': limit,
      },
    );
    final posts = <Post>[];
    final profilesId = <int>{};

    /// Получаем каждый пост
    for (final postId in postsIdFromDB) {
      final post = await _getPost(
        postId: postId['posts']?['post_id'] as int? ?? -1,
        reqUserId: reqUserId,
      );

      if (post != null) {
        posts.add(post);

        //Записываем id юзера в массив
        profilesId.add(post.userId ?? -1);
      }
    }
    final profiles = <Profile>[];

    /// Получаем каждого юзера
    for (final profileId in profilesId) {
      final profile = await _getProfile(
        userId: profileId,
        reqUserId: reqUserId,
      );

      if (profile != null) {
        profiles.add(profile);
      }
    }

    return PostsChunk(
      posts: posts,
      profiles: profiles,
      endOfList: postsIdFromDB.length < limit,
    );
  }

  @override
  Future<PostsChunk> readPersonalFeed({
    required int userId,
    required int offset,
    required int limit,
  }) async {
    final usersIdFollowingFromDB = await profileConnection.mappedResultsQuery(
      '''
      SELECT publishing_user_id
      FROM user_relationships
      WHERE reading_user_id = @user_id
      ''',
      substitutionValues: {
        'user_id': userId,
      },
    );
    final usersIdFollowing = <int>[];
    for (final usersId in usersIdFollowingFromDB) {
      usersIdFollowing
          .add(usersId['user_relationships']!['publishing_user_id'] as int);
    }
    if (usersIdFollowing.isEmpty) {
      return const PostsChunk(posts: [], profiles: [], endOfList: true);
    }

    final postIdFromDB = await postConnection.mappedResultsQuery(
      '''
      SELECT post_id
      FROM posts
      WHERE user_id IN (${usersIdFollowing.toString().substring(1, usersIdFollowing.toString().length - 1)}) AND is_delete = false
      ORDER BY post_id DESC
			OFFSET @offset
			LIMIT @limit
      ''',
      substitutionValues: {
        'offset': offset,
        'limit': limit,
      },
    );

    final posts = <Post>[];
    final profilesId = <int>{};

    /// Получаем каждый пост
    for (final postId in postIdFromDB) {
      final post = await _getPost(
        postId: postId['posts']?['post_id'] as int? ?? -1,
        reqUserId: userId,
      );

      if (post != null) {
        posts.add(post);

        //Записываем id юзера в массив
        profilesId.add(post.userId ?? -1);
      }
    }
    final profiles = <Profile>[];

    /// Получаем каждого юзера
    for (final profileId in profilesId) {
      final profile = await _getProfile(
        userId: profileId,
        reqUserId: userId,
      );

      if (profile != null) {
        profiles.add(profile);
      }
    }

    return PostsChunk(
      posts: posts,
      profiles: profiles,
      endOfList: postIdFromDB.length < limit,
    );
  }

  @override
  Future<PostsChunk> readUserComments({
    required int userId,
    required int offset,
    required int limit,
    int? reqUserId,
  }) async {
    /// Ищем юзера
    final profileFromDb =
        await _getProfile(userId: userId, reqUserId: reqUserId) ??
            Profile(
              userId: -1,
              username: 'error',
              profileName: 'error',
              avatar: 'e',
              backgroundColor: '00000000',
              isPremium: false,
              isDelete: true,
            );

    /// Если юзер нас заблокировал то отправляем пустые посты
    if (profileFromDb.isUnavailable ?? false) {
      return const PostsChunk(posts: [], endOfList: true);
    }

    /// Ищем id постов
    final usersPostsFromDB = await postConnection.mappedResultsQuery(
      '''
      SELECT post_id
      FROM posts
      WHERE user_id = @user_id AND parent_post_id IS NOT NULL AND is_delete = false
      ORDER BY post_id DESC
			OFFSET @offset
			LIMIT @limit
      ''',
      substitutionValues: {
        'offset': offset,
        'limit': limit,
        'user_id': userId,
      },
    );
    final posts = <Post>[];

    /// Получаем каждый пост
    for (final postId in usersPostsFromDB) {
      final post = await _getPost(
        postId: postId['posts']?['post_id'] as int? ?? -1,
        reqUserId: reqUserId,
      );

      if (post != null) {
        posts.add(post);
      }
    }
    return PostsChunk(
      posts: posts,
      profiles: [profileFromDb],
      endOfList: usersPostsFromDB.length < limit,
    );
  }

  @override
  Future<PostsChunk> readUserLikedPosts({
    required int userId,
    required int offset,
    required int limit,
    int? reqUserId,
  }) async {
    /// Ищем юзера
    final profileFromDb =
        await _getProfile(userId: userId, reqUserId: reqUserId) ??
            Profile(
              userId: -1,
              username: 'error',
              profileName: 'error',
              avatar: 'e',
              backgroundColor: '00000000',
              isPremium: false,
              isDelete: true,
            );

    /// Если юзер нас заблокировал то отправляем пустые посты
    if (profileFromDb.isUnavailable ?? false) {
      return const PostsChunk(posts: [], endOfList: true);
    }

    /// Ищем id постов
    final usersPostsFromDB = await postConnection.mappedResultsQuery(
      '''
      SELECT posts.post_id
      FROM posts, likes
      WHERE likes.user_id = @user_id AND posts.post_id = likes.post_id AND posts.is_delete = false
      ORDER BY post_id DESC
			OFFSET @offset
			LIMIT @limit
      ''',
      substitutionValues: {
        'offset': offset,
        'limit': limit,
        'user_id': userId,
      },
    );
    final posts = <Post>[];

    /// Получаем каждый пост
    for (final postId in usersPostsFromDB) {
      final post = await _getPost(
        postId: postId['posts']?['post_id'] as int? ?? -1,
        reqUserId: reqUserId,
      );

      if (post != null) {
        posts.add(post);
      }
    }
    return PostsChunk(
      posts: posts,
      profiles: [profileFromDb],
      endOfList: usersPostsFromDB.length < limit,
    );
  }

  @override
  Future<PostsChunk> readUserPosts({
    required int userId,
    required int offset,
    required int limit,
    int? reqUserId,
  }) async {
    /// Ищем юзера
    final profileFromDb =
        await _getProfile(userId: userId, reqUserId: reqUserId) ??
            Profile(
              userId: -1,
              username: 'error',
              profileName: 'error',
              avatar: 'e',
              backgroundColor: '00000000',
              isPremium: false,
              isDelete: true,
            );

    /// Если юзер нас заблокировал то отправляем пустые посты
    if (profileFromDb.isUnavailable ?? false) {
      return const PostsChunk(posts: [], endOfList: true);
    }

    /// Ищем id постов
    final usersPostsFromDB = await postConnection.mappedResultsQuery(
      '''
      SELECT post_id
      FROM posts
      WHERE posts.user_id = @user_id AND parent_post_id IS NULL AND is_delete = false
      ORDER BY post_id DESC
			OFFSET @offset
			LIMIT @limit
      ''',
      substitutionValues: {
        'offset': offset,
        'limit': limit,
        'user_id': userId,
      },
    );
    final posts = <Post>[];

    /// Получаем каждый пост
    for (final postId in usersPostsFromDB) {
      final post = await _getPost(
        postId: postId['posts']?['post_id'] as int? ?? -1,
        reqUserId: reqUserId,
      );

      if (post != null) {
        posts.add(post);
      }
    }
    return PostsChunk(
      posts: posts,
      profiles: [profileFromDb],
      endOfList: usersPostsFromDB.length < limit,
    );
  }

  Future<Post?> _getPost({required int postId, int? reqUserId}) async {
    final response = await postConnection.mappedResultsQuery(
      '''
          SELECT *
          ${reqUserId == null ? " " : ",(SELECT EXISTS (SELECT * FROM likes WHERE likes.user_id = @req_user_id AND likes.post_id= @post_id )) as  is_liked"}
          FROM posts ${reqUserId == null ? "" : ",likes"}
          WHERE posts.post_id = @post_id
          ''',
      substitutionValues: {
        'post_id': postId,
        'req_user_id': reqUserId,
      },
    );

    final isLiked = response.first['']?['is_liked'] as bool?;

    if (response.first['posts']?.isEmpty ?? false) {
      return null;
    }

    return Post.fromPostgres(response.first['posts'] ?? {}).copyWith(
      isLiked: isLiked,
    );
  }

  Future<Profile?> _getProfile({required int userId, int? reqUserId}) async {
    final response = await profileConnection.mappedResultsQuery(
      '''
        SELECT *
		      ${reqUserId == null ? '' : ', (SELECT EXISTS (SELECT * FROM user_relationships WHERE user_relationships.publishing_user_id = user_id AND user_relationships.reading_user_id = @req_user_id )) as  is_follow'}
		      ${reqUserId == null ? '' : ', (SELECT EXISTS (SELECT * FROM blacklist_user WHERE blacklist_user.requester_user_id = @req_user_id  AND blacklist_user.blocked_user_id = user_id)) as  is_blocked'}
		      ${reqUserId == null ? '' : ', (SELECT EXISTS (SELECT * FROM blacklist_user WHERE blacklist_user.requester_user_id = user_id AND blacklist_user.blocked_user_id = @req_user_id)) as  is_unavailable'}
        FROM profiles
        WHERE user_id = @user_id
        ''',
      substitutionValues: {
        'user_id': userId,
        'req_user_id': reqUserId,
      },
    );
    if (response.isEmpty) {
      return null;
    }
    final profile = Profile.fromPostgres(
      response.first['profiles'] ??
          Profile(
            userId: -1,
            username: 'error',
            profileName: 'error',
            avatar: 'e',
            backgroundColor: '00000000',
            isPremium: false,
            isDelete: false,
          ).toJson(),
    );

    final isFollow = (response.first[''])?['is_follow'] as bool?;
    final isBlocked = (response.first[''])?['is_blocked'] as bool?;
    final isUnavailable = (response.first[''])?['is_unavailable'] as bool?;

    if (isUnavailable ?? false) {
      return Profile(
        userId: userId,
        username: profile.username,
        profileName: profile.profileName,
        avatar: profile.avatar,
        backgroundColor: profile.backgroundColor,
        isPremium: profile.isPremium,
        isDelete: false,
        isUnavailable: isUnavailable,
        isBlocked: isBlocked,
      );
    }
    return profile.copyWith(
      isFollow: isFollow,
      isUnavailable: isUnavailable,
      isBlocked: isBlocked,
    );
  }
}
