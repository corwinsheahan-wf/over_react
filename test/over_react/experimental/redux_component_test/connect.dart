// ignore_for_file: deprecated_member_use

part of over_react.component_declaration.redux_component_test;

@Factory()
UiFactory<TestConnectProps> TestConnect;

@Props()
class TestConnectProps
    extends BuiltReduxUiProps<BaseState, BaseStateBuilder, BaseActions> {}

@Component()
class TestConnectComponent
    extends BuiltReduxUiComponent<BaseState, BaseStateBuilder, BaseActions, TestConnectProps, int> {
  int numberOfRedraws = 0;

  @override
  render() => Dom.div()(connectedState);

  @override
  int connect(BaseState state) => state.count1;

  @override
  void setState(_, [callback()]) {
    numberOfRedraws++;
    if (callback != null) callback();
  }
}
