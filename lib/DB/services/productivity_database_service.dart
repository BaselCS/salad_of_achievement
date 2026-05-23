import '../../objectbox.g.dart';
import '../models/data_model.dart';

/// Repository-ready ObjectBox service for Stacked dependency injection.
class ProductivityDatabaseService {
  ProductivityDatabaseService._(this._store) {
    _groupBox = Box<ActivityGroup>(_store);
    _activityBox = Box<Activity>(_store);
    _sessionBox = Box<Session>(_store);
  }

  final Store _store;

  late final Box<ActivityGroup> _groupBox;
  late final Box<Activity> _activityBox;
  late final Box<Session> _sessionBox;

  static Future<ProductivityDatabaseService> create({String? directory}) async {
    final store = await openStore(directory: directory);
    return ProductivityDatabaseService._(store);
  }

  Store get store => _store;

  Future<void> close() async {
    _store.close();
  }

  Future<ActivityGroup> addActivityGroup(String name) async {
    final trimmedName = name.trim();
    final groupName = trimmedName.isEmpty ? 'مرجأة' : trimmedName;
    final existing = _groupBox
        .query(ActivityGroup_.name.equals(groupName))
        .build()
        .findFirst();
    if (existing != null) {
      return existing;
    }

    final group = ActivityGroup(name: groupName);
    _groupBox.put(group);
    return group;
  }

  Future<ActivityGroup?> updateActivityGroup(
    ActivityGroup group, {
    String? name,
  }) async {
    if (group.id == 0) {
      return null;
    }
    final updatedName = name?.trim();
    if (updatedName != null && updatedName.isNotEmpty) {
      group.name = updatedName;
    }
    _groupBox.put(group);
    return group;
  }

  Future<void> deleteActivityGroup(int groupId) async {
    final group = _groupBox.get(groupId);
    if (group == null) {
      return;
    }
    _groupBox.remove(groupId);
  }

  Future<Activity> addActivity(
    Activity activity, {
    ActivityGroup? group,
    String? groupName,
  }) async {
    final resolvedGroup = await _resolveGroup(
      group: group,
      groupName: groupName ?? activity.group,
    );
    activity.groupRef.target = resolvedGroup;
    if (activity.id == 0) {
      _activityBox.put(activity);
    } else {
      _activityBox.put(activity);
    }
    return activity;
  }

  Future<Activity?> updateActivity(
    Activity activity, {
    String? name,
    int? timeSpent,
    bool? isArchived,
    ActivityGroup? group,
    String? groupName,
  }) async {
    if (activity.id == 0) {
      return null;
    }
    if (name != null && name.trim().isNotEmpty) {
      activity.name = name.trim();
    }
    if (timeSpent != null) {
      activity.timeSpent = timeSpent;
    }
    if (isArchived != null) {
      activity.isArchived = isArchived;
    }
    if (group != null || groupName != null) {
      activity.groupRef.target = await _resolveGroup(
        group: group,
        groupName: groupName ?? activity.group,
      );
    }
    _activityBox.put(activity);
    return activity;
  }

  Future<void> deleteActivity(int activityId) async {
    _activityBox.remove(activityId);
  }

  Future<Session> addSession(
    Session session, {
    Activity? activity,
    String? activityName,
    String? groupName,
  }) async {
    final resolvedActivity = await _resolveActivityForSession(
      activity: activity ?? session.activityRef.target,
      activityName: activityName ?? session.activityName,
      groupName: groupName ?? session.group,
      sessionMinutes: session.durationInMinutes,
    );

    if (resolvedActivity != null) {
      session.activityRef.target = resolvedActivity;
      session.group = resolvedActivity.group;
      resolvedActivity.timeSpent += session.durationInMinutes;
      _activityBox.put(resolvedActivity);
    }

    _sessionBox.put(session);
    return session;
  }

  Future<List<Session>> getAllSessionsWithRelations() async {
    final query = _sessionBox.query().build();
    final sessions = query.find();
    query.close();

    for (final session in sessions) {
      final activity = session.activityRef.target;
      if (activity != null) {
        final groupName = activity.group;
        if (groupName.isNotEmpty) {
          session.group = groupName;
        }
      }
    }

    return sessions;
  }

  Future<int> totalDurationForGroup(ActivityGroup group) async {
    if (group.id == 0) {
      return 0;
    }

    final activities = group.activities.toList(growable: false);
    var total = 0;
    for (final activity in activities) {
      total += activity.sessions.fold<int>(
        0,
        (sum, session) => sum + session.durationInMinutes,
      );
    }
    return total;
  }

  Future<void> migrateLegacyData() async {
    final defaultGroup = await addActivityGroup('مرجأة');
    final activities = _activityBox.getAll();
    for (final activity in activities) {
      if (activity.groupRef.target == null) {
        final resolvedGroup = await _resolveGroup(groupName: activity.group);
        activity.groupRef.target = resolvedGroup ?? defaultGroup;
        _activityBox.put(activity);
      }
    }

    final sessions = _sessionBox.getAll();
    for (final session in sessions) {
      if (session.activityRef.target == null) {
        final resolvedActivity = await _resolveActivityForSession(
          activityName: session.activityName,
          groupName: session.group,
          sessionMinutes: session.durationInMinutes,
        );
        if (resolvedActivity != null) {
          session.activityRef.target = resolvedActivity;
          session.group = resolvedActivity.group;
          _sessionBox.put(session);
        }
      }
    }
  }

  Future<ActivityGroup?> _resolveGroup({
    ActivityGroup? group,
    String? groupName,
  }) async {
    if (group != null) {
      if (group.id == 0) {
        _groupBox.put(group);
      }
      return group;
    }

    final trimmedName = groupName?.trim();
    final effectiveName = trimmedName == null || trimmedName.isEmpty
        ? 'مرجأة'
        : trimmedName;
    final existing = _groupBox
        .query(ActivityGroup_.name.equals(effectiveName))
        .build()
        .findFirst();
    if (existing != null) {
      return existing;
    }

    final created = ActivityGroup(name: effectiveName);
    _groupBox.put(created);
    return created;
  }

  Future<Activity?> _resolveActivityForSession({
    Activity? activity,
    String? activityName,
    String? groupName,
    required int sessionMinutes,
  }) async {
    if (activity != null) {
      if (activity.id == 0) {
        final resolvedGroup = await _resolveGroup(groupName: activity.group);
        activity.groupRef.target = resolvedGroup;
        if (activity.timeSpent == 0) {
          activity.timeSpent = sessionMinutes;
        }
        _activityBox.put(activity);
      }
      return activity;
    }

    final trimmedName = activityName?.trim();
    final effectiveName = trimmedName == null || trimmedName.isEmpty
        ? 'غير محدد'
        : trimmedName;

    final existing = _activityBox
        .query(Activity_.name.equals(effectiveName))
        .build()
        .findFirst();
    if (existing != null) {
      final resolvedGroup = await _resolveGroup(
        groupName: groupName ?? existing.group,
      );
      existing.groupRef.target = resolvedGroup;
      _activityBox.put(existing);
      return existing;
    }

    final resolvedGroup = await _resolveGroup(groupName: groupName);
    final created = Activity(
      name: effectiveName,
      timeSpent: sessionMinutes,
      groupEntity: resolvedGroup,
      group: resolvedGroup?.name ?? (groupName ?? 'مرجأة'),
    );
    created.groupRef.target = resolvedGroup;
    _activityBox.put(created);
    return created;
  }
}
