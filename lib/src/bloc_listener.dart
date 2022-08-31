import 'dart:async';

import 'package:jaspr/jaspr.dart';
import 'package:jaspr_bloc/jaspr_bloc.dart';
import 'package:jaspr_provider/jaspr_provider.dart';

/// Signature for the `listener` function which takes the `BuildContext` along
/// with the `state` and is responsible for executing in response to
/// `state` changes.
typedef BlocComponentListener<S> = void Function(BuildContext context, S state);

/// Signature for the `listenWhen` function which takes the previous `state`
/// and the current `state` and is responsible for returning a [bool] which
/// determines whether or not to call [BlocComponentListener] of [BlocListener]
/// with the current `state`.
typedef BlocListenerCondition<S> = bool Function(S previous, S current);

/// {@template bloc_listener}
/// Takes a [BlocComponentListener] and an optional [bloc] and invokes
/// the [listener] in response to `state` changes in the [bloc].
/// It should be used for functionality that needs to occur only in response to
/// a `state` change such as navigation, showing a `SnackBar`, showing
/// a `Dialog`, etc...
/// The [listener] is guaranteed to only be called once for each `state` change
/// unlike the `builder` in `BlocBuilder`.
///

/// BlocListener<BlocA, BlocAState>(
///   listener: (context, state) {
///     // do stuff here based on BlocA's state
///   },
/// )
/// ```
/// Only specify the [bloc] if you wish to provide a [bloc] that is otherwise
/// not accessible via [BlocProvider] and the current `BuildContext`.
///

/// BlocListener<BlocA, BlocAState>(
///   value: blocA,
///   listener: (context, state) {
///     // do stuff here based on BlocA's state
///   },
/// )
/// ```
/// {@endtemplate}
///
/// {@template bloc_listener_listen_when}
/// An optional [listenWhen] can be implemented for more granular control
/// over when [listener] is called.
/// [listenWhen] will be invoked on each [bloc] `state` change.
/// [listenWhen] takes the previous `state` and current `state` and must
/// return a [bool] which determines whether or not the [listener] function
/// will be invoked.
/// The previous `state` will be initialized to the `state` of the [bloc]
/// when the [BlocListener] is initialized.
/// [listenWhen] is optional and if omitted, it will default to `true`.
///

/// BlocListener<BlocA, BlocAState>(
///   listenWhen: (previous, current) {
///     // return true/false to determine whether or not
///     // to invoke listener with state
///   },
///   listener: (context, state) {
///     // do stuff here based on BlocA's state
///   }
/// )
/// ```
/// {@endtemplate}
class BlocListener<B extends StateStreamable<S>, S>
    extends BlocListenerBase<B, S> {
  /// {@macro bloc_listener}
  /// {@macro bloc_listener_listen_when}
  const BlocListener({
    Key? key,
    required BlocComponentListener<S> listener,
    B? bloc,
    BlocListenerCondition<S>? listenWhen,
    Component? child,
  }) : super(
          key: key,
          listener: listener,
          bloc: bloc,
          listenWhen: listenWhen,
          child: child,
        );
}

/// {@template bloc_listener_base}
/// Base class for widgets that listen to state changes in a specified [bloc].
///
/// A [BlocListenerBase] is stateful and maintains the state subscription.
/// The type of the state and what happens with each state change
/// is defined by sub-classes.
/// {@endtemplate}
abstract class BlocListenerBase<B extends StateStreamable<S>, S>
    extends StatefulComponent {
  /// {@macro bloc_listener_base}
  const BlocListenerBase({
    Key? key,
    required this.listener,
    this.bloc,
    this.listenWhen,
    this.child,
  }) : super(key: key);

  /// The [bloc] whose `state` will be listened to.
  /// Whenever the [bloc]'s `state` changes, [listener] will be invoked.
  final B? bloc;

  /// The [BlocComponentListener] which will be called on every `state` change.
  /// This [listener] should be used for any code which needs to execute
  /// in response to a `state` change.
  final BlocComponentListener<S> listener;

  /// {@macro bloc_listener_listen_when}
  final BlocListenerCondition<S>? listenWhen;

  final Component? child;

  @override
  State<BlocListenerBase<B, S>> createState() => _BlocListenerBaseState<B, S>();
}

class _BlocListenerBaseState<B extends StateStreamable<S>, S>
    extends State<BlocListenerBase<B, S>> {
  StreamSubscription<S>? _subscription;
  late B _bloc;
  late S _previousState;

  @override
  void initState() {
    super.initState();
    _bloc = component.bloc ?? context.read<B>();
    _previousState = _bloc.state;
    _subscribe();
  }

  @override
  void didUpdateComponent(BlocListenerBase<B, S> oldComponent) {
    super.didUpdateComponent(oldComponent);
    final oldBloc = oldComponent.bloc ?? context.read<B>();
    final currentBloc = component.bloc ?? oldBloc;
    if (oldBloc != currentBloc) {
      if (_subscription != null) {
        _unsubscribe();
        _bloc = currentBloc;
        _previousState = _bloc.state;
      }
      _subscribe();
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final bloc = component.bloc ?? context.read<B>();
    if (_bloc != bloc) {
      if (_subscription != null) {
        _unsubscribe();
        _bloc = bloc;
        _previousState = _bloc.state;
      }
      _subscribe();
    }
  }

  @override
  Iterable<Component> build(BuildContext context) sync* {
    if (component.bloc == null) {
      context.select<B, bool>((bloc) => identical(_bloc, bloc));
    }
    final child = component.child;
    if (child != null) {
      yield child;
    }
  }

  @override
  void dispose() {
    _unsubscribe();
    super.dispose();
  }

  void _subscribe() {
    _subscription = _bloc.stream.listen((state) {
      if (component.listenWhen?.call(_previousState, state) ?? true) {
        component.listener(context, state);
      }
      _previousState = state;
    });
  }

  void _unsubscribe() {
    _subscription?.cancel();
    _subscription = null;
  }
}
