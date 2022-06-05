import 'package:jaspr/jaspr.dart';
import 'package:jaspr_bloc/jaspr_bloc.dart';

/// Signature for the `selector` function which
/// is responsible for returning a selected value, [T], based on [state].
typedef BlocComponentSelector<S, T> = T Function(S state);

/// {@template bloc_selector}
/// [BlocSelector] is analogous to [BlocBuilder] but allows developers to
/// filter updates by selecting a new value based on the bloc state.
/// Unnecessary builds are prevented if the selected value does not change.
///
/// **Note**: the selected value must be immutable in order for [BlocSelector]
/// to accurately determine whether [builder] should be called again.
///

/// BlocSelector<BlocA, BlocAState, SelectedState>(
///   selector: (state) {
///     // return selected state based on the provided state.
///   },
///   builder: (context, state) {
///     // return widget here based on the selected state.
///   },
/// )
/// ```
/// {@endtemplate}
class BlocSelector<B extends StateStreamable<S>, S, T>
    extends StatefulComponent {
  /// {@macro bloc_selector}
  const BlocSelector({
    Key? key,
    required this.selector,
    required this.builder,
    required this.bloc,
  }) : super(key: key);

  /// The [bloc] that the [BlocSelector] will interact with.
  final B bloc;

  /// The [builder] function which will be invoked
  /// when the selected state changes.
  /// The [builder] takes the [BuildContext] and selected `state` and
  /// must return a component.
  /// This is analogous to the [builder] function in [BlocBuilder].
  final BlocComponentBuilder<T> builder;

  /// The [selector] function which will be invoked on each widget build
  /// and is responsible for returning a selected value of type [T] based on
  /// the current state.
  final BlocComponentSelector<S, T> selector;

  @override
  State<BlocSelector<B, S, T>> createState() => _BlocSelectorState<B, S, T>();
}

class _BlocSelectorState<B extends StateStreamable<S>, S, T>
    extends State<BlocSelector<B, S, T>> {
  late B _bloc;
  late T _state;

  @override
  void initState() {
    super.initState();
    _bloc = component.bloc;
    _state = component.selector(_bloc.state);
  }

  @override
  void didUpdateComponent(BlocSelector<B, S, T> oldComponent) {
    super.didUpdateComponent(oldComponent);
    final oldBloc = oldComponent.bloc;
    final currentBloc = component.bloc;
    if (oldBloc != currentBloc) {
      _bloc = currentBloc;
      _state = component.selector(_bloc.state);
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final bloc = component.bloc;
    if (_bloc != bloc) {
      _bloc = bloc;
      _state = component.selector(_bloc.state);
    }
  }

  @override
  Iterable<Component> build(BuildContext context) sync* {
    yield BlocListener<B, S>(
      bloc: _bloc,
      listener: (context, state) {
        final selectedState = component.selector(state);
        if (_state != selectedState) setState(() => _state = selectedState);
      },
    );

    yield* component.builder(context, _state);
  }
}
