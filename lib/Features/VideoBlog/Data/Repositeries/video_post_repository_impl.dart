import 'package:fpdart/fpdart.dart';
import 'package:blog_app/Core/Errors/exceptions.dart';
import 'package:blog_app/Core/Errors/failure.dart';
import 'package:blog_app/Features/VideoBlog/Data/DataSource/video_post_remote_data_source.dart';
import 'package:blog_app/Features/VideoBlog/Domain/Entities/video_post.dart';
import 'package:blog_app/Features/VideoBlog/Domain/Repositories/video_post_repository.dart';

class VideoPostRepositoryImpl implements VideoPostRepository {
  final VideoPostRemoteDataSource remoteDataSource;
  VideoPostRepositoryImpl(this.remoteDataSource);

  @override
  Future<Either<Failure, List<VideoPost>>> getAllVideoPosts() async {
    try {
      final posts = await remoteDataSource.getAllVideoPosts();
      return right(posts);
    } on ServerException catch (e) {
      return left(Failure(e.message));
    }
  }

  @override
  Future<Either<Failure, VideoPost>> createVideoPost({
    required String title,
    required String youtubeUrl,
    String? commentary,
    String? postedByName,
    String? postedById,
    String? posterAvatarUrl,
    String? visibilityCircleType,
    String? visibilityCircleId,
    bool isPublic = false,
  }) async {
    try {
      final post = await remoteDataSource.createVideoPost(
        title: title,
        youtubeUrl: youtubeUrl,
        commentary: commentary,
        postedByName: postedByName,
        postedById: postedById,
        posterAvatarUrl: posterAvatarUrl,
        visibilityCircleType: visibilityCircleType,
        visibilityCircleId: visibilityCircleId,
        isPublic: isPublic,
      );
      return right(post);
    } on ServerException catch (e) {
      return left(Failure(e.message));
    }
  }

  @override
  Future<Either<Failure, VideoPost>> updateVideoPost({
    required String id,
    required String title,
    required String youtubeUrl,
    String? commentary,
    String? visibilityCircleType,
    String? visibilityCircleId,
    bool isPublic = false,
  }) async {
    try {
      final post = await remoteDataSource.updateVideoPost(
        id: id,
        title: title,
        youtubeUrl: youtubeUrl,
        commentary: commentary,
        visibilityCircleType: visibilityCircleType,
        visibilityCircleId: visibilityCircleId,
        isPublic: isPublic,
      );
      return right(post);
    } on ServerException catch (e) {
      return left(Failure(e.message));
    }
  }

  @override
  Future<Either<Failure, Unit>> deleteVideoPost(String id) async {
    try {
      await remoteDataSource.deleteVideoPost(id);
      return right(unit);
    } on ServerException catch (e) {
      return left(Failure(e.message));
    }
  }

  @override
  Future<Either<Failure, VideoPost>> getVideoByIdPrefix(String idPrefix) async {
    try {
      final post = await remoteDataSource.getVideoByIdPrefix(idPrefix);
      return right(post);
    } on ServerException catch (e) {
      return left(Failure(e.message));
    }
  }
}
