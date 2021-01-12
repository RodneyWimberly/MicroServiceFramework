import { Injectable, Injector, ErrorHandler } from '@angular/core';
import { AlertService, MessageSeverity } from './services/alert.service';
import * as generated from './services/endpoint.services';
import { ExtendedLogService } from './services/extended-log.service';

@Injectable()
export class AppErrorHandler extends ErrorHandler {
  private alertService: AlertService;
  private extendedLogService: ExtendedLogService

  constructor(private injector: Injector) {
    super();
  }

  handleError(error: Error) {
    let message: string = error.message + '\r\n\r\nStack:\r\n' + error.stack;

    let extendedLog = new generated.ExtendedLogViewModel();
    extendedLog.eventId = 0;
    extendedLog.message = message;
    extendedLog.level = 4;
    extendedLog.name = error.name;
    extendedLog.timeStamp = new Date(Date.now());
    if (!this.extendedLogService)
      this.extendedLogService = this.injector.get(ExtendedLogService);
    this.extendedLogService.addExtendedLog(extendedLog);

    if (!this.alertService)
      this.alertService = this.injector.get(AlertService);
    this.alertService.showStickyMessage(error.name + " - Error", message, MessageSeverity.error, error);

    super.handleError(error);
  }
}
