import 'package:jaspr/jaspr.dart';
import 'package:jaspr_bloc/jaspr_bloc.dart';

void main() {
  runApp(App());
}

class App extends StatefulComponent {
  App({Key? key}) : super(key: key);

  @override
  State<App> createState() => _AppState();
}

class _AppState extends State<App> {
  late final _counterBloc = CounterBloc();

  @override
  void dispose() {
    _counterBloc.close();
    super.dispose();
  }

  @override
  Iterable<Component> build(BuildContext context) sync* {
    yield BlocBuilder<CounterBloc, int>(
      bloc: _counterBloc,
      builder: (context, count) sync* {
        yield Text('Count is $count');
      },
    );

    yield DomComponent(
      tag: 'button',
      events: {
        'click': (e) {
          _counterBloc.add(CounterEvent.increased());
        },
      },
      child: Text('Increase Me'),
    );

    yield DomComponent(
      tag: 'button',
      events: {
        'click': (e) {
          _counterBloc.add(CounterEvent.decreased());
        },
      },
      child: Text('Decrease Me'),
    );
  }
}

class CounterBloc extends Bloc<CounterEvent, int> {
  CounterBloc() : super(0) {
    on<CounterIncreased>(
      (event, emit) => emit(state + 1),
    );

    on<CounterDecreased>(
      (event, emit) => emit(state - 1),
    );
  }
}

abstract class CounterEvent {
  factory CounterEvent.increased() = CounterIncreased;
  factory CounterEvent.decreased() = CounterDecreased;
}

class CounterIncreased implements CounterEvent {}

class CounterDecreased implements CounterEvent {}
