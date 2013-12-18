namespace ZeroConfBrowser;

interface

uses
  UIKit;

type
  ServicesViewController = public class(UITableViewController, INSNetServiceDelegate, INSNetServiceBrowserDelegate)
  protected
    var fType: NSString;
    var services: NSMutableDictionary;
    var serviceStatus: NSMutableDictionary;
    var fNetServiceBrowser: NSNetServiceBrowser;
    var isRO: BOOL;
    var isDA: BOOL;
    var isRelativity: BOOL;
    var background: UIImage;
  public
    method initWithServiceType(aType: NSString): id;
    method dealloc; override;
    method viewDidLoad; override;
  private
    method becomeActive(notification: NSNotification);
    method resignActive(notification: NSNotification);
    method netServiceBrowser(netServiceBrowser: NSNetServiceBrowser) didFindService(netService: NSNetService) moreComing(moreServicesComing: BOOL);
    method netServiceBrowser(netServiceBrowser: NSNetServiceBrowser) didRemoveService(netService: NSNetService) moreComing(moreServicesComing: BOOL);
    method netServiceWillResolve(sender: NSNetService);
    method netServiceDidResolveAddress(sender: NSNetService);
    method netService(sender: NSNetService) didNotResolve(errorDict: NSDictionary);
    method numberOfSectionsInTableView(tableView: UITableView): NSInteger;
    method tableView(tableView: UITableView) numberOfRowsInSection(section: NSInteger): NSInteger;
    method tableView(tableView: UITableView) cellForRowAtIndexPath(indexPath: NSIndexPath): UITableViewCell;
    method tableView(tableView: UITableView) heightForRowAtIndexPath(indexPath: NSIndexPath): CGFloat;
    method tableView(tableView: UITableView) didSelectRowAtIndexPath(indexPath: NSIndexPath);
  end;

implementation

method ServicesViewController.initWithServiceType(aType: NSString): id;
begin
  self := inherited init;
  if assigned(self) then
    fType := aType;
  exit self;
end;

method ServicesViewController.dealloc;
begin
  NSNotificationCenter.defaultCenter().removeObserver(self);
  inherited dealloc();
end;

method ServicesViewController.viewDidLoad;
begin
  inherited viewDidLoad();
  services := NSMutableDictionary.alloc().init();
  serviceStatus := NSMutableDictionary.alloc().init();
  self.title := fType;
  isRelativity := (fType.compare('_Relativity_DataService_rosdk') = 0) or (fType.compare('_Relativity_AdminService_rosdk') = 0);
  isRO := fType.hasSuffix('_rosdk');
  isDA := NO;
  if isRelativity then
    background := UIImage.imageWithContentsOfFile(NSBundle.mainBundle().pathForResource('RelativityDetailBackground') ofType('png'))
  else
    if isDA then begin
      background := UIImage.imageWithContentsOfFile(NSBundle.mainBundle().pathForResource('DADetailBackground') ofType('png'));
    end
    else begin
      if isRO then begin
        background := UIImage.imageWithContentsOfFile(NSBundle.mainBundle().pathForResource('RODetailBackground') ofType('png'));
      end
      else begin
        background := UIImage.imageWithContentsOfFile(NSBundle.mainBundle().pathForResource('RegularDetailBackground') ofType('png'));
      end;
    end;
  self.tableView.rowHeight := 200;
  fNetServiceBrowser := NSNetServiceBrowser.alloc().init();
  fNetServiceBrowser.setDelegate(self);
  NSNotificationCenter.defaultCenter().addObserver(self) &selector(selector(resignActive:)) name(UIApplicationWillResignActiveNotification) object(nil);
  NSNotificationCenter.defaultCenter().addObserver(self) &selector(selector(becomeActive:)) name(UIApplicationDidBecomeActiveNotification) object(nil);
  self.becomeActive(nil);
end;

method ServicesViewController.becomeActive(notification: NSNotification);
begin
  fNetServiceBrowser.searchForServicesOfType(NSString.stringWithFormat('%@._tcp.', fType)) inDomain('');
end;

method ServicesViewController.resignActive(notification: NSNotification);
begin
  fNetServiceBrowser.stop();
  services.removeAllObjects();
  self.tableView().reloadData();
end;

method ServicesViewController.netServiceBrowser(netServiceBrowser: NSNetServiceBrowser) didFindService(netService: NSNetService) moreComing(moreServicesComing: BOOL);
begin
  var name: NSString := netService.name();
  services.setValue(netService) forKey(name);
  serviceStatus.setValue('pending...') forKey(name);
  netService.setDelegate(self);
  netService.resolveWithTimeout(60);
  if not moreServicesComing then
    self.tableView.reloadData();
end;

method ServicesViewController.netServiceBrowser(netServiceBrowser: NSNetServiceBrowser) didRemoveService(netService: NSNetService) moreComing(moreServicesComing: BOOL);
begin
  var name: NSString := netService.name();
  services.removeObjectForKey(name);
  serviceStatus.removeObjectForKey(name);
  if not moreServicesComing then
    self.tableView.reloadData();
end;

method ServicesViewController.netServiceWillResolve(sender: NSNetService);
begin
  serviceStatus.setValue('started resolve...') forKey(sender.name());
  self.tableView.reloadData();
end;

method ServicesViewController.netServiceDidResolveAddress(sender: NSNetService);
begin
  var status: NSString := NSString.stringWithFormat('%@:%d', sender.hostName(), Int32(sender.port()));
  var d: NSDictionary := NSNetService.dictionaryFromTXTRecordData(sender.TXTRecordData());
  for each k: NSString in d.allKeys() do
  begin
    var v := new NSString withData(d.valueForKey(k)) encoding(NSStringEncoding.NSUTF8StringEncoding);
    status := status.stringByAppendingFormat(#10"%@=%@", k, v);
  end;
  serviceStatus.setValue(status) forKey(sender.name());
  self.tableView.reloadData();
end;

method ServicesViewController.netService(sender: NSNetService) didNotResolve(errorDict: NSDictionary);
begin
  var msg: NSString := NSString.stringWithFormat('Service failed to resolve, with the following error: %@', errorDict.description());
  serviceStatus.setValue(msg) forKey(sender.name());
  self.tableView.reloadData();
end;

method ServicesViewController.numberOfSectionsInTableView(tableView: UITableView): NSInteger;
begin
  exit 1;
end;

method ServicesViewController.tableView(tableView: UITableView) numberOfRowsInSection(section: NSInteger): NSInteger;
begin
  exit services.allKeys().count();
end;

method ServicesViewController.tableView(tableView: UITableView) cellForRowAtIndexPath(indexPath: NSIndexPath): UITableViewCell;
begin
  var &index: NSInteger := indexPath.indexAtPosition(1);
  var CellIdentifier: NSString := 'ServiceTypeCell';
  var captionLabel: UILabel;
  var subtitleLabel: UILabel;
  var detailsLabel: UILabel;
  var backgroundImageView: UIImageView;
  var cell: UITableViewCell := tableView.dequeueReusableCellWithIdentifier(CellIdentifier);

  if not assigned(cell) then  begin
    cell := UITableViewCell.alloc().initWithStyle(UITableViewCellStyle.UITableViewCellStyleDefault) reuseIdentifier(CellIdentifier);

    var b: UIView := UIView.alloc().init();
    backgroundImageView := UIImageView.alloc().initWithImage(background);
    b.setFrame(cell.frame);
    backgroundImageView.setTag(100);
    b.addSubview(backgroundImageView);
    cell.setBackgroundView(b);

    var b2: UIView := UIView.alloc().init();
    backgroundImageView := UIImageView.alloc().initWithImage(background);
    b2.setFrame(cell.frame);
    backgroundImageView.setTag(100);
    b2.addSubview(backgroundImageView);
    cell.setSelectedBackgroundView(b2);

    var iconWidth: CGFloat := if isRO or isDA then 50 else 5;

    captionLabel := UILabel.alloc().initWithFrame(CGRectMake(iconWidth, 5, (tableView.bounds.size.width - iconWidth) - 5, 20));
    captionLabel.backgroundColor := UIColor.clearColor();
    captionLabel.textColor := UIColor.colorWithRed(0.25) green(0) blue(0) alpha(1);
    captionLabel.tag := 101;
    cell.contentView().addSubview(captionLabel);

    subtitleLabel := UILabel.alloc().initWithFrame(CGRectMake(iconWidth, 21, (tableView.bounds.size.width - iconWidth) - 5, 20));
    subtitleLabel.backgroundColor := UIColor.clearColor();
    subtitleLabel.font := UIFont.systemFontOfSize(12);
    subtitleLabel.textColor := UIColor.colorWithRed(0.25) green(0) blue(0) alpha(1);
    subtitleLabel.tag := 102;
    cell.contentView().addSubview(subtitleLabel);

    detailsLabel := UILabel.alloc().initWithFrame(CGRectMake(5, 50, tableView.bounds.size.width - 10, 100));
    detailsLabel.backgroundColor := UIColor.clearColor();
    detailsLabel.font := UIFont.systemFontOfSize(12);
    detailsLabel.textColor := UIColor.colorWithRed(0.25) green(0) blue(0) alpha(1);
    detailsLabel.tag := 103;
    detailsLabel.numberOfLines := 0;
    detailsLabel.lineBreakMode := NSLineBreakMode.NSLineBreakByWordWrapping;
    cell.contentView().addSubview(detailsLabel);
  end
  else begin
    captionLabel := UILabel(cell.viewWithTag(101));
    subtitleLabel := UILabel(cell.viewWithTag(102));
    detailsLabel := UILabel(cell.viewWithTag(103));
    backgroundImageView := UIImageView(cell.backgroundView().viewWithTag(100));
  end;
  var d: NSArray := NSArray.arrayWithObject(NSSortDescriptor.alloc().initWithKey('') ascending(YES));
  var names: NSArray := services.allKeys().sortedArrayUsingDescriptors(d);
  var name: NSString := names.objectAtIndex(&index);
  captionLabel.setText(name);
  subtitleLabel.setText(fType);
  var status: NSString := serviceStatus.valueForKey(name);
  detailsLabel.setText(status);
  detailsLabel.sizeToFit();
  var f: CGRect := detailsLabel.frame;
  f.size.width := tableView.bounds.size.width - 10;
  detailsLabel.setFrame(f);
  var bf: CGRect := cell.bounds();
  bf.size.height := (f.origin.y + f.size.height) + 5;
  backgroundImageView.setFrame(bf);
  var scale: CGFloat := background.scale();
  bf.size.height := bf.size.height * scale;
  bf.size.width := bf.size.width * scale;
  var imageRef: CGImageRef := CGImageCreateWithImageInRect(background.CGImage(), bf);
  backgroundImageView.setImage(UIImage.imageWithCGImage(imageRef));
  CGImageRelease(imageRef);
  cell.setNeedsDisplay();
  exit cell;
end;

method ServicesViewController.tableView(tableView: UITableView) heightForRowAtIndexPath(indexPath: NSIndexPath): CGFloat;
begin
  var MAXFLOAT := 1.99999+127; // bug

  var &index: NSInteger := indexPath.indexAtPosition(1);
  var d := NSArray.arrayWithObject(NSSortDescriptor.alloc().initWithKey('') ascending(YES));
  var names: NSArray := services.allKeys().sortedArrayUsingDescriptors(d);
  var name: NSString := names.objectAtIndex(&index);
  var status: NSString := serviceStatus.valueForKey(name);
  var height: CGFloat := 50 + status.sizeWithFont(UIFont.systemFontOfSize(12)) constrainedToSize(CGSizeMake(tableView.bounds.size.width - 10, MAXFLOAT)) lineBreakMode(NSLineBreakMode.NSLineBreakByWordWrapping).height;
  exit height + 5;
end;

method ServicesViewController.tableView(tableView: UITableView) didSelectRowAtIndexPath(indexPath: NSIndexPath);
begin
  tableView.deselectRowAtIndexPath(indexPath) animated(NO);
end;

end.
