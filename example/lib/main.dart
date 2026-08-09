import 'package:expandable_plus/expandable_plus.dart';
import 'package:flutter/material.dart';

void main() => runApp(const ExampleApp());

/// One screen from a shop: the page you land on after placing an order.
///
/// A checkout summary is where the three things this package does turn up at
/// once. Shipping, Payment and Returns each answer one question in a single
/// line, and each opens into the controls that change that answer. Only one is
/// open at a time, because the page would be unreadable otherwise. And the
/// headers have to work for someone who cannot see the chevron.
///
/// The card under the accordion reads the screen reader announcement back on
/// screen, which is the closest a sighted developer gets to hearing it. The
/// item list at the bottom is the long-list case for `lazy`.
///
/// `example/test/screen_reader_transcript_test.dart` drives this page and
/// prints what the headers announce at each step.
class ExampleApp extends StatelessWidget {
  /// Creates the example app.
  const ExampleApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'expandable_plus demo',
      theme: ThemeData(colorSchemeSeed: Colors.blue, useMaterial3: true),
      home: const OrderPage(),
    );
  }
}

/// One way of getting the order to the customer.
class _ShippingOption {
  const _ShippingOption(this.label, this.detail, this.summary);

  /// The name of the option, shown in the expanded body.
  final String label;

  /// When it arrives and what it costs.
  final String detail;

  /// The one line the collapsed section shows once this option is chosen.
  final String summary;
}

const _shippingOptions = <_ShippingOption>[
  _ShippingOption(
    'Standard',
    'Tue 12 Aug, free',
    'Standard, arrives Tue 12 Aug',
  ),
  _ShippingOption(
    'Express',
    'Mon 11 Aug, £4.90',
    'Express, arrives Mon 11 Aug',
  ),
  _ShippingOption(
    'Collection',
    'Today after 17:00, free',
    'Collect today from Bristol Broadmead',
  ),
];

/// The order page.
class OrderPage extends StatefulWidget {
  /// Creates the order page.
  const OrderPage({super.key});

  @override
  State<OrderPage> createState() => _OrderPageState();
}

class _OrderPageState extends State<OrderPage> {
  static const _titles = <String>['Shipping', 'Payment', 'Returns'];
  static const _icons = <IconData>[
    Icons.local_shipping_outlined,
    Icons.credit_card,
    Icons.assignment_return,
  ];

  final ExpandableGroupController _group = ExpandableGroupController();
  late final List<ExpandableController> _controllers;

  /// Which delivery option is chosen. The collapsed Shipping line is derived
  /// from this, so changing it in the open section changes what the closed one
  /// says. That is the difference between a second view and a clipped one.
  int _shipping = 0;

  /// The section the reader last worked with, and so the one the announcement
  /// card describes.
  int _focused = 0;

  @override
  void initState() {
    super.initState();
    _controllers = <ExpandableController>[
      for (var i = 0; i < _titles.length; i++)
        // Handing every controller the same group is the whole accordion
        // setup. Shipping starts open because a summary page with everything
        // shut tells you nothing.
        ExpandableController(group: _group, initialExpanded: i == 0),
    ];
    for (final controller in _controllers) {
      controller.addListener(_followTheGroup);
    }
  }

  @override
  void dispose() {
    for (final controller in _controllers) {
      controller.removeListener(_followTheGroup);
      controller.dispose();
    }
    _group.dispose();
    super.dispose();
  }

  void _followTheGroup() {
    final open = _group.expandedMember;
    setState(() {
      // Opening a section moves the announcement to it. Closing the open one
      // leaves the announcement where it was, which is where the finger was.
      if (open != null) {
        _focused = _controllers.indexOf(open);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final chosen = _shippingOptions[_shipping];
    final summaries = <String>[
      chosen.summary,
      'Visa ending 4242',
      'Free until 26 August',
    ];
    final bodies = <Widget>[
      _ShippingBody(
        selected: _shipping,
        onChanged: (index) => setState(() => _shipping = index),
      ),
      const _PaymentBody(),
      const _ReturnsBody(),
    ];

    return Scaffold(
      appBar: AppBar(title: const Text('Order A-2291')),
      body: ExpandableTheme(
        data: const ExpandableThemeData(
          iconColor: Colors.blue,
          headerAlignment: ExpandablePanelHeaderAlignment.center,
          headerPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        ),
        child: ListView(
          padding: const EdgeInsets.all(12),
          children: [
            Card(
              clipBehavior: Clip.antiAlias,
              margin: EdgeInsets.zero,
              child: Column(
                children: [
                  for (var i = 0; i < _titles.length; i++) ...[
                    if (i > 0) const Divider(height: 1),
                    ExpandablePanel(
                      controller: _controllers[i],
                      header: _SectionHeader(
                        icon: _icons[i],
                        title: _titles[i],
                      ),
                      collapsed: _SummaryLine(text: summaries[i]),
                      expanded: bodies[i],
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 12),
            _AnnouncementCard(
              title: _titles[_focused],
              expanded: _controllers[_focused].expanded,
            ),
            const SizedBox(height: 12),
            const _ItemsCard(),
          ],
        ),
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.icon, required this.title});

  final IconData icon;
  final String title;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 20),
        const SizedBox(width: 12),
        Text(title, style: Theme.of(context).textTheme.titleMedium),
      ],
    );
  }
}

/// The one line a section shows while it is closed.
class _SummaryLine extends StatelessWidget {
  const _SummaryLine({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      // Indented to sit under the title rather than under the icon.
      padding: const EdgeInsets.fromLTRB(48, 0, 16, 14),
      child: Text(
        text,
        style: theme.textTheme.bodyMedium?.copyWith(
          color: theme.colorScheme.onSurfaceVariant,
        ),
      ),
    );
  }
}

class _ShippingBody extends StatelessWidget {
  const _ShippingBody({required this.selected, required this.onChanged});

  final int selected;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          for (var i = 0; i < _shippingOptions.length; i++)
            _OptionRow(
              label: _shippingOptions[i].label,
              detail: _shippingOptions[i].detail,
              chosen: i == selected,
              onTap: () => onChanged(i),
            ),
          const SizedBox(height: 8),
          Text(
            'Delivering to 12 Rosemary Lane, Bristol BS1 4TR',
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}

class _OptionRow extends StatelessWidget {
  const _OptionRow({
    required this.label,
    required this.detail,
    required this.chosen,
    required this.onTap,
  });

  final String label;
  final String detail;
  final bool chosen;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Row(
          children: [
            Icon(
              chosen ? Icons.radio_button_checked : Icons.radio_button_off,
              size: 20,
              color: chosen
                  ? theme.colorScheme.primary
                  : theme.colorScheme.outline,
            ),
            const SizedBox(width: 12),
            Expanded(child: Text(label)),
            Text(
              detail,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PaymentBody extends StatelessWidget {
  const _PaymentBody();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.credit_card, size: 20),
              const SizedBox(width: 12),
              const Text('Visa 4242'),
              const Spacer(),
              Text(
                'expires 04/29',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'Billed to 12 Rosemary Lane, Bristol BS1 4TR',
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 4),
          TextButton(
            onPressed: () {},
            style: TextButton.styleFrom(padding: EdgeInsets.zero),
            child: const Text('Pay with another card'),
          ),
        ],
      ),
    );
  }
}

class _ReturnsBody extends StatelessWidget {
  const _ReturnsBody();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.fromLTRB(16, 0, 16, 16),
      child: Text(
        'Send anything back within 30 days of delivery and the refund goes to '
        'the card above. Print a label from this page, or hand the parcel in '
        'at any collection point without one.',
      ),
    );
  }
}

/// Reads back what a screen reader announces for the header last touched.
///
/// Both facts in the line come from the `Semantics(button: true, expanded:
/// ...)` that `ExpandableButton` wraps around every header, and this card
/// reads the same controller that widget reads. Keeping the two from drifting
/// apart is the job of `example/test/screen_reader_transcript_test.dart`: it
/// pulls the real semantics node for each header and fails if this line
/// disagrees with it.
class _AnnouncementCard extends StatelessWidget {
  const _AnnouncementCard({required this.title, required this.expanded});

  final String title;
  final bool expanded;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.record_voice_over_outlined,
                  size: 20,
                  color: theme.colorScheme.primary,
                ),
                const SizedBox(width: 8),
                Text(
                  'What a screen reader announces',
                  style: theme.textTheme.titleSmall,
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              '"$title, button, ${expanded ? 'expanded' : 'collapsed'}"',
              style: theme.textTheme.bodyLarge,
            ),
            const SizedBox(height: 8),
            Text(
              'Nothing above asks for that. It comes from ExpandableButton, '
              'which every header goes through.',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

const _items = <(String, double)>[
  ('Oat milk, 1 L', 2.15),
  ('Sourdough loaf', 3.40),
  ('Free-range eggs, 6', 2.80),
  ('Cherry tomatoes, 250 g', 1.75),
  ('Salted butter, 250 g', 2.50),
  ('Mature cheddar, 350 g', 4.20),
  ('Chicken thighs, 800 g', 5.60),
  ('Basmati rice, 1 kg', 3.15),
  ('Olive oil, 500 ml', 6.95),
  ('Ground coffee, 227 g', 4.80),
  ('Bananas, 5', 1.05),
  ('Baby spinach, 200 g', 1.60),
  ('Greek yoghurt, 500 g', 2.25),
  ('Penne, 500 g', 1.10),
  ('Chopped tomatoes, 2 tins', 1.30),
  ('Red onions, 1 kg', 1.45),
  ('Frozen peas, 900 g', 1.90),
  ('Dark chocolate, 100 g', 2.05),
  ('Kitchen roll, 4', 3.35),
  ('Dishwasher tablets, 40', 7.50),
];

final double _basket = _items.fold(0, (sum, item) => sum + item.$2);

/// The order lines, each one a panel, with a count of how many have built
/// their expanded body.
///
/// A cross-fade keeps both children in the tree, so with `lazy` off every line
/// the list lays out builds its detail before anyone opens it. One panel never
/// notices. Twenty do, and the counter next to the switch is the difference.
class _ItemsCard extends StatefulWidget {
  const _ItemsCard();

  @override
  State<_ItemsCard> createState() => _ItemsCardState();
}

class _ItemsCardState extends State<_ItemsCard> {
  bool _lazy = true;
  int _built = 0;

  /// Flipping the switch has to start the count over rather than carry the
  /// previous mode's total, and a new key is what throws the old list elements
  /// away so their details are built again.
  int _generation = 0;

  void _countOneDetail() {
    // Called from a child's initState, so the rebuild has to wait for the
    // frame to end. Counting initState rather than build is the point rather
    // than a detail: a build counter would be incremented by the setState that
    // displays it, and the number would climb on its own forever.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        setState(() => _built++);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '${_items.length} items, £${_basket.toStringAsFixed(2)}',
              style: theme.textTheme.titleMedium,
            ),
            Row(
              children: [
                Switch(
                  value: _lazy,
                  onChanged: (value) => setState(() {
                    _lazy = value;
                    _built = 0;
                    _generation++;
                  }),
                ),
                const SizedBox(width: 8),
                Expanded(child: Text('lazy: $_lazy')),
                Text(
                  'bodies built: $_built of ${_items.length}',
                  style: theme.textTheme.labelLarge,
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              _lazy
                  ? 'No line below has built its detail. The first one does '
                        'when you open it, and it stays built after you close '
                        'it again.'
                  : 'Every line the list has laid out built its detail '
                        'already, open or not. Scroll and the count climbs.',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 8),
            SizedBox(
              height: 240,
              child: ListView.builder(
                key: ValueKey(_generation),
                itemCount: _items.length,
                itemBuilder: (context, i) => ExpandablePanel(
                  lazy: _lazy,
                  theme: const ExpandableThemeData(
                    headerPadding: EdgeInsets.symmetric(vertical: 2),
                  ),
                  header: _ItemHeader(name: _items[i].$1, price: _items[i].$2),
                  collapsed: const SizedBox(height: 4),
                  expanded: _ItemDetail(onInit: _countOneDetail),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ItemHeader extends StatelessWidget {
  const _ItemHeader({required this.name, required this.price});

  final String name;
  final double price;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(child: Text(name)),
        Text('£${price.toStringAsFixed(2)}'),
      ],
    );
  }
}

/// One order line's detail, which reports the moment it comes into existence.
class _ItemDetail extends StatefulWidget {
  const _ItemDetail({required this.onInit});

  final VoidCallback onInit;

  @override
  State<_ItemDetail> createState() => _ItemDetailState();
}

class _ItemDetailState extends State<_ItemDetail> {
  @override
  void initState() {
    super.initState();
    widget.onInit();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        'Substitutions allowed. Packed Sat 9 Aug.',
        style: theme.textTheme.bodySmall?.copyWith(
          color: theme.colorScheme.onSurfaceVariant,
        ),
      ),
    );
  }
}
