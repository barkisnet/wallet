import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:wallet/chain_params.dart';

import 'api_service.dart';

///
/// Dio网络请求框架封装
///

class ApiManager {
  static ApiManager manager;
  var dio = new Dio();

  static ApiManager get instance {
    if (manager == null) {
      manager = ApiManager._();
    }
    return manager;
  }

  ApiManager._() {
    dio.options.baseUrl = ChainParams.lcdUrl;
    dio.options.connectTimeout = 10000;
    dio.options.receiveTimeout = 5000;
    // 添加拦截器
    dio.interceptors.add(LogInterceptor(requestBody: true));
  }

  /// 执行请求任务
  void _doRequest(String method, String url, Map<String, dynamic> params,
      [String contentType,
      void onResponse(Response resp),
      void onError(Exception e)]) async {
    contentType = contentType == null || contentType.isEmpty
        ? Headers.jsonContentType
        : contentType;
    try {
      Response response;
      switch (method) {
        case "GET":
          response = await dio.get(url, queryParameters: params);
          break;
        case "POST":
          response = await dio.post(url,
              data: (contentType == Headers.jsonContentType
                  ? json.encode(params)
                  : params),
              options: new Options(contentType: contentType));
          break;
      }
      if (response != null && onResponse != null) {
        onResponse(response);
      }
    } catch (e) {
      if (onError != null) {
        onError(e);
      }
    }
  }

  void get(String url, Map<String, dynamic> params, ApiStateHook hook) {
    if (hook != null) hook.execStart();
    _doRequest("GET", url, params, Headers.jsonContentType, (Response response) {
      if (hook != null) {
        new ApiService().proxySuccessCallBack(response, hook);
      }
    }, (Exception e) {
      if (hook != null) {
        new ApiService().proxyErrorCallBack(e, hook);
      }
    });
  }

  void post(String url, Map<String, dynamic> params, ApiStateHook hook) {
    if (hook != null) hook.execStart();
    _doRequest("POST", url, params, Headers.jsonContentType, (Response response) {
      if (hook != null) {
        new ApiService().proxySuccessCallBack(response, hook);
      }
    }, (Exception e) {
      if (hook != null) new ApiService().proxyErrorCallBack(e, hook);
    });
  }

}
