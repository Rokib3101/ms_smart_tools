import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:ms_smart_tools/core/utils/core_utils.dart';
import 'package:intl/intl.dart';
import '../calculator_logic.dart';

class CalculatorScreen extends StatefulWidget {
  const CalculatorScreen({super.key});

  @override
  State<CalculatorScreen> createState() => _CalculatorScreenState();
}

class _CalculatorScreenState extends State<CalculatorScreen> {
  final CalculatorLogic _logic = CalculatorLogic();
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final FocusNode _focusNode = FocusNode();
  bool _showScientific = false;

  @override
  void initState() {
    super.initState();
    _controller.addListener(_onCursorChanged);
    _loadHistory();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _focusNode.requestFocus();
    });
  }

  Future<void> _loadHistory() async {
    await _logic.loadHistory();
    if (mounted) {
      setState(() {});
    }
  }

  @override
  void dispose() {
    _controller.removeListener(_onCursorChanged);
    _controller.dispose();
    _scrollController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _onCursorChanged() {
    if (_controller.selection.baseOffset >= 0) {
      _logic.cursorIndex = _controller.selection.baseOffset;
    }
  }

  void _scrollToCursor() {
    if (!_scrollController.hasClients) return;

    final maxScroll = _scrollController.position.maxScrollExtent;
    if (maxScroll <= 0) return;

    if (_logic.cursorIndex >= _logic.expression.length) {
      _scrollController.jumpTo(maxScroll);
      return;
    }

    if (_logic.cursorIndex <= 0) {
      _scrollController.jumpTo(0);
      return;
    }

    final text = _controller.text;
    final textBeforeCursor = text.substring(0, _logic.cursorIndex.clamp(0, text.length));

    final tp = TextPainter(
      text: TextSpan(
        text: textBeforeCursor,
        style: const TextStyle(fontSize: 36, color: Colors.black87, fontWeight: FontWeight.w400),
      ),
      textDirection: ui.TextDirection.ltr,
    )..layout();

    final cursorX = tp.width;
    final currentScroll = _scrollController.offset;
    final viewportWidth = _scrollController.position.viewportDimension;

    const padding = 30.0;

    if (cursorX > currentScroll + viewportWidth - padding) {
      double target = cursorX - viewportWidth + padding;
      if (target > maxScroll) target = maxScroll;
      _scrollController.jumpTo(target);
    } else if (cursorX < currentScroll + padding) {
      double target = cursorX - padding;
      if (target < 0) target = 0;
      _scrollController.jumpTo(target);
    }
  }

  void _updateControllerAndScroll() {
    final displayExpr = _logic.expression;
    _controller.value = TextEditingValue(
      text: displayExpr,
      selection: TextSelection.collapsed(offset: _logic.cursorIndex.clamp(0, displayExpr.length)),
    );

    _focusNode.requestFocus();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollToCursor();
    });
  }

  void _onPressed(String btnText) {
    setState(() {
      if (btnText == '←') {
        _logic.moveLeft();
      } else if (btnText == '→') {
        _logic.moveRight();
      } else {
        _logic.append(btnText);
      }

      _updateControllerAndScroll();
    });
  }

  Future<void> _pasteFromClipboard() async {
    final clipboardData = await Clipboard.getData(Clipboard.kTextPlain);
    final rawText = clipboardData?.text;

    if (rawText == null || rawText.trim().isEmpty) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No text found in clipboard'),
          duration: Duration(seconds: 2),
        ),
      );
      return;
    }

    final sanitized = _sanitizePastedText(rawText);

    if (sanitized.isEmpty) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No valid numbers or math operators found to paste'),
          duration: Duration(seconds: 2),
        ),
      );
      return;
    }

    setState(() {
      _logic.insertText(sanitized);
      _updateControllerAndScroll();
    });

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Pasted from clipboard'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  String _sanitizePastedText(String input) {
    String text = BanglaUtils.toEnglish(input);

    text = text
        .replaceAll('*', '×')
        .replaceAll('x', '×')
        .replaceAll('X', '×')
        .replaceAll('/', '÷')
        .replaceAll('–', '-')
        .replaceAll('—', '-');

    text = text
        .replaceAll(',', '')
        .replaceAll(' ', '')
        .replaceAll('৳', '')
        .replaceAll('\$', '');

    final validBuffer = StringBuffer();
    final allowedChars = RegExp(r'[0-9\+\-\×\÷\.\%\^\(\)πe!√]');

    int i = 0;
    while (i < text.length) {
      bool matchedFunc = false;
      for (final func in ['arcsin', 'arccos', 'arctan', 'asin', 'acos', 'atan', 'sqrt', 'sin', 'cos', 'tan', 'log', 'ln']) {
        if (text.startsWith(func, i)) {
          validBuffer.write(func);
          i += func.length;
          matchedFunc = true;
          break;
        }
      }
      if (matchedFunc) continue;

      final char = text[i];
      if (allowedChars.hasMatch(char)) {
        validBuffer.write(char);
      }
      i++;
    }

    return validBuffer.toString();
  }

  Future<void> _copyInputText() async {
    final selection = _controller.selection;
    String textToCopy = _controller.text;

    if (selection.isValid && !selection.isCollapsed) {
      final selectedSubstring = selection.textInside(_controller.text);
      if (selectedSubstring.isNotEmpty) {
        textToCopy = selectedSubstring;
      }
    }

    if (textToCopy.trim().isEmpty) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No input text to copy'),
          duration: Duration(seconds: 2),
        ),
      );
      return;
    }

    await Clipboard.setData(ClipboardData(text: textToCopy));

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Copied: $textToCopy'),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  Future<void> _copyResult() async {
    final resultText = _logic.result;

    if (resultText.isEmpty || resultText == 'Error') {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No valid result to copy'),
          duration: Duration(seconds: 2),
        ),
      );
      return;
    }

    await Clipboard.setData(ClipboardData(text: resultText));

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Result copied: $resultText'),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _showHistory() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(28))),
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.6,
        maxChildSize: 0.9,
        expand: false,
        builder: (context, scrollController) => Column(
          children: [
            const SizedBox(height: 12),
            Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(2))),
            Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('History', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                  TextButton.icon(
                    onPressed: () async {
                      await _logic.clearHistory();
                      if (context.mounted) {
                        setState(() {});
                        Navigator.pop(context);
                      }
                    },
                    icon: const Icon(Icons.delete_sweep, color: Colors.red),
                    label: const Text('Clear All', style: TextStyle(color: Colors.red)),
                  ),
                ],
              ),
            ),
            const Divider(height: 1),
            Expanded(
              child: _logic.historyList.isEmpty
                  ? const Center(child: Text('No history available', style: TextStyle(color: Colors.grey)))
                  : ListView.separated(
                      controller: scrollController,
                      padding: const EdgeInsets.all(16),
                      itemCount: _logic.historyList.length,
                      separatorBuilder: (_, __) => const Divider(),
                      itemBuilder: (context, index) {
                        final item = _logic.historyList[index];
                        return ListTile(
                          title: Text(
                            item.expression,
                            style: const TextStyle(fontSize: 16, color: Colors.black54),
                          ),
                          subtitle: Text(
                            DateFormat('hh:mm a, dd MMM').format(item.timestamp),
                            style: const TextStyle(fontSize: 12),
                          ),
                          trailing: Text(
                            item.result,
                            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.blue),
                          ),
                          onTap: () {
                            setState(() {
                              _logic.expression = item.result;
                              _logic.isEvaluated = false;
                              _logic.cursorIndex = _logic.expression.length;
                              _updateControllerAndScroll();
                            });
                            Navigator.pop(context);
                          },
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F9FC),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          _showScientific ? 'Scientific Calculator' : 'Smart Calculator',
          style: const TextStyle(color: Colors.black87, fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.history, color: Colors.blue),
            onPressed: _showHistory,
            tooltip: 'History',
          ),
          IconButton(
            icon: Icon(_showScientific ? Icons.science : Icons.science_outlined, color: Colors.blue),
            onPressed: () => setState(() => _showScientific = !_showScientific),
            tooltip: 'Scientific Mode',
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            flex: _showScientific ? 2 : 3,
            child: _buildDisplay(),
          ),
          _buildMemoryBar(),
          const Divider(height: 1, color: Colors.black12),
          Expanded(
            flex: _showScientific ? 8 : 7,
            child: _buildKeypad(),
          ),
        ],
      ),
    );
  }

  Widget _buildDisplay() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
      alignment: Alignment.bottomRight,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              if (_logic.memory != 0)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(color: Colors.blue[50], borderRadius: BorderRadius.circular(8)),
                  child: Text(
                    'M: ${_logic.memory.toStringAsFixed(0)}',
                    style: const TextStyle(fontSize: 12, color: Colors.blue, fontWeight: FontWeight.bold),
                  ),
                )
              else
                const SizedBox.shrink(),
              if (_showScientific)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(color: Colors.indigo[50], borderRadius: BorderRadius.circular(8)),
                  child: Text(
                    _logic.isDegreeMode ? 'DEG' : 'RAD',
                    style: TextStyle(fontSize: 12, color: Colors.indigo[800], fontWeight: FontWeight.bold),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 4),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              if (_logic.lastCalculation.isNotEmpty)
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  reverse: true,
                  child: Text(
                    _logic.lastCalculation,
                    style: const TextStyle(fontSize: 18, color: Colors.black38, letterSpacing: 1.1),
                  ),
                ),
              const SizedBox(height: 4),
              TextField(
                controller: _controller,
                scrollController: _scrollController,
                focusNode: _focusNode,
                readOnly: true,
                showCursor: true,
                enableInteractiveSelection: true,
                scrollPhysics: const BouncingScrollPhysics(),
                textAlign: TextAlign.right,
                style: const TextStyle(fontSize: 36, color: Colors.black87, fontWeight: FontWeight.w400),
                decoration: const InputDecoration(
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.zero,
                ),
                contextMenuBuilder: (BuildContext context, EditableTextState editableTextState) {
                  final List<ContextMenuButtonItem> buttonItems = [
                    ContextMenuButtonItem(
                      label: 'Copy',
                      onPressed: () {
                        editableTextState.hideToolbar();
                        _copyInputText();
                      },
                    ),
                    ContextMenuButtonItem(
                      label: 'Paste',
                      onPressed: () {
                        editableTextState.hideToolbar();
                        _pasteFromClipboard();
                      },
                    ),
                  ];
                  return AdaptiveTextSelectionToolbar.buttonItems(
                    anchors: editableTextState.contextMenuAnchors,
                    buttonItems: buttonItems,
                  );
                },
              ),
            ],
          ),
          const SizedBox(height: 8),
          SelectableText(
            _logic.result,
            textAlign: TextAlign.right,
            style: TextStyle(
              fontSize: 48,
              fontWeight: FontWeight.bold,
              color: _logic.isEvaluated ? Colors.green[700] : Colors.blue[700],
            ),
            contextMenuBuilder: (BuildContext context, EditableTextState editableTextState) {
              final List<ContextMenuButtonItem> buttonItems = [
                ContextMenuButtonItem(
                  label: 'Copy Result',
                  onPressed: () {
                    editableTextState.hideToolbar();
                    _copyResult();
                  },
                ),
              ];
              return AdaptiveTextSelectionToolbar.buttonItems(
                anchors: editableTextState.contextMenuAnchors,
                buttonItems: buttonItems,
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildMemoryBar() {
    final memButtons = ['MC', 'MR', 'M+', 'M-'];
    return Container(
      height: 38,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: memButtons.map((btn) => TextButton(
          onPressed: () => _onPressed(btn),
          style: TextButton.styleFrom(visualDensity: VisualDensity.compact),
          child: Text(btn, style: const TextStyle(color: Colors.blueGrey, fontWeight: FontWeight.bold, fontSize: 13)),
        )).toList(),
      ),
    );
  }

  Widget _buildKeypad() {
    final List<List<String>> basicRows = [
      ['AC', '( )', '%', '÷'],
      ['7', '8', '9', '×'],
      ['4', '5', '6', '-'],
      ['1', '2', '3', '+'],
      ['⌫', '0', '.', '='],
    ];

    final List<List<String>> scientificRows = [
      [_logic.isInverse ? 'x²' : '√', 'π', '^', '!'],
      [_logic.isDegreeMode ? 'Deg' : 'Rad', _logic.isInverse ? 'asin' : 'sin', _logic.isInverse ? 'acos' : 'cos', _logic.isInverse ? 'atan' : 'tan'],
      ['Inv', 'e', _logic.isInverse ? 'eˣ' : 'ln', _logic.isInverse ? '10ˣ' : 'log'],
      ['AC', '( )', '%', '÷'],
    ];

    return Container(
      padding: const EdgeInsets.fromLTRB(10, 6, 10, 10),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
        boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 10, offset: Offset(0, -2))],
      ),
      child: SafeArea(
        top: false,
        child: Column(
          children: [
            if (_showScientific) ...[
              ...scientificRows.map((row) => Expanded(
                child: Row(
                  children: row.map((btn) => Expanded(child: _buildButton(btn, isScientific: true))).toList(),
                ),
              )),
              const Divider(height: 8, indent: 20, endIndent: 20),
            ],
            ...(_showScientific ? basicRows.sublist(1) : basicRows).map((row) => Expanded(
              child: Row(
                children: row.map((btn) => Expanded(child: _buildButton(btn))).toList(),
              ),
            )),
          ],
        ),
      ),
    );
  }

  Widget _buildButton(String text, {bool isScientific = false}) {
    bool isOperator = ['÷', '×', '-', '+', '=', 'AC', '( )', '⌫', '^', '!', '√', 'π', 'Deg', 'Rad', 'sin', 'cos', 'tan', 'asin', 'acos', 'atan', 'Inv', 'e', 'ln', 'log', 'eˣ', '10ˣ', 'x²', '%'].contains(text);
    bool isAction = ['=', 'AC', '⌫'].contains(text);
    bool isMainOperator = ['÷', '×', '-', '+'].contains(text);

    Color bgColor;
    Color textColor;

    if (text == '=') {
      bgColor = Colors.blue[600]!;
      textColor = Colors.white;
    } else if (text == 'AC') {
      bgColor = Colors.orange[100]!;
      textColor = Colors.orange[900]!;
    } else if (text == 'Inv' && _logic.isInverse) {
      bgColor = Colors.indigo[600]!;
      textColor = Colors.white;
    } else if (isMainOperator) {
      bgColor = Colors.blue[50]!;
      textColor = Colors.blue[800]!;
    } else if (isScientific) {
      bgColor = const Color(0xFF2E3B8B).withOpacity(0.12);
      textColor = const Color(0xFF1E2667);
    } else if (isOperator) {
      bgColor = Colors.grey[100]!;
      textColor = Colors.blueGrey[800]!;
    } else {
      bgColor = Colors.white;
      textColor = Colors.black87;
    }

    return Padding(
      padding: const EdgeInsets.all(4),
      child: Material(
        color: bgColor,
        borderRadius: BorderRadius.circular(20),
        elevation: isAction ? 2 : 0,
        child: InkWell(
          onTap: () => _onPressed(text),
          borderRadius: BorderRadius.circular(20),
          child: Center(
            child: Text(
              text,
              style: TextStyle(
                fontSize: isScientific ? 17 : (isOperator ? 20 : 24),
                fontWeight: isOperator ? FontWeight.bold : FontWeight.w500,
                color: textColor,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
