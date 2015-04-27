## STPScrollView
STPScrollView is UIScrollView like scroll view.
UIScrollView can not change build-in gesture recognizers.

```objective-c
// Use these accessors to configure the scroll view's built-in gesture recognizers.
// Do not change the gestures' delegates or override the getters for these properties.
@property(nonatomic, readonly) UIPanGestureRecognizer *panGestureRecognizer NS_AVAILABLE_IOS(5_0);
// `pinchGestureRecognizer` will return nil when zooming is disabled.
@property(nonatomic, readonly) UIPinchGestureRecognizer *pinchGestureRecognizer NS_AVAILABLE_IOS(5_0);
```


## Quick Start
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
