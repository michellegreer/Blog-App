import 'package:blog_app/Features/Blog/Data/Data_Source/blog_localdatasource.dart';
import 'package:blog_app/Features/Blog/Data/Models/blog_modals.dart';

class BlogLocalDataSourceWebImpl implements BlogLocalDataSource {
  @override
  List<BlogModals> getBlogFromHive() => [];

  @override
  void uploadBlogToHive({required List<BlogModals> blogs}) {}
}
