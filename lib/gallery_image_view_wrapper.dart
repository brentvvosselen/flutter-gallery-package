import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:galleryimage/app_cached_network_image.dart';
import 'package:photo_view/photo_view.dart';

import 'gallery_item_model.dart';

// to view image in full screen
class GalleryImageViewWrapper extends StatefulWidget {
  final Color? backgroundColor;
  final int? initialIndex;
  final List<GalleryItemModel> galleryItems;
  final String? titleGallery;
  final Widget? loadingWidget;
  final Widget? errorWidget;
  final double radius;
  final bool reverse;
  final bool showListInGallery;
  final PreferredSizeWidget? appBar;
  final bool displayBehindAppBar;
  final bool closeWhenSwipeUp;
  final bool closeWhenSwipeDown;
  final double? minScale;
  final double? maxScale;

  const GalleryImageViewWrapper({
    Key? key,
    this.titleGallery,
    this.backgroundColor,
    this.initialIndex,
    required this.galleryItems,
    this.loadingWidget,
    this.errorWidget,
    required this.radius,
    required this.reverse,
    required this.showListInGallery,
    this.appBar,
    required this.displayBehindAppBar,
    this.closeWhenSwipeUp = false,
    this.closeWhenSwipeDown = false,
    this.minScale,
    this.maxScale,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return _GalleryImageViewWrapperState();
  }
}

class _GalleryImageViewWrapperState extends State<GalleryImageViewWrapper> {
  late final PageController _controller = PageController(initialPage: widget.initialIndex ?? 0);
  late int _currentPage = widget.initialIndex ?? 0;

  bool isZooming = false;

  @override
  void initState() {
    _controller.addListener(() {
      setState(() {
        _currentPage = _controller.page?.toInt() ?? 0;
      });
    });
    super.initState();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: widget.appBar,
      backgroundColor: widget.backgroundColor,
      extendBodyBehindAppBar: widget.displayBehindAppBar,
      body: SafeArea(
        top: !widget.displayBehindAppBar,
        child: Container(
          constraints: BoxConstraints.expand(height: MediaQuery.of(context).size.height),
          child: Column(
            children: [
              Expanded(
                child: GestureDetector(
                  onVerticalDragEnd: (details) {
                    if (widget.closeWhenSwipeUp && details.primaryVelocity! < 0) {
                      //'up'
                      Navigator.of(context).pop();
                    }
                    if (widget.closeWhenSwipeDown && details.primaryVelocity! > 0) {
                      // 'down'
                      Navigator.of(context).pop();
                    }
                  },
                  child: PageView.builder(
                    physics: isZooming ? const NeverScrollableScrollPhysics() : null,
                    reverse: widget.reverse,
                    controller: _controller,
                    itemCount: widget.galleryItems.length,
                    itemBuilder: (context, index) => _buildImage(widget.galleryItems[index]),
                  ),
                ),
              ),
              if (widget.showListInGallery)
                SizedBox(
                  height: 80,
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: widget.galleryItems.map((e) => _buildLitImage(e)).toList(),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

// build image with zooming
  Widget _buildImage(GalleryItemModel item) {
    return Hero(
      tag: item.id,
      child: PhotoView(
        scaleStateChangedCallback: (x) {
          setState(() {
            isZooming = x.isScaleStateZooming;
          });
        },
        minScale: widget.minScale ?? PhotoViewComputedScale.contained,
        maxScale: widget.maxScale,
        errorBuilder: (context, error, stackTrace) {
          return widget.errorWidget ?? const SizedBox.shrink();
        },
        loadingBuilder: (context, event) {
          return widget.loadingWidget ?? const SizedBox.shrink();
        },
        imageProvider: CachedNetworkImageProvider(item.imageUrl),
      ),
    );
  }

// build image with zooming
  Widget _buildLitImage(GalleryItemModel item) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 5),
      child: GestureDetector(
        onTap: () {
          setState(() {
            _controller.jumpToPage(item.index);
          });
        },
        child: AppCachedNetworkImage(
          height: _currentPage == item.index ? 70 : 60,
          width: _currentPage == item.index ? 70 : 60,
          fit: BoxFit.cover,
          imageUrl: item.imageUrl,
          errorWidget: widget.errorWidget,
          radius: widget.radius,
          loadingWidget: widget.loadingWidget,
        ),
      ),
    );
  }
}
