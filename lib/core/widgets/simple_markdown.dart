import 'package:flutter/material.dart';

/// A deliberately small, safe Markdown-ish renderer supporting **bold**,
/// _italic_, `code`, bullet lines (- / *) and blank-line paragraphs. It never
/// renders raw HTML, so untrusted AI/user text cannot inject executable markup.
class SimpleMarkdown extends StatelessWidget {
  const SimpleMarkdown(this.text, {super.key, this.style});

  final String text;
  final TextStyle? style;

  @override
  Widget build(BuildContext context) {
    final TextStyle base =
        style ?? Theme.of(context).textTheme.bodyMedium ?? const TextStyle();
    final List<String> lines = text.replaceAll('\r\n', '\n').split('\n');

    final List<Widget> widgets = [];
    for (final String raw in lines) {
      final String line = raw.trimRight();
      if (line.trim().isEmpty) {
        widgets.add(const SizedBox(height: 6));
        continue;
      }
      final String trimmed = line.trimLeft();
      if (trimmed.startsWith('- ') || trimmed.startsWith('* ')) {
        widgets.add(
          Padding(
            padding: const EdgeInsets.only(bottom: 2),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('•  ', style: base),
                Expanded(
                  child: RichText(text: _inline(trimmed.substring(2), base)),
                ),
              ],
            ),
          ),
        );
      } else {
        widgets.add(
          Padding(
            padding: const EdgeInsets.only(bottom: 2),
            child: RichText(text: _inline(trimmed, base)),
          ),
        );
      }
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: widgets,
    );
  }

  /// Parses inline emphasis into styled [TextSpan]s.
  TextSpan _inline(String input, TextStyle base) {
    final List<TextSpan> spans = [];
    final RegExp pattern = RegExp(r'(\*\*(.+?)\*\*)|(_(.+?)_)|(`(.+?)`)');
    int index = 0;
    for (final Match m in pattern.allMatches(input)) {
      if (m.start > index) {
        spans.add(TextSpan(text: input.substring(index, m.start), style: base));
      }
      if (m.group(2) != null) {
        spans.add(
          TextSpan(
            text: m.group(2),
            style: base.copyWith(fontWeight: FontWeight.bold),
          ),
        );
      } else if (m.group(4) != null) {
        spans.add(
          TextSpan(
            text: m.group(4),
            style: base.copyWith(fontStyle: FontStyle.italic),
          ),
        );
      } else if (m.group(6) != null) {
        spans.add(
          TextSpan(
            text: m.group(6),
            style: base.copyWith(
              fontFamily: 'monospace',
              backgroundColor: Colors.black.withValues(alpha: 0.06),
            ),
          ),
        );
      }
      index = m.end;
    }
    if (index < input.length) {
      spans.add(TextSpan(text: input.substring(index), style: base));
    }
    return TextSpan(children: spans);
  }
}
