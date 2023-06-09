import 'dart:io';

import 'package:conduit/conduit.dart';

import '../model/NotesData.dart';
import '../model/response.dart';
import '../utils/app_response.dart';
import '../utils/app_utils.dart';

class AppNotesDataPaginationController extends ResourceController {
  AppNotesDataPaginationController(this.managedContext);

  final ManagedContext managedContext;

  @Operation.get("pageNumber")
  Future<Response> getPagination(
    @Bind.header(HttpHeaders.authorizationHeader) String header,
    @Bind.path("pageNumber") int pageNumber,
  ) async {
    try {
      if (pageNumber < 0)
      {
        return Response.notFound(body: ModelResponse(data: [], message: "Страница не может быть меньше еденицы"));
      }
      // Получаем id пользователя из header
      final id = AppUtils.getIdFromHeader(header);

      final qCreateNotesData = Query<NotesData>(managedContext)
        ..where((x) => x.user!.id).equalTo(id)
        ..where((x) => x.isDeleted).equalTo(false)
        ..sortBy((x) => x.id, QuerySortOrder.ascending)
        ..fetchLimit = 20
        ..offset = (pageNumber-1)*20;

      final List<NotesData> list = await qCreateNotesData.fetch();

      if (list.isEmpty)
      {
        return Response.notFound(body: ModelResponse(data: [], message: "Страница пуста"));
      }

      return Response.ok(list);
    } catch (e) {
      return AppResponse.serverError(e);
    }
  }
  

}

