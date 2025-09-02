import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../services/notification_service.dart';

enum TaskFilter { all, pending, completed }

class TasksScreen extends StatefulWidget {
  const TasksScreen({super.key});

  @override
  State<TasksScreen> createState() => _TasksScreenState();
}

class _TasksScreenState extends State<TasksScreen>
    with TickerProviderStateMixin {
  final _titleCtrl = TextEditingController();
  final _uid = FirebaseAuth.instance.currentUser!.uid;
  bool _isAdding = false;
  TaskFilter _currentFilter = TaskFilter.all;

  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    _animationController.dispose();
    super.dispose();
  }

  CollectionReference<Map<String, dynamic>> get _tasks =>
      FirebaseFirestore.instance.collection('tasks');

  Future<void> _addTask() async {
    final title = _titleCtrl.text.trim();
    if (title.isEmpty) return;

    setState(() => _isAdding = true);

    try {
      await _tasks.add({
        'title': title,
        'completed': false,
        'userId': _uid,
        'createdAt': FieldValue.serverTimestamp(),
      });
      _titleCtrl.clear();
    } finally {
      setState(() => _isAdding = false);
    }
  }

  Future<void> _toggle(String id, bool value) async {
    await _tasks.doc(id).update({'completed': value});

    // Send completion notification if task is marked as complete
    if (value) {
      final taskDoc = await _tasks.doc(id).get();
      final taskTitle = taskDoc.data()?['title'] ?? 'Task';
      await NotificationService().sendTaskCompletionNotification(taskTitle);
    }
  }

  Future<void> _edit(String id, String newTitle) async {
    if (newTitle.trim().isNotEmpty) {
      await _tasks.doc(id).update({'title': newTitle.trim()});
    }
  }

  Future<void> _delete(String id) async {
    await _tasks.doc(id).delete();
  }

  void _showNotificationSettings(BuildContext context) {
    Navigator.pushNamed(context, '/notification_settings');
  }

  void _showSettings(BuildContext context) {
    Navigator.pushNamed(context, '/settings');
  }

  Stream<QuerySnapshot<Map<String, dynamic>>> _getFilteredTasks() {
    Query<Map<String, dynamic>> query = _tasks
        .where('userId', isEqualTo: _uid)
        .orderBy('createdAt', descending: true);

    switch (_currentFilter) {
      case TaskFilter.pending:
        query = query.where('completed', isEqualTo: false);
        break;
      case TaskFilter.completed:
        query = query.where('completed', isEqualTo: true);
        break;
      case TaskFilter.all:
      default:
        break;
    }

    return query.snapshots();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Theme.of(context).colorScheme.primaryContainer.withOpacity(0.3),
              Theme.of(context).colorScheme.secondaryContainer.withOpacity(0.3),
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Header
              Container(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Icon(
                      Icons.task_alt,
                      size: 32,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'My Tasks',
                        style: Theme.of(context).textTheme.headlineSmall
                            ?.copyWith(fontWeight: FontWeight.bold),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.notifications_outlined),
                      onPressed: () => _showNotificationSettings(context),
                      tooltip: 'Notification Settings',
                    ),
                    IconButton(
                      icon: const Icon(Icons.settings_outlined),
                      onPressed: () => _showSettings(context),
                      tooltip: 'Settings',
                    ),
                  ],
                ),
              ),

              // Task Statistics
              StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                stream: _tasks.where('userId', isEqualTo: _uid).snapshots(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) return const SizedBox.shrink();

                  final allTasks = snapshot.data!.docs;
                  final completedTasks =
                      allTasks
                          .where((doc) => doc.data()['completed'] == true)
                          .length;
                  final pendingTasks = allTasks.length - completedTasks;

                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Row(
                      children: [
                        Expanded(
                          child: _buildStatCard(
                            'Total',
                            allTasks.length.toString(),
                            Icons.list_alt,
                            Theme.of(context).colorScheme.primary,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: _buildStatCard(
                            'Pending',
                            pendingTasks.toString(),
                            Icons.pending,
                            Colors.orange,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: _buildStatCard(
                            'Completed',
                            completedTasks.toString(),
                            Icons.check_circle,
                            Colors.green,
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),

              const SizedBox(height: 16),

              // Filter Tabs
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Card(
                  child: Padding(
                    padding: const EdgeInsets.all(4),
                    child: Row(
                      children: [
                        Expanded(child: _buildFilterTab(TaskFilter.all, 'All')),
                        Expanded(
                          child: _buildFilterTab(TaskFilter.pending, 'Pending'),
                        ),
                        Expanded(
                          child: _buildFilterTab(
                            TaskFilter.completed,
                            'Completed',
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // Add Task Input
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _titleCtrl,
                            decoration: const InputDecoration(
                              hintText: 'Add a new task...',
                              border: InputBorder.none,
                              contentPadding: EdgeInsets.zero,
                            ),
                            onSubmitted: (_) => _addTask(),
                          ),
                        ),
                        const SizedBox(width: 12),
                        ElevatedButton.icon(
                          onPressed: _isAdding ? null : _addTask,
                          icon:
                              _isAdding
                                  ? const SizedBox(
                                    height: 16,
                                    width: 16,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                    ),
                                  )
                                  : const Icon(Icons.add),
                          label: Text(_isAdding ? 'Adding...' : 'Add'),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // Tasks List
              Expanded(
                child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                  stream: _getFilteredTasks(),
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    final docs = snapshot.data!.docs;
                    if (docs.isEmpty) {
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              _currentFilter == TaskFilter.completed
                                  ? Icons.check_circle_outline
                                  : _currentFilter == TaskFilter.pending
                                  ? Icons.pending_outlined
                                  : Icons.task_outlined,
                              size: 64,
                              color:
                                  Theme.of(
                                    context,
                                  ).colorScheme.onSurfaceVariant,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              _currentFilter == TaskFilter.completed
                                  ? 'No completed tasks'
                                  : _currentFilter == TaskFilter.pending
                                  ? 'No pending tasks'
                                  : 'No tasks yet',
                              style: Theme.of(
                                context,
                              ).textTheme.titleLarge?.copyWith(
                                color:
                                    Theme.of(
                                      context,
                                    ).colorScheme.onSurfaceVariant,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              _currentFilter == TaskFilter.all
                                  ? 'Add your first task above!'
                                  : 'Tasks will appear here when available',
                              style: Theme.of(
                                context,
                              ).textTheme.bodyMedium?.copyWith(
                                color:
                                    Theme.of(
                                      context,
                                    ).colorScheme.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ),
                      );
                    }

                    return ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemCount: docs.length,
                      itemBuilder: (context, index) {
                        final doc = docs[index];
                        final data = doc.data();
                        final isCompleted = data['completed'] == true;

                        return FadeTransition(
                          opacity: _fadeAnimation,
                          child: Padding(
                            padding: const EdgeInsets.only(bottom: 8),
                            child: Dismissible(
                              key: ValueKey(doc.id),
                              background: Container(
                                decoration: BoxDecoration(
                                  color: Colors.red,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                alignment: Alignment.centerRight,
                                padding: const EdgeInsets.only(right: 20),
                                child: const Icon(
                                  Icons.delete,
                                  color: Colors.white,
                                ),
                              ),
                              onDismissed: (_) => _delete(doc.id),
                              child: Card(
                                child: ListTile(
                                  leading: Checkbox(
                                    value: isCompleted,
                                    onChanged:
                                        (value) =>
                                            _toggle(doc.id, value ?? false),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                  ),
                                  title: _EditableTitle(
                                    initial: data['title'] ?? '',
                                    isCompleted: isCompleted,
                                    onSubmit: (value) => _edit(doc.id, value),
                                  ),
                                  trailing: IconButton(
                                    icon: const Icon(Icons.delete_outline),
                                    onPressed: () => _delete(doc.id),
                                    tooltip: 'Delete task',
                                  ),
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatCard(
    String title,
    String count,
    IconData icon,
    Color color,
  ) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(height: 4),
            Text(
              count,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            Text(
              title,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterTab(TaskFilter filter, String label) {
    final isSelected = _currentFilter == filter;
    return GestureDetector(
      onTap: () => setState(() => _currentFilter = filter),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          color:
              isSelected
                  ? Theme.of(context).colorScheme.primary
                  : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          label,
          textAlign: TextAlign.center,
          style: TextStyle(
            color:
                isSelected
                    ? Theme.of(context).colorScheme.onPrimary
                    : Theme.of(context).colorScheme.onSurfaceVariant,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ),
    );
  }
}

class _EditableTitle extends StatefulWidget {
  final String initial;
  final bool isCompleted;
  final ValueChanged<String> onSubmit;

  const _EditableTitle({
    required this.initial,
    required this.isCompleted,
    required this.onSubmit,
  });

  @override
  State<_EditableTitle> createState() => _EditableTitleState();
}

class _EditableTitleState extends State<_EditableTitle> {
  late TextEditingController _ctrl;
  bool _editing = false;

  @override
  void initState() {
    super.initState();
    _ctrl = TextEditingController(text: widget.initial);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_editing) {
      return GestureDetector(
        onDoubleTap: () => setState(() => _editing = true),
        child: Text(
          _ctrl.text.isEmpty ? '(no title)' : _ctrl.text,
          style: TextStyle(
            decoration: widget.isCompleted ? TextDecoration.lineThrough : null,
            color:
                widget.isCompleted
                    ? Theme.of(context).colorScheme.onSurfaceVariant
                    : Theme.of(context).colorScheme.onSurface,
          ),
        ),
      );
    }

    return TextField(
      controller: _ctrl,
      autofocus: true,
      decoration: const InputDecoration(
        border: InputBorder.none,
        contentPadding: EdgeInsets.zero,
      ),
      onSubmitted: (value) {
        setState(() => _editing = false);
        widget.onSubmit(value);
      },
      onEditingComplete: () {
        setState(() => _editing = false);
        widget.onSubmit(_ctrl.text);
      },
    );
  }
}
