import 'package:expandable_plus/expandable_plus.dart';
import 'package:flutter/material.dart';

void main() => runApp(const ExampleApp());

const _sampleText =
    'This panel shows a short summary while collapsed and the full text once '
    'expanded. Tap the header or the arrow to toggle it.';

/// The root of the example app.
class ExampleApp extends StatelessWidget {
  /// Creates the example app.
  const ExampleApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'expandable_plus demo',
      theme: ThemeData(colorSchemeSeed: Colors.blue, useMaterial3: true),
      home: const HomePage(),
    );
  }
}

/// A page that shows the three main features: a basic panel, an accordion
/// group, and header padding.
class HomePage extends StatefulWidget {
  /// Creates the home page.
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final ExpandableGroupController _group = ExpandableGroupController();

  @override
  void dispose() {
    _group.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('expandable_plus')),
      body: ExpandableTheme(
        data: const ExpandableThemeData(
          iconColor: Colors.blue,
          useInkWell: true,
        ),
        child: ListView(
          padding: const EdgeInsets.all(12),
          children: [
            _title(context, 'Basic panel'),
            const _BasicCard(),
            _title(context, 'Accordion group'),
            _AccordionCard(group: _group),
            _title(context, 'Header padding'),
            const _HeaderPaddingCard(),
            _title(context, 'Lazy bodies in a long list'),
            const _LazyCard(),
          ],
        ),
      ),
    );
  }

  Widget _title(BuildContext context, String text) {
    return Padding(
      padding: const EdgeInsets.only(top: 16, bottom: 8, left: 4),
      child: Text(text, style: Theme.of(context).textTheme.titleMedium),
    );
  }
}

class _BasicCard extends StatelessWidget {
  const _BasicCard();

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAlias,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: ExpandablePanel(
          theme: const ExpandableThemeData(
            headerAlignment: ExpandablePanelHeaderAlignment.center,
          ),
          header: const Text('Details'),
          collapsed: const Text(
            _sampleText,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          expanded: const Text(_sampleText),
        ),
      ),
    );
  }
}

class _AccordionCard extends StatelessWidget {
  const _AccordionCard({required this.group});

  final ExpandableGroupController group;

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          for (var i = 0; i < 3; i++) ...[
            if (i > 0) const Divider(height: 1),
            // Each panel joins the shared group through an ExpandableNotifier,
            // which owns a controller wired to the group. Opening one panel
            // closes the others.
            ExpandableNotifier(
              group: group,
              child: ExpandablePanel(
                theme: const ExpandableThemeData(
                  headerAlignment: ExpandablePanelHeaderAlignment.center,
                  tapBodyToCollapse: true,
                  headerPadding: EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                ),
                header: Text('Section ${i + 1}'),
                collapsed: const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 12),
                  child: Text(
                    'Tap to open. Opening one section closes the rest.',
                  ),
                ),
                expanded: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Text('Body of section ${i + 1}. $_sampleText'),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _HeaderPaddingCard extends StatelessWidget {
  const _HeaderPaddingCard();

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAlias,
      child: ExpandablePanel(
        theme: const ExpandableThemeData(
          headerAlignment: ExpandablePanelHeaderAlignment.center,
          headerPadding: EdgeInsets.all(16),
        ),
        header: const Text('A header with 16px of padding'),
        collapsed: const Padding(
          padding: EdgeInsets.fromLTRB(16, 0, 16, 16),
          child: Text('Summary', maxLines: 1, overflow: TextOverflow.ellipsis),
        ),
        expanded: const Padding(
          padding: EdgeInsets.fromLTRB(16, 0, 16, 16),
          child: Text(_sampleText),
        ),
      ),
    );
  }
}

/// Twenty panels whose bodies count their own builds.
///
/// A cross-fade keeps both children in the tree, and without `lazy` every panel
/// the viewport lays out builds its expanded body on the first frame. The
/// counter stays at zero until you open one.
class _LazyCard extends StatefulWidget {
  const _LazyCard();

  @override
  State<_LazyCard> createState() => _LazyCardState();
}

class _LazyCardState extends State<_LazyCard> {
  bool _lazy = true;
  int _builds = 0;
  // Flipping the mode rebuilds the panels, and this key is what makes the
  // count start over rather than carrying the previous mode's total.
  int _generation = 0;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Switch(
                  value: _lazy,
                  onChanged: (v) => setState(() {
                    _lazy = v;
                    _builds = 0;
                    _generation++;
                  }),
                ),
                const SizedBox(width: 8),
                Expanded(child: Text('lazy: $_lazy')),
                Text(
                  'bodies built: $_builds',
                  style: Theme.of(context).textTheme.labelLarge,
                ),
              ],
            ),
            const SizedBox(height: 8),
            SizedBox(
              height: 260,
              child: ListView.builder(
                key: ValueKey(_generation),
                itemCount: 20,
                itemBuilder: (context, i) => ExpandablePanel(
                  lazy: _lazy,
                  header: Text('Section $i'),
                  collapsed: const SizedBox(height: 8),
                  expanded: _CountedBody(onBuild: _count),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _count() {
    // Called from a child's build, so the rebuild waits for the frame to end.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) setState(() => _builds++);
    });
  }
}

class _CountedBody extends StatelessWidget {
  const _CountedBody({required this.onBuild});

  final VoidCallback onBuild;

  @override
  Widget build(BuildContext context) {
    onBuild();
    return const Padding(
      padding: EdgeInsets.symmetric(vertical: 8),
      child: Text('This body was built.'),
    );
  }
}
