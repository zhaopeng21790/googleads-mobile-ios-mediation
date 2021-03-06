#import "MoPubAdapterMediatedNativeAd.h"

@import GoogleMobileAds;

#import "MoPubAdapterConstants.h"
#import "MPAdDestinationDisplayAgent.h"
#import "MPCoreInstanceProvider.h"
#import "MPNativeAd.h"
#import "MPNativeAdConstants.h"

@interface MoPubAdapterMediatedNativeAd ()
<GADMediatedNativeAdDelegate, MPAdDestinationDisplayAgentDelegate>

@property(nonatomic, copy) NSArray *mappedImages;
@property(nonatomic, copy) GADNativeAdImage *mappedLogo;
@property(nonatomic, copy) NSDictionary *extras;
@property(nonatomic, copy) MPNativeAd *nativeAd;
@property(nonatomic, copy) NSDictionary *nativeAdProperties;
@property(nonatomic) MPAdDestinationDisplayAgent *displayDestinationAgent;
@property(nonatomic) UIViewController *baseViewController;
@property(nonatomic) GADNativeAdViewAdOptions *nativeAdViewOptions;
@property(nonatomic) GADMoPubNetworkExtras *networkExtras;
@property(nonatomic) UIImageView *privacyIconImageView;

@end

@implementation MoPubAdapterMediatedNativeAd

- (instancetype)initWithMoPubNativeAd:(nonnull MPNativeAd *)moPubNativeAd
                         mappedImages:(nullable NSMutableDictionary *)downloadedImages
                  nativeAdViewOptions:(nonnull GADNativeAdViewAdOptions*)nativeAdViewOptions
                        networkExtras:(nullable GADMoPubNetworkExtras *)networkExtras {
  if (!moPubNativeAd) {
    return nil;
  }
  self = [super init];
  if (self) {
    _nativeAd = moPubNativeAd;
    _nativeAdProperties = moPubNativeAd.properties;
    _nativeAdViewOptions = nativeAdViewOptions;
    _networkExtras = networkExtras;

    CGFloat defaultImageScale = 1;
    if(downloadedImages!=nil){
      _mappedImages =
      [[NSArray alloc] initWithObjects:[downloadedImages objectForKey:kAdMainImageKey], nil];
      _mappedLogo = [downloadedImages objectForKey:kAdIconImageKey];
    }
    else {
      NSURL *mainImageUrl =
      [[NSURL alloc] initFileURLWithPath:[_nativeAdProperties objectForKey:kAdMainImageKey]];
      _mappedImages =
      @[[[GADNativeAdImage alloc] initWithURL:mainImageUrl scale:defaultImageScale]];
      NSURL *logoImageURL =
      [[NSURL alloc] initFileURLWithPath:[_nativeAdProperties objectForKey:kAdIconImageKey]];
      _mappedLogo = [[GADNativeAdImage alloc] initWithURL:logoImageURL scale:defaultImageScale];
    }
  }
  return self;
}

- (NSString *)headline {
  return [_nativeAdProperties objectForKey:kAdTitleKey];
}

- (NSString *)body {
  return [_nativeAdProperties objectForKey:kAdTextKey];
}

- (GADNativeAdImage *)icon {
  return _mappedLogo;
}

- (NSArray *)images {
  return _mappedImages;
}

- (NSString *)callToAction {
  return [_nativeAdProperties objectForKey:kAdCTATextKey];
}

- (NSString *)advertiser {
  return nil;
}

- (NSDictionary *)extraAssets {
  return _extras;
}

- (NSDecimalNumber *)starRating{
  return 0;
}

- (NSString *)store {
  return nil;
}

- (NSString *)price {
  return nil;
}

- (id<GADMediatedNativeAdDelegate>)mediatedNativeAdDelegate {
  return self;
}

- (void)privacyIconTapped {
  _displayDestinationAgent =
  [[MPCoreInstanceProvider sharedProvider] buildMPAdDestinationDisplayAgentWithDelegate:self];
  [_displayDestinationAgent
   displayDestinationForURL:[NSURL URLWithString:kDAAIconTapDestinationURL]];
}

#pragma mark - GADMediatedNativeAdDelegate implementation
#pragma GCC diagnostic ignored "-Wundeclared-selector"

- (void)mediatedNativeAd:(id<GADMediatedNativeAd>)mediatedNativeAd
         didRenderInView:(UIView *)view
          viewController:(UIViewController *)viewController {

  _baseViewController = viewController;
  [_nativeAd performSelector:@selector(willAttachToView:) withObject:view];

  UITapGestureRecognizer *tapRecognizer =
  [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(privacyIconTapped)];

  UIImage *privacyIconImage = [UIImage imageNamed:kDAAIconImageName];
  _privacyIconImageView = [[UIImageView alloc] initWithImage:privacyIconImage];
  _privacyIconImageView.userInteractionEnabled = YES;
  [_privacyIconImageView addGestureRecognizer:tapRecognizer];

  float privacyIconSize;
  if (_networkExtras) {
    if (_networkExtras.privacyIconSize < MINIMUM_MOPUB_PRIVACY_ICON_SIZE) {
      privacyIconSize = MINIMUM_MOPUB_PRIVACY_ICON_SIZE;
    }
    else if (_networkExtras.privacyIconSize > MAXIMUM_MOPUB_PRIVACY_ICON_SIZE) {
      privacyIconSize = MAXIMUM_MOPUB_PRIVACY_ICON_SIZE;
    }
    else {
      privacyIconSize = _networkExtras.privacyIconSize;
    }
  } else {
    privacyIconSize = DEFAULT_MOPUB_PRIVACY_ICON_SIZE;
  }

  switch (_nativeAdViewOptions.preferredAdChoicesPosition) {
      case GADAdChoicesPositionTopLeftCorner:
      _privacyIconImageView.frame = CGRectMake(0, 0, privacyIconSize, privacyIconSize);
      _privacyIconImageView.autoresizingMask =
      UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleRightMargin;
      break;
      case GADAdChoicesPositionBottomLeftCorner:
      _privacyIconImageView.frame = CGRectMake(0,
                                               view.bounds.size.height-privacyIconSize,
                                               privacyIconSize,
                                               privacyIconSize);
      _privacyIconImageView.autoresizingMask =
      UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleRightMargin;
      break;
      case GADAdChoicesPositionBottomRightCorner:
      _privacyIconImageView.frame = CGRectMake(view.bounds.size.width-privacyIconSize,
                                               view.bounds.size.height-privacyIconSize,
                                               privacyIconSize,
                                               privacyIconSize);
      _privacyIconImageView.autoresizingMask =
      UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleLeftMargin;
      break;
      case GADAdChoicesPositionTopRightCorner:
      _privacyIconImageView.frame = CGRectMake(view.bounds.size.width-privacyIconSize,
                                               0,
                                               privacyIconSize,
                                               privacyIconSize);
      _privacyIconImageView.autoresizingMask =
      UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleLeftMargin;
      break;
    default:
      _privacyIconImageView.frame = CGRectMake(view.bounds.size.width-privacyIconSize,
                                               0,
                                               privacyIconSize,
                                               privacyIconSize);
      _privacyIconImageView.autoresizingMask =
      UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleLeftMargin;
      break;
  }

  [view addSubview:_privacyIconImageView];
}

- (void)mediatedNativeAd:(id<GADMediatedNativeAd>)mediatedNativeAd
didRecordClickOnAssetWithName:(NSString *)assetName
                    view:(UIView *)view
          viewController:(UIViewController *)viewController {
  if (_nativeAd) {
    [_nativeAd performSelector:@selector(adViewTapped)];
  }
}

- (void)mediatedNativeAd:(id<GADMediatedNativeAd>)mediatedNativeAd didUntrackView:(UIView *)view {
  if(_privacyIconImageView) {
    [_privacyIconImageView removeFromSuperview];
  }
}

#pragma mark - MPAdDestinationDisplayAgentDelegate

- (UIViewController *)viewControllerForPresentingModalView {
  return _baseViewController;
}

- (void)displayAgentDidDismissModal {
  [GADMediatedNativeAdNotificationSource mediatedNativeAdWillDismissScreen:self];
  [GADMediatedNativeAdNotificationSource mediatedNativeAdDidDismissScreen:self];
}

- (void)displayAgentWillPresentModal {
  [GADMediatedNativeAdNotificationSource mediatedNativeAdWillPresentScreen:self];
}

- (void)displayAgentWillLeaveApplication {
  [GADMediatedNativeAdNotificationSource mediatedNativeAdWillLeaveApplication:self];
}

@end
