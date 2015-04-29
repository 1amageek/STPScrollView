## STPScrollView
STPScrollView is Scroll View resembling a UIScrollView. This View allows customization that can not be in UIScrollView. 
For example, the UIPanGestureRecognizer that has been built-in UIScrollView you will not be able to change.

```objective-c
// Use these accessors to configure the scroll view's built-in gesture recognizers.
// Do not change the gestures' delegates or override the getters for these properties.
@property(nonatomic, readonly) UIPanGestureRecognizer *panGestureRecognizer NS_AVAILABLE_IOS(5_0);
// `pinchGestureRecognizer` will return nil when zooming is disabled.
@property(nonatomic, readonly) UIPinchGestureRecognizer *pinchGestureRecognizer NS_AVAILABLE_IOS(5_0);
```


## Quick Start

This project is dependent on [POP](https://github.com/facebook/pop).
```bash
pod install 
```
This is the same usage as the UIScrollView
```objective-c
- (void)viewDidLoad {
    [super viewDidLoad];
    CGRect screenRect = [UIScreen mainScreen].bounds;

    _scrollView = [[STPScrollView alloc] initWithFrame:screenRect];
    _scrollView.delegate = self;
    _scrollView.minimumZoomScale = 0.4;
    _scrollView.maximumZoomScale = 1;
    _scrollView.contentSize = CGSizeMake(500, 500);
    
    [self.view addSubview:_scrollView];
    
}
```

## License

  [MIT](LICENSE)
