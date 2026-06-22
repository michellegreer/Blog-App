import 'package:blog_app/Core/Errors/exceptions.dart';
import 'package:blog_app/Features/VideoBlog/Data/Models/video_post_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

abstract interface class VideoPostRemoteDataSource {
  Future<List<VideoPostModel>> getAllVideoPosts();
  Future<VideoPostModel> createVideoPost({
    required String title,
    required String youtubeUrl,
    String? commentary,
    String? postedByName,
    String? postedById,
    String? posterAvatarUrl,
  });
  Future<VideoPostModel> updateVideoPost({
    required String id,
    required String title,
    required String youtubeUrl,
    String? commentary,
  });
  Future<void> deleteVideoPost(String id);
  Future<VideoPostModel> getVideoByIdPrefix(String idPrefix);
}

class VideoPostRemoteDataSourceImpl implements VideoPostRemoteDataSource {
  final SupabaseClient supabaseClient;
  VideoPostRemoteDataSourceImpl(this.supabaseClient);

  @override
  Future<List<VideoPostModel>> getAllVideoPosts() async {
    try {
      final response = await supabaseClient
          .from('video_posts')
          .select()
          .order('created_at', ascending: false);
      return response.map((json) => VideoPostModel.fromJson(json)).toList();
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<VideoPostModel> createVideoPost({
    required String title,
    required String youtubeUrl,
    String? commentary,
    String? postedByName,
    String? postedById,
    String? posterAvatarUrl,
  }) async {
    try {
      final response = await supabaseClient
          .from('video_posts')
          .insert({
            'title': title,
            'youtube_url': youtubeUrl,
            'commentary': commentary,
            'posted_by_name': postedByName,
            'posted_by_id': postedById,
            'poster_avatar_url': posterAvatarUrl,
          })
          .select()
          .single();
      return VideoPostModel.fromJson(response);
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<VideoPostModel> updateVideoPost({
    required String id,
    required String title,
    required String youtubeUrl,
    String? commentary,
  }) async {
    try {
      final response = await supabaseClient
          .from('video_posts')
          .update({
            'title': title,
            'youtube_url': youtubeUrl,
            'commentary': commentary,
          })
          .eq('id', id)
          .select()
          .single();
      return VideoPostModel.fromJson(response);
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<void> deleteVideoPost(String id) async {
    try {
      await supabaseClient.from('video_posts').delete().eq('id', id);
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<VideoPostModel> getVideoByIdPrefix(String idPrefix) async {
    try {
      final response = await supabaseClient
          .from('video_posts')
          .select()
          .like('id', '$idPrefix%')
          .limit(1)
          .single();
      return VideoPostModel.fromJson(response);
    } catch (e) {
      throw ServerException(e.toString());
    }
  }
}
