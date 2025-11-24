import 'package:flutter/material.dart';
import 'package:s_dropdown/s_dropdown.dart';
import 'package:sizer/sizer.dart';

void main() {
  runApp(const ExampleApp());
}

class ExampleApp extends StatelessWidget {
  const ExampleApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Sizer(builder: (context, orientation, deviceType) {
      return MaterialApp(
        title: 'SDropdown Example',
        home: const ExampleHome(),
      );
    });
  }
}

class ExampleHome extends StatefulWidget {
  const ExampleHome({super.key});

  @override
  State<ExampleHome> createState() => _ExampleHomeState();
}

class _ExampleHomeState extends State<ExampleHome> {
  final List<String> _items = ['Apple', 'Banana', 'Cherry', 'Durian'];
  String? _selected;
  final SDropdownController _controller = SDropdownController();
  final SDropdownController _controller2 = SDropdownController();
  final SDropdownController _controller3 = SDropdownController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('SDropdown Example')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 16),
            // Basic usage
            SDropdown(
              items: _items,
              selectedItem: _selected,
              hintText: 'Select a fruit',
              onChanged: (value) {
                setState(() {
                  _selected = value;
                });
              },
              width: 280,
              height: 52,
              controller: _controller,
            ),
            const SizedBox(height: 20),
            // Decorated dropdown with overlay size override
            SDropdown(
              items: _items,
              selectedItem: _selected,
              hintText: 'Decorated dropdown',
              onChanged: (value) {
                setState(() {
                  _selected = value;
                });
              },
              width: 300,
              height: 55,
              overlayWidth: 350,
              overlayHeight: 180,
              decoration: SDropdownDecoration(
                closedFillColor: Colors.grey.shade200,
                expandedFillColor: Colors.white,
                closedBorder: Border.all(color: Colors.grey.shade400),
                expandedBorder:
                    Border.all(color: Colors.blue.shade700, width: 1.5),
                closedBorderRadius: BorderRadius.circular(10),
                expandedBorderRadius: BorderRadius.circular(8),
                headerStyle:
                    const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                hintStyle: const TextStyle(fontSize: 16, color: Colors.grey),
                listItemStyle: const TextStyle(fontSize: 14),
              ),
            ),
            const SizedBox(height: 20),
            // Exclude selected from overlay & custom items
            SDropdown(
              items: _items,
              selectedItem: _selected,
              hintText: 'Exclude selected',
              onChanged: (value) {
                setState(() {
                  _selected = value;
                });
              },
              width: 260,
              height: 48,
              excludeSelected: true,
              controller: _controller3,
              customItemsNamesDisplayed: [
                '🍎 Apple',
                '🍌 Banana',
                '🍒 Cherry',
                '💥 Durian'
              ],
            ),
            const SizedBox(height: 20),
            // Custom header text to display friendly label for the selected value
            SDropdown(
              items: _items,
              selectedItem: 'Apple',
              selectedItemText: '🍎 Apple',
              hintText: 'Selected text override',
              width: 260,
              height: 48,
            ),
            const SizedBox(height: 20),
            // Validator + item specific style + responsive sizing
            Form(
              child: SDropdown(
                items: _items,
                selectedItem: _selected,
                hintText: 'With validator & item styles (60% width)',
                onChanged: (value) {
                  setState(() {
                    _selected = value;
                  });
                },
                width: 60.w,
                height: 6.h,
                validator: (v) => v == null ? 'Please select' : null,
                validateOnChange: true,
                itemSpecificStyles: {
                  'Durian': const TextStyle(
                      color: Colors.deepPurple, fontWeight: FontWeight.bold),
                },
              ),
            ),
            const SizedBox(height: 20),
            // Controller demonstration with programmatic navigation
            SDropdown(
              items: _items,
              hintText: 'Controller demo',
              width: 260,
              height: 48,
              controller: _controller2,
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                ElevatedButton(
                  onPressed: () => _controller2.open(),
                  child: const Text('Open'),
                ),
                const SizedBox(width: 12),
                ElevatedButton(
                  onPressed: () => _controller2.highlightNext(),
                  child: const Text('Highlight Next'),
                ),
                const SizedBox(width: 12),
                ElevatedButton(
                  onPressed: () => _controller2.selectHighlighted(),
                  child: const Text('Select Highlighted'),
                ),
                const SizedBox(width: 12),
                ElevatedButton(
                  onPressed: () => _controller2.highlightAtIndex(2),
                  child: const Text('Highlight Index 2'),
                ),
                const SizedBox(width: 12),
                ElevatedButton(
                  onPressed: () => _controller2.highlightItem('Apple'),
                  child: const Text('Highlight Item Apple'),
                ),
                const SizedBox(width: 12),
                ElevatedButton(
                  onPressed: () => _controller2.selectIndex(1),
                  child: const Text('Select Index 1'),
                ),
                const SizedBox(width: 12),
                ElevatedButton(
                  onPressed: () => _controller2.selectItem('Cherry'),
                  child: const Text('Select Item Cherry'),
                ),
              ],
            ),
            Row(
              children: [
                ElevatedButton(
                  onPressed: () => _controller.open(),
                  child: const Text('Open'),
                ),
                const SizedBox(width: 12),
                ElevatedButton(
                  onPressed: () => _controller.close(),
                  child: const Text('Close'),
                ),
                const SizedBox(width: 12),
                ElevatedButton(
                  onPressed: () => _controller.toggle(),
                  child: const Text('Toggle'),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                ElevatedButton(
                  onPressed: () => _controller3.open(),
                  child: const Text('Open Exclude'),
                ),
                const SizedBox(width: 12),
                ElevatedButton(
                  onPressed: () => _controller3.highlightAtIndex(0),
                  child: const Text('Try Highlight Selected (Index 0)'),
                ),
                const SizedBox(width: 12),
                ElevatedButton(
                  onPressed: () => _controller3.selectIndex(2),
                  child: const Text('Select Index 2'),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Text('Selected value: ${_selected ?? "(none)"}'),
          ],
        ),
      ),
    );
  }
}
