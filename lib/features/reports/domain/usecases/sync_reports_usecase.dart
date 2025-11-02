import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../../data/repositories/report_repository_impl.dart';
import '../repositories/report_repository.dart';

class SyncReportsUseCase {
  final ReportRepository repository;

  SyncReportsUseCase(this.repository);

  Future<Either<Failure, SyncResult>> call() async {
    return repository.syncPendingReports();
  }
}
