import 'package:jaspr/jaspr.dart';
import 'package:jaspr_bloc/jaspr_bloc.dart';

class App extends StatefulComponent {
  const App({Key? key}) : super(key: key);

  @override
  State<App> createState() => _AppState();
}

class _AppState extends State<App> {
  @override
  Iterable<Component> build(BuildContext context) sync* {
    yield DomComponent(
      tag: 'div',
      styles: const {
        "display": "flex",
        "flex-direction": "column",
        "justify-content": "center",
      },
      children: [
        BlocProvider(
          create: (context) => CounterCubit(),
          child: BlocBuilder<CounterCubit, int>(
            builder: (context, state) sync* {
              yield const DomComponent(
                tag: "h5",
                styles: {
                  "text-align": "center",
                },
                children: [
                  Text(
                    "Press plus button to increment the counter with jaspr bloc!",
                  ),
                ],
              );
              yield DomComponent(
                tag: 'h2',
                styles: const {
                  "text-align": "center",
                },
                child: Text(state.toString()),
              );

              yield DomComponent(
                tag: 'div',
                styles: const {
                  "display": "flex",
                  "justify-content": "center",
                },
                child: DomComponent(
                  tag: 'button',
                  events: {
                    'click': (e) {
                      context.read<CounterCubit>().increment();
                    },
                  },
                  child: const Text('+'),
                ),
              );
            },
          ),
        )
      ],
    );
  }
}

class CounterCubit extends Cubit<int> {
  CounterCubit() : super(0);

  void increment() => emit(state + 1);
}
