import 'package:jaspr/jaspr.dart';
import 'package:jaspr_bloc/src/bloc_provider.dart';
import 'package:jaspr_provider/jaspr_provider.dart';

/// {@template multi_bloc_provider}
/// Merges multiple [BlocProvider] components into one component tree.
///
/// [MultiBlocProvider] improves the readability and eliminates the need
/// to nest multiple [BlocProvider]s.
///
/// By using [MultiBlocProvider] we can go from:
///
/// ```dart
/// BlocProvider<BlocA>(
///   create: (BuildContext context) => BlocA(),
///   child: BlocProvider<BlocB>(
///     create: (BuildContext context) => BlocB(),
///     child: BlocProvider<BlocC>(
///       create: (BuildContext context) => BlocC(),
///       child: ChildA(),
///     )
///   )
/// )
/// ```
///
/// to:
///
/// ```dart
/// MultiBlocProvider(
///   providers: [
///     BlocProvider<BlocA>(
///       create: (BuildContext context) => BlocA(),
///     ),
///     BlocProvider<BlocB>(
///       create: (BuildContext context) => BlocB(),
///     ),
///     BlocProvider<BlocC>(
///       create: (BuildContext context) => BlocC(),
///     ),
///   ],
///   child: ChildA(),
/// )
/// ```
///
/// [MultiBlocProvider] converts the [BlocProvider] list into a tree of nested
/// [BlocProvider] components.
/// As a result, the only advantage of using [MultiBlocProvider] is improved
/// readability due to the reduction in nesting and boilerplate.
/// {@endtemplate}
class MultiBlocProvider extends MultiProvider {
  /// {@macro multi_bloc_provider}
  MultiBlocProvider({
    Key? key,
    required List<BlocProviderSingleChildComponent> providers,
    required Component child,
  }) : super(key: key, providers: providers, child: child);
}
