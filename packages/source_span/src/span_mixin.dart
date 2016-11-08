// Copyright (c) 2014, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:math' as math;
import 'package:path/path.dart' as p;

import 'colors.dart' as colors;
import 'span.dart';
import 'span_with_context.dart';
import 'utils.dart';

/// A mixin for easily implementing [SourceSpan].
///
/// This implements the [SourceSpan] methods in terms of [start], [end], and
/// [text]. This assumes that [start] and [end] have the same source URL, that
/// [start] comes before [end], and that [text] has a number of characters equal
/// to the distance between [start] and [end].
abstract class SourceSpanMixin implements SourceSpan {
  Uri get sourceUrl => start.sourceUrl;
  int get length => end.offset - start.offset;

  int compareTo(SourceSpan other) {
    var result = start.compareTo(other.start);
    return result == 0 ? end.compareTo(other.end) : result;
  }

  SourceSpan union(SourceSpan other) {
    if (sourceUrl != other.sourceUrl) {
      throw new ArgumentError("Source URLs \"${sourceUrl}\" and "
          " \"${other.sourceUrl}\" don't match.");
    }

    var start = min(this.start, other.start);
    var end = max(this.end, other.end);
    var beginSpan = start == this.start ? this : other;
    var endSpan = end == this.end ? this : other;

    if (beginSpan.end.compareTo(endSpan.start) < 0) {
      throw new ArgumentError("Spans $this and $other are disjoint.");
    }

    var text = beginSpan.text +
        endSpan.text.substring(beginSpan.end.distance(endSpan.start));
    return new SourceSpan(start, end, text);
  }

  String message(String message, {color}) {
    if (color == true) color = colors.RED;
    if (color == false) color = null;

    var line = start.line;
    var column = start.column;

    var buffer = new StringBuffer();
    buffer.write('line ${line + 1}, column ${column + 1}');
    if (sourceUrl != null) buffer.write(' of ${p.prettyUri(sourceUrl)}');
    buffer.write(': $message');

    if (length == 0 && this is! SourceSpanWithContext) return buffer.toString();
    buffer.write("\n");

    String textLine;
    if (this is SourceSpanWithContext) {
      var context = (this as SourceSpanWithContext).context;
      var lineStart = findLineStart(context, text, column);
      if (lineStart != null && lineStart > 0) {
        buffer.write(context.substring(0, lineStart));
        context = context.substring(lineStart);
      }
      var endIndex = context.indexOf('\n');
      textLine = endIndex == -1 ? context : context.substring(0, endIndex + 1);
      column = math.min(column, textLine.length);
    } else {
      textLine = text.split("\n").first;
      column = 0;
    }

    var toColumn =
        math.min(column + end.offset - start.offset, textLine.length);
    if (color != null) {
      buffer.write(textLine.substring(0, column));
      buffer.write(color);
      buffer.write(textLine.substring(column, toColumn));
      buffer.write(colors.NONE);
      buffer.write(textLine.substring(toColumn));
    } else {
      buffer.write(textLine);
    }
    if (!textLine.endsWith('\n')) buffer.write('\n');
    buffer.write(' ' * column);
    if (color != null) buffer.write(color);
    buffer.write('^' * math.max(toColumn - column, 1));
    if (color != null) buffer.write(colors.NONE);
    return buffer.toString();
  }

  bool operator ==(other) => other is SourceSpan &&
      start == other.start && end == other.end;

  int get hashCode => start.hashCode + (31 * end.hashCode);

  String toString() => '<$runtimeType: from $start to $end "$text">';
}
