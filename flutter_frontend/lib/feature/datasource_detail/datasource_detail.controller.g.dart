// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'datasource_detail.controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$datasourceDetailControllerHash() =>
    r'0a6a902a31b8051b39b4d21addaceda412c43aea';

/// Copied from Dart SDK
class _SystemHash {
  _SystemHash._();

  static int combine(int hash, int value) {
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + value);
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + ((0x0007ffff & hash) << 10));
    return hash ^ (hash >> 6);
  }

  static int finish(int hash) {
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + ((0x03ffffff & hash) << 3));
    // ignore: parameter_assignments
    hash = hash ^ (hash >> 11);
    return 0x1fffffff & (hash + ((0x00003fff & hash) << 15));
  }
}

abstract class _$DatasourceDetailController
    extends BuildlessAutoDisposeAsyncNotifier<Dataset> {
  late final String id;

  FutureOr<Dataset> build(String id);
}

/// See also [DatasourceDetailController].
@ProviderFor(DatasourceDetailController)
const datasourceDetailControllerProvider = DatasourceDetailControllerFamily();

/// See also [DatasourceDetailController].
class DatasourceDetailControllerFamily extends Family<AsyncValue<Dataset>> {
  /// See also [DatasourceDetailController].
  const DatasourceDetailControllerFamily();

  /// See also [DatasourceDetailController].
  DatasourceDetailControllerProvider call(String id) {
    return DatasourceDetailControllerProvider(id);
  }

  @override
  DatasourceDetailControllerProvider getProviderOverride(
    covariant DatasourceDetailControllerProvider provider,
  ) {
    return call(provider.id);
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'datasourceDetailControllerProvider';
}

/// See also [DatasourceDetailController].
class DatasourceDetailControllerProvider
    extends
        AutoDisposeAsyncNotifierProviderImpl<
          DatasourceDetailController,
          Dataset
        > {
  /// See also [DatasourceDetailController].
  DatasourceDetailControllerProvider(String id)
    : this._internal(
        () => DatasourceDetailController()..id = id,
        from: datasourceDetailControllerProvider,
        name: r'datasourceDetailControllerProvider',
        debugGetCreateSourceHash:
            const bool.fromEnvironment('dart.vm.product')
                ? null
                : _$datasourceDetailControllerHash,
        dependencies: DatasourceDetailControllerFamily._dependencies,
        allTransitiveDependencies:
            DatasourceDetailControllerFamily._allTransitiveDependencies,
        id: id,
      );

  DatasourceDetailControllerProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.id,
  }) : super.internal();

  final String id;

  @override
  FutureOr<Dataset> runNotifierBuild(
    covariant DatasourceDetailController notifier,
  ) {
    return notifier.build(id);
  }

  @override
  Override overrideWith(DatasourceDetailController Function() create) {
    return ProviderOverride(
      origin: this,
      override: DatasourceDetailControllerProvider._internal(
        () => create()..id = id,
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        id: id,
      ),
    );
  }

  @override
  AutoDisposeAsyncNotifierProviderElement<DatasourceDetailController, Dataset>
  createElement() {
    return _DatasourceDetailControllerProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is DatasourceDetailControllerProvider && other.id == id;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, id.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin DatasourceDetailControllerRef
    on AutoDisposeAsyncNotifierProviderRef<Dataset> {
  /// The parameter `id` of this provider.
  String get id;
}

class _DatasourceDetailControllerProviderElement
    extends
        AutoDisposeAsyncNotifierProviderElement<
          DatasourceDetailController,
          Dataset
        >
    with DatasourceDetailControllerRef {
  _DatasourceDetailControllerProviderElement(super.provider);

  @override
  String get id => (origin as DatasourceDetailControllerProvider).id;
}

// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
