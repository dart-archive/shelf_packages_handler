// Copyright (c) 2016, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

library shelf_packages_handler;

import 'dart:isolate';

import 'package:shelf/shelf.dart';
import 'package:package_config/package_config.dart';

import 'src/async_handler.dart';
import 'src/dir_handler.dart';
import 'src/package_config_handler.dart';

/// A handler that serves the contents of a virtual packages directory.
///
/// This effectively serves `package:${request.url}`. It locates packages using
/// the package resolution logic defined by [packageConfig]. If [packageConfig]
/// isn't passed, it defaults to the current isolate's package config.
///
/// This can only serve assets from `file:` URIs.
Handler packagesHandler({PackageConfig packageConfig}) {
  return AsyncHandler(() async {
    var isolateConfigUri = await Isolate.packageConfig;
    packageConfig ??= await loadPackageConfigUri(isolateConfigUri);
    return PackageConfigHandler(packageConfig).handleRequest;
  }());
}

/// A handler that serves virtual `packages/` directories wherever they're
/// requested.
///
/// This serves the same assets as [packagesHandler] for every URL that contains
/// `/packages/`. Otherwise, it returns 404s for all requests.
///
/// This is useful for ensuring that `package:` imports work for all entrypoints
/// in Dartium.
Handler packagesDirHandler({PackageConfig packageConfig}) =>
    DirHandler('packages', packagesHandler(packageConfig: packageConfig));
