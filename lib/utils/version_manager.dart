import 'dart:io';

import 'package:dio/dio.dart';
import 'package:path_provider/path_provider.dart';
import 'package:open_file/open_file.dart';
import 'package:wallet/utils/log_utils.dart';

class VersionManager {
  Dio dio;

  VersionManager() {
    dio = new Dio();
    dio.options.connectTimeout = 5000; //5s
    dio.options.receiveTimeout = 3000;
  }

  @override
  void downloadApk(Function f,Function error,String url) async {
    log('downloading url: $url');
    Directory tempDir = await getExternalStorageDirectory();
    String tempPath = tempDir.path;
    String savePath = '$tempPath/update.apk';
    await dio.download(url, savePath,
        onReceiveProgress: f,options: Options(receiveTimeout: 10*60*1000)).catchError((_error){
      error();
      return _error;
    });
    _installApk(savePath);
  }

  @override
  void _installApk(String path) async {
    log(path);
//    log(Uri.file(path));
    OpenFile.open(path);
  }

}