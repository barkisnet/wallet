import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:wallet/chain_params.dart';
import 'package:wallet/utils/log_utils.dart';

///
/// Dio网络框架封装
///

class DioManager {

  int code;

  var dio = Dio(BaseOptions(baseUrl: ChainParams.lcdUrl, connectTimeout: 20000, receiveTimeout: 20000));

  /// 静态私有成员，没有初始化
  static DioManager instance;

  /// 单例公开访问点
  factory DioManager() =>
      DioManager.instance ??= DioManager._();

  ///定义一个命名构造函数用来生产实例
  DioManager._();

  void setCode(int code){
    this.code = code;
  }

  Future<String> get(String url, Map<String, dynamic> params) async {
    if (url.isNotEmpty && params != null && params.isNotEmpty) {
      //拼接参数
      StringBuffer sb = StringBuffer('?');
      params.forEach((key, value) {
        sb.write('$key=$value&');
      });
      String paramString = sb.toString().substring(0, sb.length - 1);
      url += paramString;
    }
    log('DioManager.get.url: $url');
    Response<String> response = await dio.get<String>(url);
    log('DioManager.get.data: ${response.data}');
    return response.data;
  }

  Future<String> post(String url, Map<String, dynamic> params) async {
    Map<String, String> headers = Map<String, String>();
    headers['content-Type'] = "application/x-www-form-urlencoded; charset=utf-8";
    headers['accept'] = "application/json,application/xml,application/xhtml+xml,text/html;q=0.9,image/webp,*/*;q=0.8";
//    headers['token'] = token;

    log('DioManager.post.url: $url');

    Map<String, dynamic> param;
    if(params != null) {
      param = Map<String, dynamic>();
      param['param'] = json.encode(params);

      log('DioManager.post.param = $param');
    }

    Response<String> response = await dio.post<String>(url, queryParameters: param, options: Options(headers: headers));
    log('DioManager.post.data: ${response.data}');
    return response.data;
  }

  Future<String> postBody(String url, Map<String, dynamic> params) async {
    Map<String, String> headers = Map<String, String>();
    headers['content-Type'] = "application/json; charset=utf-8";
    log('DioManager.post.url: $url');
//    params['token'] = token;
    log('params = $params');
    Response<String> response = await dio.post<String>(url, data: params, options: Options(headers: headers));
    log('DioManager.post.data: ${response.data}');
    return response.data;
  }

  /// 上传填报页面中图片
  Future<String> uploadImage(String url, Map<String, dynamic> params, List<File> fileList) async {
    Map<String, String> headers = Map<String, String>();
//    headers['token'] = token;

    log('DioManager.post.url: $url');

    Map<String, dynamic> param;
    if(params != null) {
      param = Map<String, dynamic>();
      param['param'] = json.encode(params);

      log('DioManager.post.param = $param');
    }

    var formData = FormData();

    if(fileList.isNotEmpty){
      fileList.forEach((f) {
        log('f.path = ${f.path}');
        String fileName = f.path.substring(f.path.lastIndexOf('/') + 1);
        log('fileName = $fileName');
        String suffix = f.path.substring(f.path.lastIndexOf('.') + 1);
        log('suffix = $suffix');

        formData.files.add(MapEntry(
            "files", MultipartFile.fromFileSync(f.path, filename: fileName),
        ));
      });
    }

    formData.files.forEach((element) {
      log('file.key = ${element.key} = ${element.value.filename}');
    });

    Response<String> response = await dio.post<String>(url, queryParameters: param, data: formData, options: Options(headers: headers));
    log('DioManager.post.data: ${response.data}');
    return response.data;
  }

}
