/// Provides the [SpatialHash] class.
///
/// This library is code copied from the
/// [spatialhash](https://github.com/novemberisms/spatialhash) package. That
/// package was never converted to null safety, and my
/// [issue](https://github.com/novemberisms/spatialhash/issues/1) never
/// received a response.
import 'dart:collection';
import 'dart:math';

/// A Spatial Hash is a specialized data structure used for efficiently querying
/// its contents based on their
/// spatial relationship to each other. In other words, if you have an object
/// with a known location in space and a size,
/// storing it in a spatial hash will allow you to efficiently query for all
/// other objects nearby, without having to iterate
/// over all the other items stored within. Common applications for Spatial
/// Hashes include collision detection in games, and
/// map-based routing.
///
/// It is comprised of a 'grid' of cells, and each object stored in the Spatial
/// Hash occupies a number of cells. Efficient queries
/// are made by fetching only objects that occupy the same cells.
class SpatialHash<T> {
  /// Creates a new empty spatial hash with `width` x `height` cells, where each
  /// cell has dimensions
  /// `cellWidth` x `cellHeight`. this spatial hash will have its internal
  /// origin set at `origin`.
  SpatialHash(this.width, this.height, this.cellWidth, this.cellHeight,
      [Point origin = const Point(0, 0)])
      : assert(width > 0 && height > 0,
            'the width and height of a spatial hash must both be > 0'),
        assert(cellWidth > 0 && cellHeight > 0,
            'the cell width and cell height of a spatial hash must be > 0'),
        _data = _generateInitialData<T>(
            width, height, cellWidth, cellHeight, origin),
        _itemLookup = HashMap(),
        boundingBox = Rectangle(
            origin.x, origin.y, width * cellWidth, height * cellHeight);

  final List<SpatialHashCell<T>> _data;
  final HashMap<T, List<SpatialHashCell<T>>> _itemLookup;

  /// How many cells wide this spatial hash extends horizontally
  final int width;

  /// How many cells tall this spatial hash extends vertically
  final int height;

  /// Width of each cell in this spatial hash
  final num cellWidth;

  /// Height of each cell in this spatial hash
  final num cellHeight;

  /// Bounding box of this spatial hash.
  ///
  /// Note that objects stored in this spatial hash that lie outside of this
  /// bounding box
  /// are still able to be fetched and queried. They are stored on the boundary
  /// cells closest to their
  /// actual location in space. In essence, if you have an object at
  /// `-1000, -1000` and the bounding box
  /// of this hash only begins at the point `0, 0`, then the object will be
  /// stored at the cell `0, 0`, no matter
  /// how far diagonally the object is.
  final Rectangle boundingBox;

  static List<SpatialHashCell<T>> _generateInitialData<T>(
          int width, int height, num cellWidth, num cellHeight, Point origin) =>
      List.generate(width * height, (i) {
        final left = origin.x + (i % width) * cellWidth;
        final top = origin.y + (i / width).floor() * cellHeight;
        return SpatialHashCell<T>(Rectangle(left, top, cellWidth, cellHeight));
      }, growable: false);

  /// Clears all objects from the cells of the spatial hash
  void clear() {
    for (final cell in _data) {
      cell.clear();
    }
    _itemLookup.clear();
  }

  /// Adds an `item` to the spatial hash at the specified `location`. Use
  /// [update] if you wish to further
  /// update the position of the item later on.
  void add(T item, Rectangle location) {
    if (contains(item)) {
      throw StateError('Item is already in the spatial hash');
    }

    final startGrid = _grid(location.topLeft);
    final endGrid = _grid(location.bottomRight);

    _itemLookup[item] = [];

    for (var gy = startGrid.y; gy <= endGrid.y; gy++) {
      for (var gx = startGrid.x; gx <= endGrid.x; gx++) {
        final cell = _cell(gx, gy)..add(item);
        _itemLookup[item]!.add(cell);
      }
    }
  }

  /// Updates the position of the `item` within the spatial hash to a new
  /// location. If the item
  /// has not yet been added, throws a `StateError`.
  void update(T item, Rectangle newLocation) {
    if (!remove(item)) {
      throw StateError(
          'Cannot update an item that has not been added to the spatial hash');
    }
    add(item, newLocation);
  }

  /// Removes an `item` from the spatial hash. returns `true` if the item was in
  /// the spatial hash
  /// or `false` if the item was not already in it.
  bool remove(T item) {
    if (!contains(item)) {
      return false;
    }
    final items = _itemLookup[item];
    if (items != null) {
      for (final cell in items) {
        cell.remove(item);
      }
    }
    _itemLookup.remove(item);
    return true;
  }

  /// Returns `true` if the `item` has been added to the spatial hash
  bool contains(T item) => _itemLookup.containsKey(item);

  /// Returns an iterable that goes over all cells in the specified rectangular
  /// `region` in worldspace.
  /// note that the same item may occur in more than one of these cells.
  /// if you wish to iterate over all objects in a given region with each object
  /// only appearing once, use
  /// the `itemsInRegion` method.
  ///
  /// The [SpatialHashCell]s returned by this iterable are copies, and so
  /// modifying them will not modify the
  /// contents of the spatial hash itself.
  Iterable<SpatialHashCell<T>> cellsAt(Rectangle region) {
    final startGrid = _grid(region.topLeft);
    final endGrid = _grid(region.bottomRight);
    final gridWidth = endGrid.x - startGrid.x + 1;
    final gridHeight = endGrid.y - startGrid.y + 1;

    return Iterable.generate(
      gridWidth * gridHeight,
      (i) => SpatialHashCell.copy(
        _cell(
          startGrid.x + i % gridWidth,
          startGrid.y + (i / gridWidth).floor(),
        ),
      ),
    );
  }

  /// Returns a [Set] containing all the items present in a given rectangular
  /// `region` of space.
  /// Being a [Set], it is guaranteed that all items will only appear once
  /// within it.
  Set<T> itemsInRegion(Rectangle region) {
    final result = <T>{};
    for (final cell in cellsAt(region)) {
      result.addAll(cell._contents);
    }
    return result;
  }

  /// Returns a [Set] containing all the items occupying the same cells as
  /// `item`. The item itself does not appear in this set. Use this for
  /// efficient collision detection.
  ///
  /// Note that the items in this set
  /// are only **potentially** close enough to collide with the item. You will
  /// then need to run a collision
  /// detection algorithm on the contents of this set to precisely detect
  /// collisions. The goal of a [SpatialHash]
  /// is to merely reduce the number of objects you have to check against for
  /// detecting collisions. It does not give
  /// a definitive list of objects colliding with the given item.
  Set<T> near(T item) {
    final result = <T>{};
    final items = _itemLookup[item];
    if (items != null) {
      for (final cell in items) {
        result.addAll(cell._contents);
      }
    }
    result.remove(item);
    return result;
  }

  /// Returns a [Set] containing all the items occupying the same cells as
  /// `item`, as well as all items
  /// occupying the cells within a given **rectangular** `range` in world-space.
  ///
  /// Example, if an object is located at `0, 0`, then calling
  /// `range(item, 300)` will return a set of all
  /// objects that are contained in [SpatialHashCell]s within `300` pixels (or
  /// whatever unit you use) of the
  /// boundaries of the cell containing the item. So if the `cellWidth` and
  /// `cellHeight` of the spatial hash are
  /// `100 x 100`, then it will query the space from `-300, -300` to `400, 400`.
  ///
  /// Use this to query for objects within a certain range of the object. Note
  /// that if you wish to query a circular range,
  /// or if you need more precise range detection, you will then need to filter
  /// the contents of the returned set yourself.
  Set<T> range(T item, num range) {
    final rangeVector = Point(range, range);
    final regionTopLeft = _itemLookup[item]!.first.rect.topLeft - rangeVector;
    final regionBottomRight =
        _itemLookup[item]!.last.rect.bottomRight + rangeVector;
    final regionWidth = regionBottomRight.x - regionTopLeft.x;
    final regionHeight = regionBottomRight.y - regionTopLeft.y;

    final result = itemsInRegion(
        Rectangle(regionTopLeft.x, regionTopLeft.y, regionWidth, regionHeight))
      ..remove(item);
    return result;
  }

  /// Returns a cell containing all the added items for the cell corresponding
  /// to the given world-space coordinate.
  /// Note that this cell is a copy and so changing its contents won't affect
  /// the spatial hash.
  SpatialHashCell<T> cellAt(num x, num y) => SpatialHashCell.copy(
      _cell((x / cellWidth).floor(), (y / cellHeight).floor()));

  /// Gives the cell assigned to the grid coordinates. This clamps the values so
  /// that
  /// grid coordinates outside the range of the hash will be assigned to the
  /// border cells
  SpatialHashCell<T> _cell(int gx, int gy) =>
      _data[gx.clamp(0, width - 1) + gy.clamp(0, height - 1) * width];

  /// Gives a point in grid-space that corresponds to the grid coordinates of
  /// the cell covering this point
  /// in world-space
  Point<int> _grid(Point worldCoords) => Point(
      (worldCoords.x / cellWidth).floor().clamp(0, width - 1),
      (worldCoords.y / cellHeight).floor().clamp(0, height - 1));
}

/// A cell within a [SpatialHash]. It keeps track of all its contents and its
/// position and extent in space.
class SpatialHashCell<T> with IterableMixin<T> {
  /// Create a cell.
  SpatialHashCell(this.rect);

  /// Creates a copy of this cell with the same contents and location.
  factory SpatialHashCell.copy(SpatialHashCell<T> existing) =>
      SpatialHashCell<T>(existing.rect).._contents.addAll(existing._contents);

  /// The bounding box for this cell. This cannot be changed.
  final Rectangle rect;
  final Set<T> _contents = {};

  @override
  Iterator<T> get iterator => _contents.iterator;

  /// Creates a [Set] out of all the items in this cell.
  @override
  Set<T> toSet() => _contents.toSet();

  /// Creates a [List] containing all the items in this cell.
  @override
  List<T> toList({bool growable = true}) =>
      _contents.toList(growable: growable);

  /// Clears all items from this cell.
  void clear() => _contents.clear();

  /// Adds an `item` to this cell.
  ///
  /// Returns `true` if the item was not yet in the
  /// cell.
  bool add(T item) => _contents.add(item);

  /// Removes an `item` from this cell.
  ///
  /// Returns `true` if the item was previously present in the cell.
  bool remove(T item) => _contents.remove(item);
}
