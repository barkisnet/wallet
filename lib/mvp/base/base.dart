///
/// MVP基类
///

abstract class IView<T extends IPresenter> {
  void showMessage(String msg);

  void showLoading();

  void dismissLoading();
}

abstract class IPresenter {}

class BasePresenter<T extends IView> {
  T mView;

  BasePresenter(T view) {
    _attachView(view);
  }

  void _attachView(T view) {
    this.mView = view;
  }
}
