namespace ZeroConfBrowser;

interface

uses
  UIKit;

type
  RootViewController = public class(UITableViewController, INSNetServiceBrowserDelegate)
  protected
    var currentServices: NSMutableDictionary;
    var fNetServiceBrowser: NSNetServiceBrowser;
    var knownServiceTypes: NSDictionary;
    var regularBackground: UIImage;
    var regularBackgroundSelected: UIImage;
  public
    class method initialize; override;
    method viewDidLoad; override;
    method viewDidUnload; override;
    method shouldAutorotateToInterfaceOrientation(interfaceOrientation: UIInterfaceOrientation): BOOL; override;
    method didReceiveMemoryWarning; override;
    method toggleView(sender: id);
  private
    method becomeActive(notification: NSNotification);
    method resignActive(notification: NSNotification);
    method netServiceBrowser(netServiceBrowser: NSNetServiceBrowser) didFindService(netService: NSNetService) moreComing(moreServicesComing: BOOL);
    method netServiceBrowser(netServiceBrowser: NSNetServiceBrowser) didRemoveService(netService: NSNetService) moreComing(moreServicesComing: BOOL);
    method numberOfSectionsInTableView(tableView: UITableView): NSInteger;
    method tableView(tableView: UITableView) numberOfRowsInSection(section: NSInteger): NSInteger;
    method tableView(tableView: UITableView) heightForRowAtIndexPath(indexPath: NSIndexPath): CGFloat;
    method tableView(tableView: UITableView) cellForRowAtIndexPath(indexPath: NSIndexPath): UITableViewCell;
    method tableView(tableView: UITableView) didSelectRowAtIndexPath(indexPath: NSIndexPath);
  end;

implementation

class method RootViewController.initialize;
begin
  var appDefaults := NSMutableDictionary.dictionaryWithObject(NSNumber.numberWithBool(YES)) forKey('ShowAllServices');
  NSUserDefaults.standardUserDefaults().registerDefaults(appDefaults);
end;

method RootViewController.toggleView(sender: id);
begin
  self.tableView.reloadData();
end;

method RootViewController.viewDidLoad;
begin
  NSLog('RootViewController.viewDidLoad');

  inherited viewDidLoad();

  currentServices := new NSMutableDictionary;
  var kt: NSString := NSBundle.mainBundle().pathForResource('KnownZeroConfTypes') ofType('plist');
  knownServiceTypes := new NSDictionary withContentsOfFile(kt);

  title := 'Services';
  tableView.separatorInset := UIEdgeInsetsMake(0,0,0,0);

  fNetServiceBrowser := new NSNetServiceBrowser;
  fNetServiceBrowser.setDelegate(self);
  
  regularBackground := UIImage.imageWithContentsOfFile(NSBundle.mainBundle().pathForResource('RegularServiceBackground') ofType('png'));
  regularBackgroundSelected := UIImage.imageWithContentsOfFile(NSBundle.mainBundle().pathForResource('RegularServiceBackgroundSelected') ofType('png'));
  
  NSNotificationCenter.defaultCenter().addObserver(self) &selector(selector(resignActive:)) name(UIApplicationWillResignActiveNotification) object(nil);
  NSNotificationCenter.defaultCenter().addObserver(self) &selector(selector(becomeActive:)) name(UIApplicationDidBecomeActiveNotification) object(nil);

  //self.becomeActive(nil);
end;

method RootViewController.becomeActive(notification: NSNotification);
begin
  NSLog('RootViewController.becomeActive');
  fNetServiceBrowser.searchForServicesOfType('_services._dns-sd._udp.') inDomain('');
end;

method RootViewController.resignActive(notification: NSNotification);
begin
  NSLog('RootViewController.resignActive');
  fNetServiceBrowser.stop();
  currentServices.removeAllObjects();
  tableView.reloadData();
end;

method RootViewController.netServiceBrowser(netServiceBrowser: NSNetServiceBrowser) didFindService(netService: NSNetService) moreComing(moreServicesComing: BOOL);
begin
  var name: NSString := netService.name();
  NSLog('didFindService: %@', name);
  currentServices.setValue(netService) forKey(name);
  if not moreServicesComing then
    self.tableView.reloadData();
end;

method RootViewController.netServiceBrowser(netServiceBrowser: NSNetServiceBrowser) didRemoveService(netService: NSNetService) moreComing(moreServicesComing: BOOL);
begin
  var name: NSString := netService.name();
  currentServices.removeObjectForKey(name);
  if not moreServicesComing then
    self.tableView.reloadData();
end;

method RootViewController.shouldAutorotateToInterfaceOrientation(interfaceOrientation: UIInterfaceOrientation): BOOL;
begin
  exit interfaceOrientation = UIInterfaceOrientation.UIInterfaceOrientationPortrait;
end;

method RootViewController.didReceiveMemoryWarning;
begin
  inherited didReceiveMemoryWarning();
end;

method RootViewController.viewDidUnload;
begin
end;

method RootViewController.numberOfSectionsInTableView(tableView: UITableView): NSInteger;
begin
  exit 1;
end;

method RootViewController.tableView(tableView: UITableView) numberOfRowsInSection(section: NSInteger): NSInteger;
begin
  exit currentServices.allKeys().count();
end;

method RootViewController.tableView(tableView: UITableView) heightForRowAtIndexPath(indexPath: NSIndexPath): CGFloat;
begin
  var allKeys: NSArray := currentServices.allKeys();
  if allKeys.count() = 0 then
    exit 480;
  exit tableView.rowHeight();
end;

method RootViewController.tableView(tableView: UITableView) cellForRowAtIndexPath(indexPath: NSIndexPath): UITableViewCell;
begin
  var &index: NSInteger := indexPath.indexAtPosition(1);
  var allKeys: NSArray := currentServices.allKeys();
  if allKeys.count() = 0 then
  begin
    var LookingCellIdentifier: NSString := 'LookingCell';
    var cell: UITableViewCell := tableView.dequeueReusableCellWithIdentifier(LookingCellIdentifier);
    if cell = nil then
      cell := UITableViewCell.alloc().initWithStyle(UITableViewCellStyle.UITableViewCellStyleDefault) reuseIdentifier(LookingCellIdentifier);
    var looking: UIImage := UIImage.imageWithContentsOfFile(NSBundle.mainBundle().pathForResource('Looking') ofType('png'));
    cell.setBackgroundView(UIImageView.alloc().initWithImage(looking));
    cell.setSelectedBackgroundView(UIImageView.alloc().initWithImage(looking));
    exit cell;
  end;

  var CellIdentifier: NSString := 'ServiceTypeCell';
  var captionLabel: UILabel;
  var subtitleLable: UILabel;
  var cell: UITableViewCell := tableView.dequeueReusableCellWithIdentifier(CellIdentifier);
  
  if not assigned(cell) then begin
    cell := UITableViewCell.alloc().initWithStyle(UITableViewCellStyle.UITableViewCellStyleDefault) reuseIdentifier(CellIdentifier);
    captionLabel := UILabel.alloc().initWithFrame(CGRectMake(50, 5, (tableView.bounds.size.width - 50) - 5, 20));
    captionLabel.backgroundColor := UIColor.clearColor();
    captionLabel.textColor := UIColor.colorWithRed(0.25) green(0) blue(0) alpha(1);
    captionLabel.tag := 101;
    cell.contentView().addSubview(captionLabel);
    subtitleLable := UILabel.alloc().initWithFrame(CGRectMake(50, 21, (tableView.bounds.size.width - 50) - 5, 20));
    subtitleLable.backgroundColor := UIColor.clearColor();
    subtitleLable.font := UIFont.systemFontOfSize(12);
    subtitleLable.textColor := UIColor.colorWithRed(0.25) green(0) blue(0) alpha(1);
    subtitleLable.tag := 12;
    cell.contentView().addSubview(subtitleLable);
    cell.setBackgroundView(new UIImageView withImage(regularBackground));
    cell.setSelectedBackgroundView(new UIImageView withImage(regularBackgroundSelected));

    //var f := cell.imageView.frame;
    //f.origin.x := f.origin.x-30;
    //cell.imageView.frame := f;
  end
  else begin
    captionLabel := UILabel(cell.viewWithTag(101));
    subtitleLable := UILabel(cell.viewWithTag(12));
  end;
  var d: NSArray := NSArray.arrayWithObject(NSSortDescriptor.alloc().initWithKey('') ascending(YES));
  var names: NSArray := allKeys.sortedArrayUsingDescriptors(d);
  var lType: NSString := names.objectAtIndex(&index);
  var name: NSString := knownServiceTypes.valueForKey(lType);
  if not assigned(name) then
    name := lType;
  
  case lType of
    '_Relativity_DataService_rosdk',
    '_Relativity_AdminService_rosdk': cell.imageView.image := UIImage.imageWithContentsOfFile(NSBundle.mainBundle().pathForResource('Relativity') ofType('png'));
    '_crossbox': cell.imageView.image := UIImage.imageWithContentsOfFile(NSBundle.mainBundle().pathForResource('Elements') ofType('png'));
    else
      if lType.hasSuffix('_rosdk') then
        cell.imageView.image := UIImage.imageWithContentsOfFile(NSBundle.mainBundle().pathForResource('RemObjectsSDK') ofType('png'))
      else
        cell.imageView.image := nil;
  end;
  
  captionLabel.setText(name);
  subtitleLable.setText(lType);
  exit cell;
end;

method RootViewController.tableView(tableView: UITableView) didSelectRowAtIndexPath(indexPath: NSIndexPath);
begin
  var &index: NSInteger := indexPath.indexAtPosition(1);
  var allKeys: NSArray := currentServices.allKeys();
  if &index >= allKeys.count() then
    exit;
  var d: NSArray := NSArray.arrayWithObject(NSSortDescriptor.alloc().initWithKey('') ascending(YES));
  var names: NSArray := allKeys.sortedArrayUsingDescriptors(d);
  var &type: NSString := names.objectAtIndex(&index);
  var svc: ServicesViewController := ServicesViewController.alloc().initWithServiceType(&type);
  self.navigationController.pushViewController(svc) animated(YES);
  tableView.deselectRowAtIndexPath(indexPath) animated(NO);
end;

end.
