import 'dart:async';

import 'package:get/get.dart';
import 'package:get/get_connect/http/src/request/request.dart';
import 'package:skye_utils/util/http/async_decoder.dart';
import 'package:skye_utils/util/http/http_decoder.dart';
import 'package:skye_utils/util/http/request_interceptor.dart';
import 'package:skye_utils/util/http/response_interceptor.dart';
import 'package:skye_utils/util/http_util.dart';
import 'package:skye_utils/util/logger_util.dart';
import 'package:skye_utils/util/object_util.dart';
import 'package:skye_utils/util/serialize/serializable.dart';

///it's http client to send the http request
class HttpClient extends GetConnect {
  //the sever host
  String? host;
  //the sever port
  String? port;
  //the sever connection uri
  String? uri;
  //the http protocol
  String protocol;
  //the request interceptor list
  List<RequestInterceptor>? requestInterceptorList;
  //the response interceptor list
  List<ResponseInterceptor>? responseInterceptorList;
  //the response decoder which is used to decode the raw response string
  HttpDecoder? httpDecoder = AsyncDecoder();

  ///build the http client by the host and port
  HttpClient.signBuilder({
    required this.host,
    required this.port,
    this.protocol = "http",
    this.httpDecoder,
    this.requestInterceptorList,
    this.responseInterceptorList,
  });

  ///build the http client object by the uri
  HttpClient.uriBuilder({
    required this.uri,
    this.protocol = "http",
    this.httpDecoder,
    this.requestInterceptorList,
    this.responseInterceptorList,
  });

  @override
  void onInit() {
    //set the base url
    //it just will take effect when you use the websocket
    httpClient.baseUrl = (() {
      if (ObjectUtil.isEmpty(uri)) {
        if (ObjectUtil.isAnyEmpty([host, port])) {
          Log.e("can't find the http client sign");
        } else {
          uri = "$protocol://${host!}:${port!}";
        }
      }
      return uri;
    })();

    ///Its setting isn't authenticated in the default, when response status code is 403 , it will call the method
    /// addAuthenticator Authenticator will be called 3 times if HttpStatus is
    ///  HttpStatus.unauthorized

    ///package all request interceptor and append it
    httpClient.addRequestModifier((Request request) async {
      if (ObjectUtil.isNotEmpty(requestInterceptorList)) {
        //traverse all request interceptors
        for (RequestInterceptor interceptor in requestInterceptorList!) {
          request = await interceptor.intercept(request);
        }
        return request;
      } else {
        return request;
      }
    });

    /// it will intercept the response
    ///package all request interceptor and append it
    httpClient.addResponseModifier((Request request, Response response) async {
      if (ObjectUtil.isNotEmpty(responseInterceptorList)) {
        for (ResponseInterceptor interceptor in responseInterceptorList!) {
          response = await interceptor.intercept(request, response);
        }
        return response;
      } else {
        return response;
      }
    });
  }

  ///to send a GET request
  ///@param uri : the request Uri
  ///@param params : the request params
  ///@param header : the params in the header
  ///@param contentType : the content type
  ///@return : the response String
  FutureOr<String> toGet({
    required String uri,
    Map<String, dynamic>? params,
    Map<String, String>? headers,
    String? contentType,
  }) async {
    return HttpUtil.getBodyString(
        get(uri, query: params, headers: headers, contentType: contentType));
  }

  ///to send a POST request
  ///@param uri : the request Uri
  ///@param body : the request body
  ///@param query : the request query params
  ///@param header : the params in the header
  ///@param contentType : the content type
  ///@return : the response String
  FutureOr<String> toPost({
    required String uri,
    required dynamic body,
    Map<String, dynamic>? query,
    Map<String, String>? headers,
    String? contentType,
  }) async {
    return HttpUtil.getBodyString(
        post(uri, body, query: query, headers: headers, contentType: contentType));
  }

  ///to send a PUT request
  ///@param uri : the request Uri
  ///@param body : the request body
  ///@param query : the request query params
  ///@param header : the params in the header
  ///@param contentType : the content type
  ///@return : the response String
  FutureOr<String> toPut({
    required String uri,
    required dynamic body,
    Map<String, dynamic>? query,
    Map<String, String>? headers,
    String? contentType,
  }) async {
    return HttpUtil.getBodyString(
        put(uri, body, query: query, headers: headers, contentType: contentType));
  }

  ///to send a DELETE request
  ///@param uri : the request Uri
  ///@param params : the request params
  ///@param header : the params in the header
  ///@param contentType : the content type
  ///@return : the response String
  FutureOr<String> toDelete({
    required String uri,
    required Map<String, dynamic> params,
    Map<String, String>? headers,
    String? contentType,
  }) async {
    return HttpUtil.getBodyString(
        delete(uri, query: params, headers: headers, contentType: contentType));
  }

  /// to send a GET request and decode the response
  ///@param uri : the request Uri
  ///@param params : the request params
  ///@param header : the params in the header
  ///@param contentType : the content type
  ///@param modelObj : the target object
  ///@return : the response object
  Future<E> toGetAndDecode<E, F extends Serializable>({
    required String uri,
    Map<String, dynamic>? params,
    Map<String, String>? headers,
    String? contentType,
    F? modelObj,
  }) async {
    String response =
        await toGet(uri: uri, params: params, headers: headers, contentType: contentType);
    return httpDecoder!.decode<E, F>(response, modelObj: modelObj);
  }

  /// to send a POST request and decode the response
  ///@param uri : the request Uri
  ///@param body : the request body
  ///@param query : the request query params
  ///@param header : the params in the header
  ///@param contentType : the content type
  ///@param modelObj : the target object
  ///@return : the response String
  Future<E> toPostAndDecode<E, F extends Serializable>({
    required String uri,
    required dynamic body,
    Map<String, dynamic>? query,
    Map<String, String>? headers,
    String? contentType,
    F? modelObj,
  }) async {
    String response = await toPost(
        uri: uri, body: body, query: query, headers: headers, contentType: contentType);
    return httpDecoder!.decode<E, F>(response, modelObj: modelObj);
  }

  /// to send a PUT request and decode the response
  ///@param uri : the request Uri
  ///@param body : the request body
  ///@param query : the request query params
  ///@param header : the params in the header
  ///@param contentType : the content type
  ///@param modelObj : the target object
  ///@return : the response String
  Future<E> toPutAndDecode<E, F extends Serializable>({
    required String uri,
    required dynamic body,
    Map<String, dynamic>? query,
    Map<String, String>? headers,
    String? contentType,
    F? modelObj,
  }) async {
    String response =
        await toPut(uri: uri, body: body, query: query, headers: headers, contentType: contentType);
    return httpDecoder!.decode<E, F>(response, modelObj: modelObj);
  }

  /// to send a DELETE request and decode the response
  ///@param uri : the request Uri
  ///@param params : the request query params
  ///@param header : the params in the header
  ///@param contentType : the content type
  ///@param modelObj : the target object
  ///@return : the response String
  Future<E> toDeleteAndDecode<E, F extends Serializable>({
    required String uri,
    required Map<String, dynamic> params,
    Map<String, String>? headers,
    String? contentType,
    F? modelObj,
  }) async {
    String response =
        await toDelete(uri: uri, params: params, headers: headers, contentType: contentType);
    return httpDecoder!.decode<E, F>(response, modelObj: modelObj);
  }
}
