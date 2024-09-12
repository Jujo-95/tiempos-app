import 'package:fluro/fluro.dart';
import 'package:flutter/material.dart';

class Flurorouter {
  static final FluroRouter router = FluroRouter();

  static void configureRoutes() {
    router.define('/:id', handler: _loginHandler);
  }

  static final Handler _loginHandler = Handler(handlerFunc: (context, params) {
    String id = params['id']![0];
    return Dialog.fullscreen(child: Text(id));
  });
}
