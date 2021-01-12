import { Injectable } from '@angular/core';
import { Observable, interval } from 'rxjs';
import { map, flatMap, startWith } from 'rxjs/operators';

import * as generated from './endpoint.services';
import { NotificationMockService } from './notification-mock.service';

@Injectable()
export class NotificationService {

  private lastNotificationDate: Date;
  private _recentNotifications: generated.NotificationViewModel[];

  get currentUser() {
    return this.authEndpointService.currentUser;
  }

  get recentNotifications() {
    return this._recentNotifications;
  }

    set recentNotifications(notifications: generated.NotificationViewModel[]) {
    this._recentNotifications = notifications;
  }



  constructor(private notificationMockService: NotificationMockService, private authEndpointService: generated.AuthEndpointService) {

  }


  getNotification(notificationId?: string) {

      return this.notificationMockService.getNotificationEndpoint(notificationId).pipe(
          map(response => generated.NotificationViewModel.fromJS(response)));
  }


  getNotifications(page: number, pageSize: number) {

    return this.notificationMockService.getNotificationsEndpoint(page, pageSize).pipe(
      map(response => {
        return this.getNotificationsFromResponse(response);
      }));
  }


  getUnreadNotifications(userId?: string) {

    return this.notificationMockService.getUnreadNotificationsEndpoint(userId).pipe(
      map(response => this.getNotificationsFromResponse(response)));
  }


  getNewNotifications() {
    return this.notificationMockService.getNewNotificationsEndpoint(this.lastNotificationDate).pipe(
      map(response => this.processNewNotificationsFromResponse(response)));
  }


  getNewNotificationsPeriodically() {
    return interval(10000).pipe(
      startWith(0),
      flatMap(() => {
        return this.notificationMockService.getNewNotificationsEndpoint(this.lastNotificationDate).pipe(
          map(response => this.processNewNotificationsFromResponse(response)));
      }));
  }




  pinUnpinNotification(notificationOrNotificationId: string | generated.NotificationViewModel, isPinned?: boolean): Observable<any> {

    if (typeof notificationOrNotificationId === 'string' || notificationOrNotificationId instanceof String) {
      return this.notificationMockService.getPinUnpinNotificationEndpoint(notificationOrNotificationId as string, isPinned);
    } else {
      return this.pinUnpinNotification(notificationOrNotificationId.id);
    }
  }


  readUnreadNotification(notificationIds: string[], isRead: boolean): Observable<any> {

    return this.notificationMockService.getReadUnreadNotificationEndpoint(notificationIds, isRead);
  }




    deleteNotification(notificationOrNotificationId: string | generated.NotificationViewModel): Observable<generated.NotificationViewModel> {

      if (typeof notificationOrNotificationId === 'string' || notificationOrNotificationId instanceof String) { // Todo: Test me if its check is valid
        return this.notificationMockService.getDeleteNotificationEndpoint(notificationOrNotificationId as string).pipe(
        map(response => {
          this.recentNotifications = this.recentNotifications.filter(n => n.id != notificationOrNotificationId);
            return generated.NotificationViewModel.fromJS(response);
        }));
    } else {
      return this.deleteNotification(notificationOrNotificationId.id);
    }
  }




  private processNewNotificationsFromResponse(response) {
    const notifications = this.getNotificationsFromResponse(response);

    for (const n of notifications) {
      if (n.date > this.lastNotificationDate) {
        this.lastNotificationDate = n.date;
      }
    }

    return notifications;
  }


  private getNotificationsFromResponse(response) {
      const notifications: generated.NotificationViewModel[] = [];

      for (const i in response) {
          notifications[i] = generated.NotificationViewModel.fromJS(response[i]);
    }

    notifications.sort((a, b) => b.date.valueOf() - a.date.valueOf());
    notifications.sort((a, b) => (a.isPinned === b.isPinned) ? 0 : a.isPinned ? -1 : 1);

    this.recentNotifications = notifications;

    return notifications;
  }
}
