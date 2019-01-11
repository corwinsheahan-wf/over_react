part of basic.library;

// ignore: mixin_of_non_class,undefined_class
class SuperPartOfLibProps extends _$SuperPartOfLibProps with _$SuperPartOfLibPropsAccessorsMixin {}

@AbstractProps()
class _$SuperPartOfLibProps extends UiProps {
  static const PropsMeta meta = _$metaForSuperPartOfLibProps;

  String superProp;
}

@AbstractComponent()
abstract class SuperPartOfLibComponent<T extends SuperPartOfLibProps> extends UiComponent<T> {
  getDefaultProps() => newProps()..id = 'super';

  @override
  render() {
    return Dom.div()('SuperPartOfLib', {
      'props.superProp': props.superProp,
//      'props': props.toString(),
    }.toString());
  }
}

@Factory()
UiFactory<SubPartOfLibProps> SubPartOfLib = _$SubPartOfLib;

// ignore: mixin_of_non_class,undefined_class
class SubPartOfLibProps extends _$SubPartOfLibProps with _$SubPartOfLibPropsAccessorsMixin {}

@Props()
// Heads up: props class inheritance doesn't work properly currently
class _$SubPartOfLibProps extends SuperPartOfLibProps {
 static const PropsMeta meta = _$metaForSubPartOfLibProps;

  String subProp;
}

@Component()
class SubPartOfLibComponent extends SuperPartOfLibComponent<SubPartOfLibProps> {
  getDefaultProps() => newProps()..id = 'sub';

  @override
  render() {
    return Dom.div()('SubPartOfLib', {
      'props.subProp': props.subProp,
      'props.superProp': props.superProp,
//      'props': props.toString(),
    }.toString());
  }
}
