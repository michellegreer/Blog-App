import 'package:blog_app/Core/Errors/failure.dart';
import 'package:blog_app/Features/Invite/Data/DataSource/invite_remote_data_source.dart';
import 'package:fpdart/fpdart.dart';

class SendInvite {
  final InviteRemoteDataSource _dataSource;
  SendInvite(this._dataSource);

  Future<Either<Failure, void>> call({
    required String email,
    String? name,
    String? circleId,
  }) async {
    try {
      await _dataSource.sendInvite(email: email, name: name, circleId: circleId);
      return right(null);
    } catch (e) {
      return left(Failure(e.toString().replaceFirst('Exception: ', '')));
    }
  }
}
