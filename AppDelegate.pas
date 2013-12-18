namespace ZeroConfBrowser;

interface

uses UIKit;

type
  AppDelegate = public class(NSObject, IUIApplicationDelegate)
  protected
    property window: UIWindow;
    property navigationController: UINavigationController;
  private
    method applicationDidFinishLaunching(application: UIApplication);
    method applicationWillTerminate(application: UIApplication);
  end;

implementation

method AppDelegate.applicationDidFinishLaunching(application: UIApplication);
begin
  window := new UIWindow withFrame(UIScreen.mainScreen.bounds);

  //application.statusBarStyle := UIStatusBarStyle.UIStatusBarStyleLightContent;

  var lNavigationController := new UINavigationController withRootViewController(new RootViewController);
  lNavigationController.navigationBar.tintColor := UIColor.colorWithRed(0.8) green(0.0) blue(0) alpha(1.0);
  window.rootViewController := lNavigationController;

  self.window.makeKeyAndVisible;
end;

method AppDelegate.applicationWillTerminate(application: UIApplication);
begin
end;

end.
