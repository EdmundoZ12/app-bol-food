import 'package:bol_food_app/models/notifications/push_message.dart';
import 'package:equatable/equatable.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

class NotificationsState extends Equatable {
  final AuthorizationStatus status;
  final List<PushMessage> notifications;

  const NotificationsState({
    this.status = AuthorizationStatus.notDetermined,
    this.notifications = const [],
  });

  NotificationsState copyWith({
    AuthorizationStatus? status,
    List<PushMessage>? notifications,
  }) => NotificationsState(
    status: status ?? this.status,
    notifications: notifications ?? this.notifications,
  );

  @override
  List<Object> get props => [status, notifications];
}
