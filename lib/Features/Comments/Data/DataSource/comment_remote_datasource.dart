import 'package:blog_app/Core/Errors/exceptions.dart';
import 'package:blog_app/Features/Comments/Data/Models/comment_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

abstract interface class CommentRemoteDataSource {
  Future<List<CommentModel>> getComments(String videoPostId);
  Future<CommentModel> addComment({
    required String videoPostId,
    required String userId,
    required String userName,
    String? userAvatarUrl,
    required String content,
  });
}

class CommentRemoteDataSourceImpl implements CommentRemoteDataSource {
  final SupabaseClient supabaseClient;
  CommentRemoteDataSourceImpl(this.supabaseClient);

  @override
  Future<List<CommentModel>> getComments(String videoPostId) async {
    try {
      final response = await supabaseClient
          .from('comments')
          .select()
          .eq('video_post_id', videoPostId)
          .order('created_at', ascending: true);
      return response.map((json) => CommentModel.fromJson(json)).toList();
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<CommentModel> addComment({
    required String videoPostId,
    required String userId,
    required String userName,
    String? userAvatarUrl,
    required String content,
  }) async {
    try {
      final response = await supabaseClient
          .from('comments')
          .insert({
            'video_post_id': videoPostId,
            'user_id': userId,
            'user_name': userName,
            'user_avatar_url': userAvatarUrl,
            'content': content,
          })
          .select()
          .single();
      return CommentModel.fromJson(response);
    } catch (e) {
      throw ServerException(e.toString());
    }
  }
}
