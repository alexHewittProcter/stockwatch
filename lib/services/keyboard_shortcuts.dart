import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter/material.dart';

/**
 * Keyboard Shortcuts Service
 * 
 * Manages global keyboard shortcuts for StockWatch.
 */

enum StockWatchShortcut {
  globalSearch,     // Cmd+K
  refresh,          // Cmd+R
  newDashboard,     // Cmd+N
  newTrade,         // Cmd+T
  settings,         // Cmd+,
  help,             // Cmd+/
  filter,           // Cmd+F
  dashboard1,       // Cmd+1
  dashboard2,       // Cmd+2
  dashboard3,       // Cmd+3
  dashboard4,       // Cmd+4
  dashboard5,       // Cmd+5
  dashboard6,       // Cmd+6
  dashboard7,       // Cmd+7
  dashboard8,       // Cmd+8
  dashboard9,       // Cmd+9
  escape,           // Escape
}

class KeyboardShortcutService {
  static final KeyboardShortcutService _instance = KeyboardShortcutService._internal();
  factory KeyboardShortcutService() => _instance;
  KeyboardShortcutService._internal();

  final Map<StockWatchShortcut, VoidCallback?> _handlers = {};
  final Map<LogicalKeySet, StockWatchShortcut> _keyMappings = {};

  bool _initialized = false;

  void initialize() {
    if (_initialized) return;

    // Initialize key mappings
    _setupKeyMappings();
    _initialized = true;
  }

  void _setupKeyMappings() {
    _keyMappings.clear();

    // Meta key (Cmd on macOS, Ctrl on others)
    final metaKey = defaultTargetPlatform == TargetPlatform.macOS
        ? LogicalKeyboardKey.meta
        : LogicalKeyboardKey.control;

    _keyMappings[LogicalKeySet(metaKey, LogicalKeyboardKey.keyK)] = StockWatchShortcut.globalSearch;
    _keyMappings[LogicalKeySet(metaKey, LogicalKeyboardKey.keyR)] = StockWatchShortcut.refresh;
    _keyMappings[LogicalKeySet(metaKey, LogicalKeyboardKey.keyN)] = StockWatchShortcut.newDashboard;
    _keyMappings[LogicalKeySet(metaKey, LogicalKeyboardKey.keyT)] = StockWatchShortcut.newTrade;
    _keyMappings[LogicalKeySet(metaKey, LogicalKeyboardKey.comma)] = StockWatchShortcut.settings;
    _keyMappings[LogicalKeySet(metaKey, LogicalKeyboardKey.slash)] = StockWatchShortcut.help;
    _keyMappings[LogicalKeySet(metaKey, LogicalKeyboardKey.keyF)] = StockWatchShortcut.filter;

    // Dashboard shortcuts
    _keyMappings[LogicalKeySet(metaKey, LogicalKeyboardKey.digit1)] = StockWatchShortcut.dashboard1;
    _keyMappings[LogicalKeySet(metaKey, LogicalKeyboardKey.digit2)] = StockWatchShortcut.dashboard2;
    _keyMappings[LogicalKeySet(metaKey, LogicalKeyboardKey.digit3)] = StockWatchShortcut.dashboard3;
    _keyMappings[LogicalKeySet(metaKey, LogicalKeyboardKey.digit4)] = StockWatchShortcut.dashboard4;
    _keyMappings[LogicalKeySet(metaKey, LogicalKeyboardKey.digit5)] = StockWatchShortcut.dashboard5;
    _keyMappings[LogicalKeySet(metaKey, LogicalKeyboardKey.digit6)] = StockWatchShortcut.dashboard6;
    _keyMappings[LogicalKeySet(metaKey, LogicalKeyboardKey.digit7)] = StockWatchShortcut.dashboard7;
    _keyMappings[LogicalKeySet(metaKey, LogicalKeyboardKey.digit8)] = StockWatchShortcut.dashboard8;
    _keyMappings[LogicalKeySet(metaKey, LogicalKeyboardKey.digit9)] = StockWatchShortcut.dashboard9;

    // Escape key
    _keyMappings[LogicalKeySet(LogicalKeyboardKey.escape)] = StockWatchShortcut.escape;
  }

  void registerHandler(StockWatchShortcut shortcut, VoidCallback? handler) {
    _handlers[shortcut] = handler;
  }

  void unregisterHandler(StockWatchShortcut shortcut) {
    _handlers.remove(shortcut);
  }

  void clearAllHandlers() {
    _handlers.clear();
  }

  bool handleKeyEvent(KeyEvent event) {
    if (!_initialized) return false;
    if (event is! KeyDownEvent) return false;

    final keysPressed = HardwareKeyboard.instance.logicalKeysPressed;
    
    for (final keyMapping in _keyMappings.entries) {
      if (_keySetMatches(keyMapping.key, keysPressed)) {
        final handler = _handlers[keyMapping.value];
        if (handler != null) {
          handler();
          return true;
        }
      }
    }

    return false;
  }

  bool _keySetMatches(LogicalKeySet keySet, Set<LogicalKeyboardKey> pressed) {
    if (keySet.keys.length != pressed.length) return false;
    return keySet.keys.every((key) => pressed.contains(key));
  }

  Widget buildShortcutsWrapper({required Widget child}) {
    if (!_initialized) initialize();

    return Focus(
      autofocus: true,
      onKeyEvent: (node, event) {
        if (handleKeyEvent(event)) {
          return KeyEventResult.handled;
        }
        return KeyEventResult.ignored;
      },
      child: child,
    );
  }

  Map<StockWatchShortcut, String> getShortcutDescriptions() {
    final metaSymbol = defaultTargetPlatform == TargetPlatform.macOS ? '⌘' : 'Ctrl';
    
    return {
      StockWatchShortcut.globalSearch: '$metaSymbol+K - Global search',
      StockWatchShortcut.refresh: '$metaSymbol+R - Refresh current view',
      StockWatchShortcut.newDashboard: '$metaSymbol+N - New dashboard',
      StockWatchShortcut.newTrade: '$metaSymbol+T - New trade',
      StockWatchShortcut.settings: '$metaSymbol+, - Settings',
      StockWatchShortcut.help: '$metaSymbol+/ - Keyboard shortcuts help',
      StockWatchShortcut.filter: '$metaSymbol+F - Filter current view',
      StockWatchShortcut.dashboard1: '$metaSymbol+1 - Switch to dashboard 1',
      StockWatchShortcut.dashboard2: '$metaSymbol+2 - Switch to dashboard 2',
      StockWatchShortcut.dashboard3: '$metaSymbol+3 - Switch to dashboard 3',
      StockWatchShortcut.dashboard4: '$metaSymbol+4 - Switch to dashboard 4',
      StockWatchShortcut.dashboard5: '$metaSymbol+5 - Switch to dashboard 5',
      StockWatchShortcut.dashboard6: '$metaSymbol+6 - Switch to dashboard 6',
      StockWatchShortcut.dashboard7: '$metaSymbol+7 - Switch to dashboard 7',
      StockWatchShortcut.dashboard8: '$metaSymbol+8 - Switch to dashboard 8',
      StockWatchShortcut.dashboard9: '$metaSymbol+9 - Switch to dashboard 9',
      StockWatchShortcut.escape: 'Escape - Close modal/overlay',
    };
  }

  List<Map<String, String>> getShortcutsList() {
    final descriptions = getShortcutDescriptions();
    return descriptions.entries.map((entry) {
      final parts = entry.value.split(' - ');
      return {
        'shortcut': parts[0],
        'description': parts.length > 1 ? parts[1] : '',
      };
    }).toList();
  }
}

class KeyboardShortcutHandler extends StatefulWidget {
  final Widget child;
  final Map<StockWatchShortcut, VoidCallback>? shortcuts;

  const KeyboardShortcutHandler({
    super.key,
    required this.child,
    this.shortcuts,
  });

  @override
  State<KeyboardShortcutHandler> createState() => _KeyboardShortcutHandlerState();
}

class _KeyboardShortcutHandlerState extends State<KeyboardShortcutHandler> {
  final _shortcutService = KeyboardShortcutService();

  @override
  void initState() {
    super.initState();
    _registerShortcuts();
  }

  @override
  void didUpdateWidget(KeyboardShortcutHandler oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.shortcuts != oldWidget.shortcuts) {
      _registerShortcuts();
    }
  }

  @override
  void dispose() {
    _shortcutService.clearAllHandlers();
    super.dispose();
  }

  void _registerShortcuts() {
    _shortcutService.clearAllHandlers();
    
    if (widget.shortcuts != null) {
      widget.shortcuts!.forEach((shortcut, callback) {
        _shortcutService.registerHandler(shortcut, callback);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return _shortcutService.buildShortcutsWrapper(child: widget.child);
  }
}

// Helper widget for keyboard shortcut help overlay
class KeyboardShortcutHelp extends StatelessWidget {
  final VoidCallback? onClose;

  const KeyboardShortcutHelp({super.key, this.onClose});

  @override
  Widget build(BuildContext context) {
    final shortcuts = KeyboardShortcutService().getShortcutsList();
    
    return Container(
      padding: const EdgeInsets.all(24),
      constraints: const BoxConstraints(maxWidth: 500, maxHeight: 600),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                'Keyboard Shortcuts',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const Spacer(),
              if (onClose != null)
                IconButton(
                  onPressed: onClose,
                  icon: const Icon(Icons.close),
                ),
            ],
          ),
          const SizedBox(height: 16),
          Flexible(
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: shortcuts.length,
              itemBuilder: (context, index) {
                final shortcut = shortcuts[index];
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Theme.of(context).brightness == Brightness.dark
                              ? Colors.grey[800]
                              : Colors.grey[200],
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          shortcut['shortcut']!,
                          style: TextStyle(
                            fontFamily: 'monospace',
                            fontSize: 12,
                            color: Theme.of(context).brightness == Brightness.dark
                                ? Colors.grey[300]
                                : Colors.grey[700],
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Text(
                          shortcut['description']!,
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}