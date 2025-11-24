import 'package:flutter/material.dart';
import 'package:minkids/models/tip.dart';
import 'package:minkids/services/tips_service.dart';
import 'package:minkids/services/auth_service.dart';

class TipsScreen extends StatefulWidget {
  const TipsScreen({super.key});

  @override
  State<TipsScreen> createState() => _TipsScreenState();
}

class _TipsScreenState extends State<TipsScreen> {
  String _userRole = 'hijo';
  String? _selectedCategory;
  List<TipModel> _tips = [];
  List<String> _categories = [];

  @override
  void initState() {
    super.initState();
    _loadTips();
  }

  Future<void> _loadTips() async {
    final user = await AuthService.currentUser();
    final role = user?.rol ?? 'hijo';
    final tips = TipsService.getTipsForRole(role);
    final categories = TipsService.getCategoriesForRole(role);

    setState(() {
      _userRole = role;
      _tips = tips;
      _categories = categories;
    });
  }

  List<TipModel> get _filteredTips {
    if (_selectedCategory == null) return _tips;
    return _tips.where((tip) => tip.category == _selectedCategory).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          _buildAppBar(),
          SliverToBoxAdapter(child: _buildCategoryFilter()),
          SliverPadding(
            padding: const EdgeInsets.all(16),
            sliver: SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) => _buildTipCard(_filteredTips[index]),
                childCount: _filteredTips.length,
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showRandomTip,
        icon: const Icon(Icons.shuffle),
        label: const Text('Consejo Aleatorio'),
      ),
    );
  }

  Widget _buildAppBar() {
    return SliverAppBar(
      expandedHeight: 200,
      pinned: true,
      flexibleSpace: FlexibleSpaceBar(
        title: Text(
          _userRole == 'padre' ? 'Consejos para Padres' : 'Consejos para Ti',
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            shadows: [
              Shadow(
                offset: Offset(0, 1),
                blurRadius: 3.0,
                color: Color.fromARGB(128, 0, 0, 0),
              ),
            ],
          ),
        ),
        background: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: _userRole == 'padre'
                  ? [Colors.indigo, Colors.blue]
                  : [Colors.purple, Colors.deepPurple],
            ),
          ),
          child: Stack(
            children: [
              Positioned(
                right: -50,
                top: -50,
                child: Icon(
                  _userRole == 'padre' ? Icons.family_restroom : Icons.child_care,
                  size: 200,
                  color: Colors.white.withOpacity(0.1),
                ),
              ),
              Positioned(
                left: 20,
                bottom: 60,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${_tips.length} consejos',
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 14,
                      ),
                    ),
                    Text(
                      '${_categories.length} categorías',
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCategoryFilter() {
    return Container(
      height: 60,
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        children: [
          _buildCategoryChip('Todos', null),
          ..._categories.map((category) => _buildCategoryChip(category, category)),
        ],
      ),
    );
  }

  Widget _buildCategoryChip(String label, String? category) {
    final isSelected = _selectedCategory == category;
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: FilterChip(
        label: Text(label),
        selected: isSelected,
        onSelected: (selected) {
          setState(() {
            _selectedCategory = selected ? category : null;
          });
        },
        selectedColor: _userRole == 'padre' ? Colors.indigo.shade100 : Colors.purple.shade100,
        checkmarkColor: _userRole == 'padre' ? Colors.indigo : Colors.purple,
      ),
    );
  }

  Widget _buildTipCard(TipModel tip) {
    final color = _getColorFromName(tip.colorName ?? 'blue');
    final icon = _getIconFromName(tip.iconName ?? 'lightbulb');

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        onTap: () => _showTipDetails(tip),
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: color.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(icon, color: color, size: 24),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          tip.title,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: color.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            tip.category,
                            style: TextStyle(
                              fontSize: 12,
                              color: color,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Icon(Icons.chevron_right, color: Colors.grey),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                tip.content,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[700],
                  height: 1.4,
                ),
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showTipDetails(TipModel tip) {
    final color = _getColorFromName(tip.colorName ?? 'blue');
    final icon = _getIconFromName(tip.iconName ?? 'lightbulb');

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        expand: false,
        builder: (context, scrollController) => SingleChildScrollView(
          controller: scrollController,
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: color.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Icon(icon, color: color, size: 32),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            tip.title,
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                            decoration: BoxDecoration(
                              color: color.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              tip.category,
                              style: TextStyle(
                                fontSize: 14,
                                color: color,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                Text(
                  tip.content,
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey[800],
                    height: 1.6,
                  ),
                ),
                const SizedBox(height: 32),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.check),
                    label: const Text('Entendido'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: color,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showRandomTip() {
    final randomTip = TipsService.getRandomTipForRole(_userRole);
    _showTipDetails(randomTip);
  }

  Color _getColorFromName(String colorName) {
    switch (colorName) {
      case 'blue':
        return Colors.blue;
      case 'green':
        return Colors.green;
      case 'purple':
        return Colors.purple;
      case 'orange':
        return Colors.orange;
      case 'red':
        return Colors.red;
      case 'indigo':
        return Colors.indigo;
      case 'amber':
        return Colors.amber;
      case 'teal':
        return Colors.teal;
      case 'cyan':
        return Colors.cyan;
      case 'pink':
        return Colors.pink;
      case 'deepPurple':
        return Colors.deepPurple;
      case 'deepOrange':
        return Colors.deepOrange;
      default:
        return Colors.blue;
    }
  }

  IconData _getIconFromName(String iconName) {
    switch (iconName) {
      case 'schedule':
        return Icons.schedule;
      case 'person':
        return Icons.person;
      case 'chat':
        return Icons.chat;
      case 'sports_soccer':
        return Icons.sports_soccer;
      case 'no_cell':
        return Icons.mobile_off;
      case 'security':
        return Icons.security;
      case 'star':
        return Icons.star;
      case 'visibility':
        return Icons.visibility;
      case 'warning':
        return Icons.warning;
      case 'update':
        return Icons.update;
      case 'apps':
        return Icons.apps;
      case 'psychology':
        return Icons.psychology;
      case 'self_improvement':
        return Icons.self_improvement;
      case 'shield':
        return Icons.shield;
      case 'sentiment_satisfied':
        return Icons.sentiment_satisfied;
      case 'record_voice_over':
        return Icons.record_voice_over;
      case 'nature_people':
        return Icons.nature_people;
      case 'lightbulb':
        return Icons.lightbulb;
      case 'lock':
        return Icons.lock;
      case 'favorite':
        return Icons.favorite;
      case 'palette':
        return Icons.palette;
      case 'bedtime':
        return Icons.bedtime;
      case 'school':
        return Icons.school;
      case 'accessibility_new':
        return Icons.accessibility_new;
      default:
        return Icons.lightbulb;
    }
  }
}
