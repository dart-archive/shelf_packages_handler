// Copyright (c) 2016, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:async';

import 'package:package_config/package_config.dart';
import 'package:path/path.dart' as p;
import 'package:shelf/shelf.dart';
import 'package:shelf_static/shelf_static.dart';

/// A shelf handler that serves a virtual packages directory based on a package
/// config.
class PackageConfigHandler {
  /// The static handlers for serving entries in the package config, indexed by
  /// name.
  final _packageHandlers = <String, Handler>{};

  /// The information specifying how to do package resolution.
  final PackageConfig _packageConfig;

  PackageConfigHandler(this._packageConfig);

  /// The callback for handling a single request.
  FutureOr<Response> handleRequest(Request request) {
    var segments = request.url.pathSegments;
    return _handlerFor(segments.first)(request.change(path: segments.first));
  }

  /// Creates a handler for [packageName] based on the package map in
  /// [_packageConfig].
  Handler _handlerFor(String packageName) {
    return _packageHandlers.putIfAbsent(packageName, () {
      var package = _packageConfig[packageName];
      var handler = package == null
          ? (_) => Response.notFound('Package $packageName not found.')
          : createStaticHandler(p.fromUri(package.packageUriRoot),
              serveFilesOutsidePath: true);

      return handler;
    });
  }
}
