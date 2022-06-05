import 'package:jaspr/jaspr.dart';
import 'package:jaspr_bloc/jaspr_bloc.dart';

/// {@template bloc_consumer}
/// [BlocConsumer] exposes a [builder] and [listener] in order react to new
/// states.
/// [BlocConsumer] is analogous to a nested `BlocListener`
/// and `BlocBuilder` but reduces the amount of boilerplate needed.
/// [BlocConsumer] should only be used when it is necessary to both rebuild UI
/// and execute other reactions to state changes in the [bloc].
///
/// [BlocConsumer] takes a required `BlocComponentBuilder`
/// and `BlocComponentListener` and an optional [bloc],
/// `BlocBuilderCondition`, and `BlocListenerCondition`.
///
/// If the [bloc] parameter is omitted, [BlocConsumer] will automatically
/// perform a lookup using `BlocProvider` and the current `BuildContext`.
///

/// BlocConsumer<BlocA, BlocAState>(
///   listener: (context, state) {
///     // do stuff here based on BlocA's state
///   },
///   builder: (context, state) {
///     // return widget here based on BlocA's state
///   }
/// )
/// ```
///
/// An optional [listenWhen] and [buildWhen] can be implemented for more
/// granular control over when [listener] and [builder] are called.
/// The [listenWhen] and [buildWhen] will be invoked on each [bloc] `state`
/// change.
/// They each take the previous `state` and current `state` and must return
/// a [bool] which determines whether or not the [builder] and/or [listener]
/// function will be invoked.
/// The previous `state` will be initialized to the `state` of the [bloc] when
/// the [BlocConsumer] is initialized.
/// [listenWhen] and [buildWhen] are optional and if they aren't implemented,
/// they will default to `true`.
///

/// BlocConsumer<BlocA, BlocAState>(
///   listenWhen: (previous, current) {
///     // return true/false to determine whether or not
///     // to invoke listener with state
///   },
///   listener: (context, state) {
///     // do stuff here based on BlocA's state
///   },
///   buildWhen: (previous, current) {
///     // return true/false to determine whether or not
///     // to rebuild the widget with state
///   },
///   builder: (context, state) {
///     // return widget here based on BlocA's state
///   }
/// )
/// ```
/// {@endtemplate}
class BlocConsumer<B extends StateStreamable<S>, S> extends StatefulComponent {
  /// {@macro bloc_consumer}
  const BlocConsumer({
    required this.builder,
    required this.listener,
    required this.bloc,
    this.buildWhen,
    this.listenWhen,
    Key? key,
  }) : super(key: key);

  /// The [bloc] that the [BlocConsumer] will interact with.
  /// If omitted, [BlocConsumer] will automatically perform a lookup using
  /// `BlocProvider` and the current `BuildContext`.
  final B bloc;

  /// The [builder] function which will be invoked on each widget build.
  /// The [builder] takes the `BuildContext` and current `state` and
  /// must return a component.
  /// This is analogous to the [builder] function in [StreamBuilder].
  final BlocComponentBuilder<S> builder;

  /// Takes the `BuildContext` along with the [bloc] `state`
  /// and is responsible for executing in response to `state` changes.
  final BlocComponentListener<S> listener;

  /// Takes the previous `state` and the current `state` and is responsible for
  /// returning a [bool] which determines whether or not to trigger
  /// [builder] with the current `state`.
  final BlocBuilderCondition<S>? buildWhen;

  /// Takes the previous `state` and the current `state` and is responsible for
  /// returning a [bool] which determines whether or not to call [listener] of
  /// [BlocConsumer] with the current `state`.
  final BlocListenerCondition<S>? listenWhen;

  @override
  State<BlocConsumer<B, S>> createState() => _BlocConsumerState<B, S>();
}

class _BlocConsumerState<B extends StateStreamable<S>, S>
    extends State<BlocConsumer<B, S>> {
  late B _bloc;

  @override
  void initState() {
    super.initState();
    _bloc = component.bloc;
  }

  @override
  void didUpdateComponent(BlocConsumer<B, S> oldComponent) {
    super.didUpdateComponent(oldComponent);
    final oldBloc = oldComponent.bloc;
    final currentBloc = component.bloc;
    if (oldBloc != currentBloc) _bloc = currentBloc;
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final bloc = component.bloc;
    if (_bloc != bloc) _bloc = bloc;
  }

  @override
  Iterable<Component> build(BuildContext context) sync* {
    yield BlocBuilder<B, S>(
      bloc: _bloc,
      builder: component.builder,
      buildWhen: (previous, current) {
        if (component.listenWhen?.call(previous, current) ?? true) {
          component.listener(context, current);
        }
        return component.buildWhen?.call(previous, current) ?? true;
      },
    );
  }
}
